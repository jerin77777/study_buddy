import json
from dotenv import load_dotenv
from langchain_community.document_loaders import PyPDFLoader

from langchain_google_genai import GoogleGenerativeAIEmbeddings, ChatGoogleGenerativeAI
from langchain_community.vectorstores import FAISS

from video_gen import *
from functions.speech import *
from functions.utils import *

load_dotenv()

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


def get_history(socketId,file,question):
    print(question)

    loader = PyPDFLoader(f".{file}")
    texts = loader.load_and_split()

    embeddings = GoogleGenerativeAIEmbeddings(model="models/embedding-001")
    doc_search = FAISS.from_documents(texts, embeddings)

    docs = doc_search.similarity_search(question)
    chain = get_conversational_chain()


    response = chain.invoke(
        {"input_documents": docs, "question": question}, return_only_outputs=True
    )

    send(socketId,"progress", 10)

    ans = response["output_text"]
    ans += "\ncreate a narration for this text."
    narration = gen(ans)

    send(socketId,"progress",15)


    queries = []

    while len(queries) == 0:
        ans = narration + ' sepreate the text that has a different key idea and create a array of json using the format {"key_idea":value,"text":value} make sure concatenating text values does not differ from the original text, return the array only'
        ans = gen(ans)

        try:
            queries = json.loads(ans)
        except:
            print("caught")
            queries = []

    send(socketId,"progress",20)

    print(queries)
    queries = []
    while len(queries) == 0:
        temp = "rules: No NSFW or obscene content. This includes, nudity, sexual acts, explicit violence, or graphically disturbing material.\n\n"
        temp = temp + ans + ' for each item in array create a 4 second video scene description that follow above rules for the "text" with add it in the json with key "video_description"'
        temp = gen(temp)

        try:
            queries = json.loads(temp)
        except:
            print("caught")
            queries = []

    send(socketId,"progress",30)
    print(queries)

    for query in queries:
        query["promptId"] = prompt(query["video_description"])
        print(query["promptId"])

    send(socketId,"progress",40)


    for query in queries:
        speech = speak(query["text"].strip())
        query["word_timings"] = speech["word_timings"]
        query["word_visemes"] = speech["word_visemes"]
        query["file"] = speech["file"]

    send(socketId,"progress",90)

    toggle()

    for query in queries:
        src = get_src(query["promptId"])
        query["image"] = src["img"]
        query["video"] = src["vid"]

    toggle()

    return queries
