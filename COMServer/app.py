#!/usr/bin/env python
# coding:utf-8

from flask import Flask, request,g
from flask_socketio import SocketIO, emit
from flask_redis import FlaskRedis
from flask import jsonify
import os
basedir = os.path.abspath(os.path.dirname(__file__))


# 发送操作指令事件
SEND_LAUNCH_CMD = 'SEND_LAUNCH_CMD'

# 发送监控数据事件
SEND_MON_DATA = 'SEND_MON_DATA'

# 开启监控数据传输
IS_SEND_MON_DATA = 'IS_SEND_MON_DATA'

# 开启视频数据
IS_SEND_VIDEO_DATA = 'IS_SEND_VIDEO_DATA'
#发送视频数据
SEND_VIDEO_DATA = 'SEND_VIDEO_DATA'

app = Flask(__name__, template_folder='./')
app.config['SECRET_KEY'] = 'secret!'
app.config['REDIS_URL'] = "redis://localhost:6379/COM"
socketio = SocketIO(app)
redis_store = FlaskRedis(app)

def getAll():
    all_datas = []
    keys = redis_store.keys()
    for key in keys:
        value = redis_store.get(key)
        all_datas.append({'device':value.decode("utf-8"),'sid':key.decode("utf-8")})

    return all_datas
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
    socketio.emit(SEND_VIDEO_DATA, {'data': 'dada'}, callback=ack)
    return 'success'

@app.route('/switch_video')
def open_send():
    is_open = request.args.get("data")
    print("switch_video",is_open)
    socketio.emit(IS_SEND_VIDEO_DATA, {'data': is_open}, callback=ack)
    return jsonify({'code':11111,'msg':'切换成功'})

@app.route('/get_devices',methods=['GET'])
def get_devices():
    all_devices = getAll()
    print(all_devices)
    return_data = {'code':11111,'msg':'查询成功','data':all_devices}
    return jsonify(return_data)


@socketio.on(SEND_VIDEO_DATA)
def handle_video(data):

    data_dict = {'data':data,'code':11111,'msg':'数据获取成功'}
    socketio.emit(SEND_VIDEO_DATA,data_dict)

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
    print('connecting...')
    device = request.args['device']
    sid = request.sid
    result = redis_store.set(sid,device)
    print('添加成功？',result)

@socketio.on('disconnect')
def disconnect():
    print('disconnect.....')
    sid = request.sid
    device = redis_store.get(sid)
    result = redis_store.delete(sid)
    print('删除成功',result)


@socketio.on('chat')
def chat(json):
    sid = request.sid
    req = request
    print(sid)
    print(json)
    send_sid = json['sid']
    socketio.emit('chat',json,room=send_sid)

@socketio.on_error()
def error_handler(e):
    print('error')
    print(e)

@socketio.on_error_default
def default_error_handler(e):
    print('error')
    print(e)

if __name__ == '__main__':
    redis_store.flushall()
    socketio.run(app, host='0.0.0.0',debug=True)