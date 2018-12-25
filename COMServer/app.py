from flask import Flask, request
from flask_socketio import SocketIO, emit
from  flask_sqlalchemy import SQLAlchemy
import os
from model import OnlieDevice
basedir = os.path.abspath(os.path.dirname(__file__))


# 发送操作指令事件
SEND_LAUNCH_CMD = 'SEND_LAUNCH_CMD'

# 发送监控数据事件
SEND_MON_DATA = 'SEND_MON_DATA'

# 开启监控数据传输
IS_SEND_MON_DATA = 'IS_SEND_MON_DATA'

#发送视频数据
SEND_VIDEO_DATA = 'SEND_VIDEO_DATA'

app = Flask(__name__, template_folder='./')
app.config['SECRET_KEY'] = 'secret!'

socketio = SocketIO(app)
db = SQLAlchemy(app)

def ack():
    print('message was received!')

@app.route('/')
def index():
    # return render_template('index.html')
    print('=====')
    # socketio.emit('device_server', {'data': 42},callback=ack)
    return 'test'
@app.route('/send')
def send():
    socketio.emit(SEND_LAUNCH_CMD, {'data': 42}, callback=ack)
    return 'success'

@app.route('/open_send')
def open_send():
    socketio.emit(IS_SEND_MON_DATA, {'data': True}, callback=ack)
    return 'success'

@app.route('/close_send')
def close_send():
    socketio.emit(IS_SEND_MON_DATA, {'data': False}, callback=ack)
    return 'success'

@socketio.on(SEND_VIDEO_DATA)
def handle_video(data):
    print('video data',data)
    data_dict = {'data':data,'code':11111,'msg':'数据获取成功'}
    socketio.emit(SEND_MON_DATA,data_dict)
    return True
@socketio.on(SEND_MON_DATA)
def handle_json(json):
    print('received json' + str(json))
    return 'receive'


@socketio.on('message')
def handle_message(message):
    print('received message: ' + message)

@socketio.on('client_event')
def client_msg(msg):
    print(msg)
    emit('device_server', {'data': msg['data']},callback=ack)


@socketio.on('connect')
def connect():
    device = request.args['device']
    sid = request.sid
    device_model = OnlieDevice(sid=sid,device=device)
    db.session.add(device_model)
    db.session.commit()
    print(sid)
@socketio.on('disconnect')
def disconnect():
    sid = request.sid
    device_model = OnlieDevice.query.filter_by(sid = sid).first()
    db.session.delete(device_model)
    db.session.commit()
    print('Client disconnected')


@socketio.on_error()
def error_handler(e):
    print(e)

@socketio.on_error_default
def default_error_handler(e):
    print('error')
    print(e)

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0',debug=True)