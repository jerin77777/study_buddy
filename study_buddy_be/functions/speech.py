import os
import azure.cognitiveservices.speech as speechsdk
import json
import soundex
import time
import uuid


def speak(text):
    speech_config = speechsdk.SpeechConfig(subscription='5fdcf0d212a341f58d4e3d09ff834b03', region='eastus')
    speech_config.request_word_level_timestamps()
    speech_config.speech_synthesis_voice_name = "en-US-TonyNeural"

    file_name = str(uuid.uuid4()) + ".wav"
    audio_config = speechsdk.audio.AudioOutputConfig(use_default_speaker=True,filename=f"./static/{file_name}")

    # audio_config = speechsdk.audio.AudioOutputConfig(use_default_speaker=True,filename=f"../static/{file_name}")

    speech_config.request_word_level_timestamps()

    speech_synthesizer = speechsdk.SpeechSynthesizer(speech_config=speech_config, audio_config=audio_config)

    word_visemes = []

    def get_viseme(evt):
        word_visemes.append({"id":evt.viseme_id,"offset":evt.audio_offset / 10000})

    speech_synthesizer.viseme_received.connect(get_viseme)

    speech_synthesis_result = speech_synthesizer.speak_text_async(text).get()

    if speech_synthesis_result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
        print("Speech synthesized for text [{}]".format(text))



    speech_recognizer = speechsdk.SpeechRecognizer(speech_config=speech_config, audio_config=audio_config)

    done = False
    word_timings = []
    final_word_timings = []

    for word in text.split(" "):
        word_timings.append({"word": word, "offset": 0.0})

    def get_word_timings(data):
        nonlocal word_timings
        nonlocal final_word_timings

        data_set = []

        for word in data['NBest']:
            data_set.append(word)

        for word in word_timings:
            confidences = []
            data_idx = 0
            for data in data_set:
                found = False
                for i in range(0, 3):
                    s = soundex.getInstance()
                    if i < len(data['Words']):
                        if s.soundex(word['word'].lower()) == s.soundex(data['Words'][i]['Word'].lower()):
                            found = True
                            confidences.append({"offset": data['Words'][i]['Offset'], "confidence": data['Words'][i]['Confidence']})
                            data['Words'] = data['Words'][slice(i, len(data['Words']))]

                if found == False and len(data_set[data_idx]['Words']) != 0:
                    confidences.append({"offset": data_set[data_idx]['Words'][0]['Offset'], "confidence": data_set[data_idx]['Words'][0]['Confidence']})
                    data_set[data_idx]['Words'].pop(0)

                data_idx += 1

            max_confidence = 0

            for confidence in confidences:
                if confidence["confidence"] > max_confidence:
                    max_confidence = confidence["confidence"]

            for confidence in confidences:
                if confidence["confidence"] == max_confidence:
                    word["offset"] = confidence["offset"] / 10000

        cn = 0
        for word in word_timings:
            if word["offset"] != 0.0:
                cn += 1
                final_word_timings.append(word)

        word_timings = word_timings[slice(cn, len(word_timings) + 1)]

    speech_recognizer.recognized.connect(lambda evt: get_word_timings(json.loads(evt.result.json)))

    def stop_cb(evt):
        # print('CLOSING on {}'.format(evt))
        speech_recognizer.stop_continuous_recognition()
        nonlocal done
        done = True

    speech_recognizer.session_stopped.connect(stop_cb)
    speech_recognizer.canceled.connect(stop_cb)

    speech_recognizer.start_continuous_recognition()
    while not done:
        time.sleep(.5)

    print(final_word_timings)
    return {"word_timings":final_word_timings, "word_visemes":word_visemes, "file": "/static/" + file_name}



def speak_only_visieme(text):
    speech_config = speechsdk.SpeechConfig(subscription='5fdcf0d212a341f58d4e3d09ff834b03', region='eastus')
    speech_config.request_word_level_timestamps()

    file_name = str(uuid.uuid4()) + ".wav"
    audio_config = speechsdk.audio.AudioOutputConfig(use_default_speaker=True,filename=f"./static/{file_name}")

    speech_config.speech_synthesis_voice_name = "en-US-TonyNeural"
    speech_config.request_word_level_timestamps()

    speech_synthesizer = speechsdk.SpeechSynthesizer(speech_config=speech_config, audio_config=audio_config)

    word_visemes = []

    def get_viseme(evt):
        word_visemes.append({"id":evt.viseme_id,"offset":evt.audio_offset / 10000})

    speech_synthesizer.viseme_received.connect(get_viseme)

    speech_synthesis_result = speech_synthesizer.speak_text_async(text).get()

    if speech_synthesis_result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
        print("Speech synthesized for text [{}]".format(text))



    return {"word_visemes":word_visemes, "file": "/static/" + file_name}

