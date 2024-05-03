import json
import time

import google.generativeai as genai
# from functions.utils import *
from utils import *
from IPython.display import Markdown
from langchain_community.document_loaders import PyPDFLoader
from langchain_community.vectorstores import FAISS
from langchain_google_genai import GoogleGenerativeAIEmbeddings, ChatGoogleGenerativeAI
from langchain.text_splitter import RecursiveCharacterTextSplitter
from PyPDF2 import PdfReader


def get_conversational_chain():
    # Define a prompt template for asking questions based on a given context
    prompt_template = """
    Answer the question as detailed as possible from the provided context, make sure to provide all the details,
    if the answer is not in the provided in any of the context just say, "answer is not available in the context", don't provide the wrong answer\n\n
    Context:\n {context}?\n
    Question: \n{question}\n

    Answer:
    """

    # Initialize a ChatGoogleGenerativeAI model for conversational AI
    model = ChatGoogleGenerativeAI(model="gemini-pro", temperature=0.5)

    # Create a prompt template with input variables "context" and "question"
    prompt = PromptTemplate(
        template=prompt_template, input_variables=["context", "question"]
    )

    # Load a question-answering chain with the specified model and prompt
    chain = load_qa_chain(model, chain_type="stuff", prompt=prompt)

    return chain

# def get_topics(file):
# print("getting topics")
text = ""
#
pdf_reader = PdfReader(f"../data/1712829486.5056217..globalisation.pdf")
# pdf_reader = PdfReader(f".{file}")
for page in pdf_reader.pages:
    text += page.extract_text()

text_splitter = RecursiveCharacterTextSplitter(chunk_size=10000, chunk_overlap=1000)
texts = text_splitter.split_text(text)

#
# headings = []
#
# for text in texts:
#     temp_headings = []
#     while len(temp_headings) == 0:
#         try:
#             ans = gen(text + "\n extract all the main headings from this text without changing them, exclude subtopics and images. return as array of json with key as heading")
#             ans = ans.replace("```", "").replace("json", "")
#             temp_headings = json.loads(ans)
#             for temp in temp_headings:
#                 headings.append({"heading":temp["heading"]})
#         except:
#             print("caught")
#             temp_headings = []
#
# final_headings = []
# # remove duplicates
# for heading in headings:
#     exists = False
#     for check in final_headings:
#         if check["heading"] == heading["heading"]:
#             exists = True
#
#     if not exists:
#         final_headings.append(heading)
#
# print("got headings")
# headings = final_headings
# print(headings)
final_headings = []

headings = [{'heading': '77'}, {'heading': 'The Pre-modern World'}, {'heading': '1.1 Silk Routes Link the World'}, {'heading': '1.2 Food Travels: Spaghetti and Potato'}, {'heading': '1.3 Conquest, Disease and Trade'}, {'heading': '2.1 A World Economy Takes Shape'}, {'heading': '1. Interconnections and Flows in the Nineteenth-Century World Economy'}, {'heading': '2.2 Role of Technology'}, {'heading': '2.3 Late nineteenth-century Colonialism'}, {'heading': '2.4 Rinderpest, or the Cattle Plague'}, {'heading': 'Rinderpest, or the Cattle Plague'}, {'heading': 'Indentured Labour Migration from India'}, {'heading': 'Indian Entrepreneurs Abroad'}, {'heading': 'Indian Trade, Colonialism and the Global System'}, {'heading': '1  The World of the Port Cities'}, {'heading': '1.1 A World of Ports: A Global Network'}, {'heading': '1.2 Towards a Global Economy'}, {'heading': '1.3 Surat: A Major Indian Port City'}, {'heading': '1.4 Indian Textiles and the World Market'}, {'heading': '1.5 Terminal Points in India'}, {'heading': '1.6 The Dutch and the English East India Companies'}, {'heading': '1.7 European Companies and Asian Trade'}, {'heading': '1.8 Englishmen in India'}, {'heading': '1.9 Military Power and the East India Company'}, {'heading': '1.10 Bengal: The East India Company’s Biggest Prize'}, {'heading': '1.11 The Company Sarkar'}, {'heading': '2  Colonialism and the Indian Economy'}, {'heading': '2.1 British Colonial Policy'}, {'heading': '2.2 Colonisation and Indian Trade'}, {'heading': '2.3 Rise of Bombay'}, {'heading': '2.4 The Establishment of Colonial Rule'}, {'heading': '2.5 Indian Labour in Plantations'}, {'heading': '2.6 Indian Trade, Colonialism and the Global System'}, {'heading': '3  The Inter-war Economy'}, {'heading': '3.1 Wartime Transformations'}, {'heading': '3.2 Post-war Recovery'}, {'heading': '3.3 Rise of Mass Production and Consumption'}, {'heading': 'Recovery and Expansion'}, {'heading': 'Rise of Mass Production and Consumption'}, {'heading': 'The Great Depression'}, {'heading': 'India and the Great Depression'}, {'heading': 'Who profits from jute cultivation according to the jute growers’ lament? Explain.'}, {'heading': 'DiscussIndia and the Contemporary World'}, {'heading': 'Rebuilding a World Economy: The Post-war Era'}, {'heading': 'The Second World War'}, {'heading': 'Post-war Settlement and the Bretton Woods Institutions'}, {'heading': 'The Early Post-war Years'}, {'heading': 'Decolonisation and Independence'}, {'heading': 'End of Bretton Woods and the Beginning of ‘Globalisation’'}, {'heading': 'The Making of a Global World'}, {'heading': 'Write in brief'}]

