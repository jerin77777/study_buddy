import google.generativeai as genai
import os
from flask_socketio import emit
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.chains.question_answering import load_qa_chain
from langchain.prompts import PromptTemplate
import PIL.Image


gkey = "AIzaSyCRL3nXbBTdub71_3r7DKB6G8hxG-rigFU"
os.environ["GOOGLE_API_KEY"] = gkey


def gen(query, math=False):
    genai.configure(api_key=gkey)

    model = genai.GenerativeModel('gemini-pro')

    model.max_output_tokens = 1500
    response = model.generate_content(query)

    ans = str(response.text)

    if math:
        return ans.replace("$", "$$")

    return ans.replace("$", "$$").replace("*", "").replace("#", "")

def gen_stream(query):
    genai.configure(api_key=gkey)

    model = genai.GenerativeModel('gemini-pro')
    response = model.generate_content(query, stream=True, generation_config=genai.types.GenerationConfig(max_output_tokens=20000))

    ans = ""
    for temp in response:
        print(temp.text)
        ans += temp.text


    return ans
def get_focus(image):
    genai.configure(api_key=gkey)

    img = PIL.Image.open(image)

    model = genai.GenerativeModel('gemini-pro-vision')
    focus = None

    while focus is None:
        try:
            response = model.generate_content(["from 0 to 10 rate the focus level of this person. if dark or face is not visible return 10. return only the value",img])
            focus = int(response.text)
        except:
            focus = None
            pass

    return focus



def send(socketId,event,data):
    print("sending data")
    emit(event, data, room=socketId, namespace="/")


def get_conversational_chain():
    # Define a prompt template for asking questions based on a given context
    prompt_template = """
    Answer the question as detailed as possible from the provided context, make sure to provide all the details,
    Context:\n {context}?\n
    Question: \n{question}\n

    Answer:
    """

    # Initialize a ChatGoogleGenerativeAI model for conversational AI
    model = ChatGoogleGenerativeAI(model="gemini-pro")

    # Create a prompt template with input variables "context" and "question"
    prompt = PromptTemplate(
        template=prompt_template, input_variables=["context", "question"]
    )

    # Load a question-answering chain with the specified model and prompt
    chain = load_qa_chain(model, chain_type="stuff", prompt=prompt)

    return chain

