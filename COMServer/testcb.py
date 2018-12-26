import cv2
import numpy
import os
import base64
from socketIO_client import SocketIO,LoggingNamespace


SEND_VIDEO_DATA = 'SEND_VIDEO_DATA'

# 开启监控数据传输
IS_SEND_VIDEO_DATA = 'IS_SEND_VIDEO_DATA'
IS_OPEN = False

def open_video(response,ack):
    global IS_OPEN
    IS_OPEN = bool(int(response['data']))
    print('====',IS_OPEN)
with SocketIO('192.168.0.21', 5000, LoggingNamespace,params={'device': 'lot'}) as socketIO:
    socketIO.connect()
    socketIO.on(IS_SEND_VIDEO_DATA,callback=open_video)

    basedir = os.path.abspath(os.path.dirname(__file__))
    path = '/Users/gaof/Desktop/test/testCV3/haarcascade_frontalface_default.1.xml'
    print(path)
    cap = cv2.VideoCapture(0)
    # detector = cv2.CascadeClassifier(path)
    # detector.load(path)
    while(True):
        ret, frame = cap.read()
        if frame is not None:
            cv2.imshow('frame', frame)
            retval, buffer = cv2.imencode('.jpg', frame)
            print(frame)
            jpg_as_text = base64.b64encode(buffer)
            print(jpg_as_text)
            print('while is open ====', IS_OPEN)
            if IS_OPEN:
                print('=====send=======')
                print('is_open ==',IS_OPEN)
                socketIO.emit(SEND_VIDEO_DATA,jpg_as_text.decode("utf-8"))
        socketIO.wait(seconds=1)
        # gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        # faces = detector.detectMultiScale(gray, 1.3, 5)
        # for (x,y,w,h) in faces:
        #     cv2.rectangle(frame,(x,y),(x+w,y+h),(255, 0, 0), 2)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()
