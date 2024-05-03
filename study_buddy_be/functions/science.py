import time

from functions.utils import *
# from utils import *
from functions.speech import *
# from speech import *
import json
from langchain_community.document_loaders import PyPDFLoader
from langchain_google_genai import GoogleGenerativeAIEmbeddings, ChatGoogleGenerativeAI
from langchain_community.vectorstores import FAISS
from db_models import *


def get_science(socketId,question):
    loader = PyPDFLoader(f"./data/motion.pdf")
    texts = loader.load_and_split()

    embeddings = GoogleGenerativeAIEmbeddings(model="models/embedding-001")
    doc_search = FAISS.from_documents(texts, embeddings)

    docs = doc_search.similarity_search(question)
    chain = get_conversational_chain()

    response = chain.invoke(
        {"input_documents": docs, "question": question}, return_only_outputs=True
    )

    send(socketId, "progress", 10)

    ans = response["output_text"]
    ans += "\ncreate a narration for this text. return only the narration"
    narration = gen(ans)
    print(narration)
    narration += "\nsplit this narration into animation scenes. create a description of a simple animation that helps understand the scene with key as animation, and reference the respective narration that was split in whole with key as narration. return as array of json."


    scenes = []
    while len(scenes) == 0:
        try:
            ans = gen(narration)
            ans = ans.replace("```","").replace("```json","")
            scenes = json.loads(ans)
            temp = scenes[0]["animation"]
            temp = scenes[0]["narration"]
        except:
            print("caught")
            scenes = []

    print(scenes)

    send(socketId, "progress", 20)

    # scenes = [scenes[0]]
    for scene in scenes:
        print(scene)
        objects = []

        while len(objects) == 0:
            try:
                ans = gen(f"""
                {scene["animation"]}

                within a canvas size of 800 x 500
                list the different objects (excluding floor and arrows) that is required to create the animation with key as name, mention the size, position and a description in words of how to create a simple svg of the object without including other objects. return as an array of json objects
                """)


                ans = ans.replace("```json","").replace("```","")
                objects = json.loads(ans)
                for obj in objects:
                    temp = obj["name"]
                    temp = obj["description"]
                    temp = obj["size"]["width"]
                    temp = obj["position"]["x"]

            except:
                print("caught")
                objects = []


        for obj in objects:

            print(obj["name"])
            svg = Objects.select(Objects.object).where(fn.lower(Objects.objectName).contains(obj["name"])).namedtuples().first()
            if svg is not None:
                print(f"got {svg[0]}")
                obj["svg"] = svg[0]
            else:
                obj["instruction"] = f"""
                create svg for {obj["name"]}
                with the following properties
                - width {obj["size"]["width"]}
                - height {obj["size"]["height"]}
                - description {obj["description"]}
                """
                obj["instruction"] = obj["instruction"].strip("\n")
                ans = gen(obj["instruction"])

                obj["svg"] = ans.replace("```svg","").replace("```","").strip("\n")

        prompt = ""
        for obj in objects:
            prompt += f"""
{obj["name"]}
initial position:
    - x: {obj["position"]["x"]}
    - y: {obj["position"]["y"]}
svg: {obj["svg"]}
            """



        prompt += f"""
Place the above svg objects in html code within a screen size of 800 x 500, without any background colors or borders. return as a single ready to use code.
        """
        print("prompt")
        print(prompt)
        print("code 1")
        ans = gen(prompt)
        ans = ans.replace("```html","").replace("```","")
        print(ans)

        print("animated")
        prompt = ans + f"\n\n animation:{scene["animation"]}\n\n animate the objects in html using animated css and anime js to create the above animation. return as a single ready to use code."
        print(prompt)
        ans = gen(prompt)
        ans = ans.replace("```html","").replace("```","")
        print(ans)

        scene["code"] = ans

    send(socketId, "progress", 80)


    for scene in scenes:
        speech = speak(scene["narration"])
        scene["word_timings"] = speech["word_timings"]
        scene["word_visemes"] = speech["word_visemes"]
        scene["audio"] = speech["file"]

    send(socketId, "progress", 90)


    return scenes

# get_science(1,"explain what is uniform and non uniform motion")
