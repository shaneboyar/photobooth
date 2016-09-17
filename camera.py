from picamera import PiCamera
from time import sleep
import os
import datetime
from gpiozero import LED

c = PiCamera()
led = LED(2)

current_time = datetime.datetime.now().time()
t = current_time.isoformat()
path = r'/home/pi/Desktop/images/%s' % (t,)
if not os.path.exists(path):
    os.makedirs(path)

c.rotation = 180
c.start_preview()
sleep(2)
for i in range(5):
    sleep(2)
    n = str(i)
    led.on()
    c.capture(path + '/%s.jpg' % (n,))
    led.off()
c.stop_preview()

