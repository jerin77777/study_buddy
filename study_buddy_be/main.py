from flask import Flask, request as req, render_template,make_response
from flask_socketio import SocketIO, emit
from functions.functions import *
from functions.get_topics import *
from db_models import *
import os
from werkzeug.utils import secure_filename
from flask_cors import CORS, cross_origin
import time
import base64
import threading


# logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__, static_url_path='/static')
# run_with_ngrok(app)
app.config['SECRET_KEY'] = 'secret!'
app.config['CORS_HEADERS'] = 'Content-Type'

# cors = CORS(app, resources={r"/static/*": {"origins": "*"}})

# cors = CORS(app, resources={r"/api/*": {"origins": "*"}})
cors = CORS(app, resources={r"/static/*": {"origins": "*"}})

socketio = SocketIO(app, cors_allowed_origins="*", async_mode='threading')


@app.route('/')
@cross_origin()
def index():
    return render_template('index.html')


@app.route('/file', methods=['POST'])
@cross_origin()
def handle_form():
    print("file api")
    file = req.files['file']
    fileName = json.loads(file.filename)["name"]
    sessionId = json.loads(file.filename)["id"]
    subject = json.loads(file.filename)["subject"]
    chapter = json.loads(file.filename)["chapter"]
    fileName = str(time.time())  + ".." + fileName
    print(fileName)

    path = os.path.join(os.getcwd(), 'data', secure_filename(fileName))
    file.save(path)
    print("saved")

    file_size = os.path.getsize('./data/'+secure_filename(fileName))
    topics = get_topics("/data/" + secure_filename(fileName))

    difficulties = []
    for topic in topics:
        difficulties.append(topic["difficulty"])

    difficulty = sum(difficulties) / len(difficulties)
    Files.insert(fileName=json.loads(file.filename)["name"], difficulty=difficulty, fileSize=file_size, subject=subject, chapter=chapter, topics=topics, url="/data/" + secure_filename(fileName), sessionId=sessionId).execute()

    result = make_response("/data/" + secure_filename(fileName))
    result.headers['Content-type'] = 'text/xml'

    return result

@app.route('/image', methods=['POST'])
@cross_origin()
def handle_image():
    print("image api")
    file = req.json
    fileName = str(time.time())  + ".." + file["name"]

    image = file["image"]
    path = os.path.join(os.getcwd(), 'static', secure_filename(fileName))

    fh = open(path, "wb")
    fh.write(base64.b64decode(image))
    fh.close()

    print("saved")

    return "/static/" + secure_filename(fileName)

@app.route('/get_files', methods=['POST'])
@cross_origin()
def handle_get_files():
    query = Files.select(Files.fileId, Files.fileName, Files.subject, Files.chapter, Files.topics, Files.fileSize, Files.url).where(Files.sessionId == req.json["sessionId"]).where(Files.subject == req.json["subject"])
    files = list(query.dicts())

    return files

@app.route('/focus', methods=['POST'])
@cross_origin()
def handle_focus():
    print(req.json["image"])
    focus = get_focus(req.json["image"])
    print(focus)
    return {"focus":focus}
    # return result

@app.route('/prompt', methods=['POST'])
@cross_origin()
def handle_prompt():
    result = {"status":404}

    gotAns = False

    # fileId = Files.select(Files.fileId).where(Files.url == req.json["file"]).namedtuples().first()[0]
    # # query = Questions.select(Questions.ans).where(Questions.question == req.json["query"]).namedtuples().first()
    # query = Questions.select(Questions.ans).where(fn.Lower(Questions.question) == str(req.json["query"]).lower()).where(Questions.fileId == fileId).namedtuples().first()
    # if query is not None:
    #     return query[0]
    # print(req.json["socket_id"])
    # print("querying for")

    if req.json["subject"] == "history":
        result = get_history(req.json["socket_id"],req.json["file"],req.json["query"])
    elif req.json["subject"] == "maths":
        result = get_maths(req.json["socket_id"], req.json["query"])
    elif req.json["subject"] == "science":
        result = get_science(req.json["socket_id"], req.json["query"])

    # gotAns = True
    # if gotAns:
    #     Questions.insert(question=req.json["query"],ans=result, fileId=fileId).execute()

    return result

@app.route('/schedule', methods=['POST'])
@cross_origin()
def handle_schedule():
    result = get_schedule()
    return result

@socketio.on('disconnect')
def test_disconnect():
    print('Client disconnected new')
    # delete_socket(req.sid)
    print(req.sid)

def startServer():
    socketio.run(app, host="0.0.0.0", port=5000, debug=False,allow_unsafe_werkzeug=True)

if __name__ == '__main__':
    t1 = threading.Thread(target=startServer)
    t2 = threading.Thread(target=load)

    t1.start()
    t2.start()

    t1.join()
    t2.join()

