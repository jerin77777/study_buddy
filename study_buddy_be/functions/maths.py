from functions.utils import *
from functions.speech import *

def get_maths(socketId, question):

    question += "\n create step by step explanation for this problem"

    narration = gen(question, math=True)
    narration = narration.replace("**","").replace("#","")

    result = []

    for text in narration.split("\n"):
        tex = None
        if text.strip() != "":
            if ("+" or "-" or "*" or "/" or "=") in text:
                print(text)
                query = text + "\ncreate LaTex code for only this text to use in flutter Tex. return only the tex code."
                tex = gen(query)
                tex = tex.replace("```", "")
                print(tex)
            else:
                print(text)

            speech = speak_only_visieme(text.strip())
            result.append({"text": text.strip(), "tex": tex,"file": speech["file"], "word_visemes": speech["word_visemes"]})
    print(result)


    return result


# get_math("","""""A cottage industry produces a certain number of pottery articles in a day. It was observed
# on a particular day that the cost of production of each article (in rupees) was 3 more than
# twice the number of articles produced on that day. If the total cost of production on that
# day was ` 90, find the number of articles produced and the cost of each article.""")
