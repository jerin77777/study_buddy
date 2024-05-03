import json
import time

import google.generativeai as genai
from functions.utils import *
# from utils import *
from langchain.text_splitter import RecursiveCharacterTextSplitter
from PyPDF2 import PdfReader

def clean_text(text):
    cn = 0
    idx = 0
    for chr in text:
        cn += 1
        if chr.isdigit():
            idx = cn

    return text[idx:].replace(".","").strip()

def get_topics(file):
    pdf_text = ""

    # pdf_reader = PdfReader(f"../data/1712829486.5056217..globalisation.pdf")
    pdf_reader = PdfReader(f".{file}")
    for page in pdf_reader.pages:
        pdf_text += page.extract_text()

    text_splitter = RecursiveCharacterTextSplitter(chunk_size=10000, chunk_overlap=1000)
    texts = text_splitter.split_text(pdf_text)

    temp_text = ""
    for temp in pdf_text.split("\n"):
        temp_text += f" {temp}"


    pdf_text = temp_text
    temp_text = ""
    # print(new_text)

    headings = []

    for text in texts:
        temp_headings = []
        while len(temp_headings) == 0:
            try:
                ans = gen(text + "\n extract all the main headings from this text without changing them, exclude subtopics and images. return as array of json with key as heading")
                ans = ans.replace("```", "").replace("json", "")
                temp_headings = json.loads(ans)
                for temp in temp_headings:
                    headings.append({"heading":temp["heading"]})
            except:
                print("caught")
                temp_headings = []


    final_headings = []

    # remove duplicates
    for heading in headings:
        heading["heading"] = clean_text(heading["heading"])
        exists = False
        for check in final_headings:
            if check["heading"] == heading["heading"]:
                exists = True

        if not exists:
            final_headings.append(heading)
        # else:
        #     print("removed "+ heading["heading"])

    headings = final_headings
    final_headings = []

    cn = 0
    for heading in headings:
        # heading["heading"] = clean_text(heading["heading"])
        if heading["heading"] in pdf_text and cn + 1 < len(headings) and heading["heading"] != "":

            temp = pdf_text.split(headings[cn]["heading"])[1]
            temp = temp.split(headings[cn+1]["heading"])[0]

            if len(temp) > 50:
                heading["content"] = temp
                final_headings.append(heading)
            # else:
                # print("ommiting: " + heading["heading"])
                # print(headings[cn+1]["heading"])

        cn += 1

    headings = final_headings
    final_headings = []

    for heading in headings:

        difficulty = None
        while difficulty is None:
            try:
                ans = gen(heading["content"] + "\nfrom 0 to 100 rate the difficulty of learning this text. return only the value")
                difficulty = int(ans)
            except:
                difficulty = None
                print("caught")

        if difficulty > 0:
            heading["difficulty"] = difficulty
            final_headings.append(heading)
        else:
            print(f"omitted heading {heading["heading"]}")

    print("completed")

    return final_headings

# print(final_headings)
# print(len(final_headings))