for heading in headings:
    hasDigit = any(chr.isdigit() for chr in heading["heading"])
    if hasDigit:
        cn = 0
        idx = 0
        for chr in heading["heading"]:
            cn += 1
            if chr.isdigit():
                idx = cn

        if heading["heading"][idx:].replace(".","").strip() != "":
            heading["heading"] = heading["heading"][idx:].replace(".","").strip()
            # print(heading["heading"])

            final_headings.append(heading)

headings = final_headings
final_headings = []

embeddings = GoogleGenerativeAIEmbeddings(model="models/embedding-001")
doc_search = FAISS.from_texts(texts, embeddings)

chain = get_conversational_chain()
for heading in headings:

    docs = doc_search.similarity_search(heading["heading"])
    print(len(docs))

    # response = None
    # while response is None:
    #     try:
    #         response = chain.invoke(
    #             {"input_documents": docs, "question": f"what is {heading["heading"]}"}, return_only_outputs=True
    #         )
    #     except:
    #         response = None
    #         time.sleep(5)
    #         print("caught")
    #
    # ans = response["output_text"]
    #
    # print(heading["heading"])
    # if "context" not in ans and "not" not in ans:
    #     difficulty = None
    #     while difficulty is None:
    #         try:
    #             ans = gen(ans + "\nfrom 0 to 100 rate the difficulty of learning this text. return only the value")
    #             difficulty = int(ans)
    #         except:
    #             difficulty = None
    #             print("caught")
    #
    #     if difficulty > 0:
    #         heading["difficulty"] = difficulty
    #         final_headings.append(heading)
    #     else:
    #         print(f"omitted heading {heading["heading"]}")
    #
    # else:
    #     print(f"omitted heading {heading["heading"]}")

    print(final_headings)
    print(len(final_headings))

# return final_headings


# final_headings = [{'heading': 'Food Travels: Spaghetti and Potato', 'difficulty': 30}, {'heading': 'Conquest, Disease and Trade', 'difficulty': 80}, {'heading': 'A World Economy Takes Shape', 'difficulty': 60}, {'heading': 'Late nineteenth-century Colonialism', 'difficulty': 50}, {'heading': 'Rinderpest, or the Cattle Plague', 'difficulty': 75}, {'heading': 'Indentured Labour Migration from India', 'difficulty': 75}, {'heading': 'Indian Trade, Colonialism and the Global System', 'difficulty': 60}, {'heading': '3.1 Wartime Transformations', 'difficulty': 50}, {'heading': '3.2 Post-war Recovery', 'difficulty': 70}, {'heading': 'Across India, peasants’ indebtedness increased', 'difficulty': 20}, {'heading': 'The Second World War broke out a mere two decades after the end of the First World War', 'difficulty': 50}, {'heading': 'Post-war Settlement and the Bretton Woods Institutions', 'difficulty': 70}, {'heading': 'The Bretton Woods system inaugurated an era of  unprecedented growth of trade and incomes for the Western industrial nations', 'difficulty': 30}, {'heading': 'Despite years of stable and rapid growth, not all was well in this post-war world', 'difficulty': 60}, {'heading': 'Write in brief', 'difficulty': 60}]
# difficulties = []
# for heading in final_headings:
#     difficulties.append(heading["difficulty"])
#
# avg = sum(difficulties) / len(difficulties)
# print(avg)
#
#
#
# ans = str(final_headings) + "\n create a 3 month plan to study these topics."
# ans = gen(ans)
# print(ans)
# print(len(final_headings))
