import json
from functions.utils import *
# from utils import *
from db_models import *
import math

portions_raw = []

def get_portions():
    portions = ""

    for portion in portions_raw:
        if len(portion["topics"]) != 0:
            portions += f"\n{portion["subject"]}:\n"
            for topic in portion["topics"]:
                portions += f"  topic: {topic["heading"]}, dificulty: {topic["difficulty"]}\n"

    return portions


def get_schedule():
    portions = ""
    tnot = 0
    tnod = 30

    for subject in ["maths","history","science"]:
        query = Files.select(Files.fileName, Files.topics, Files.difficulty,Files.chapter).where(Files.subject == subject).where(Files.sessionId == 6041)
        chapters = list(query.dicts())

        topics = []

        for chapter in chapters:
            tnot += len(chapter["topics"])

            topics.extend(chapter["topics"])

        portions_raw.append({"subject": subject, "topics": topics})

    portions = get_portions()
    allSchedules = []

    for i in range(0,tnod,10):
        schedule = []
        portions = get_portions()
        print(portions)
        print(tnot)
        prompt = portions + f"\nsplit {math.ceil(tnot / tnod)} chapters per day according to difficulty for first 10 days. return as array of json with keys 'day', and array of 'topics' with keys 'subject' and 'topic'"

        while len(schedule) == 0:
            try:
                ans = gen(prompt)
                ans = ans.replace("```json", "").replace("```", "")
                # print(ans)
                schedule = json.loads(ans)
                schedule[0]["topics"][0]["subject"]
                schedule[0]["topics"][0]["topic"]
            except:
                schedule = []
                print("caught")

        for day in schedule:
            got = False
            for topic in day["topics"]:
                for subject in portions_raw:
                    for _topic in subject["topics"]:
                        if topic["topic"].lower() == _topic["heading"].lower():
                            subject["topics"].remove(_topic)
                            got = True
            if got:
                allSchedules.append(day)


    cn = 1
    for schedule in allSchedules:
        schedule["day"] = cn
        cn += 1


    return allSchedules


