from picamera import PiCamera
from time import sleep
import os
import datetime
from gpiozero import LED
import pygame
from pygame.locals import *

#Miniscreen Resolution is 800x480


c = PiCamera()
led = LED(2)

current_time = datetime.datetime.now().time()
t = current_time.isoformat()
path = r'/home/pi/Desktop/images/%s' % (t,)
if not os.path.exists(path):
    os.makedirs(path)

c.rotation = 180
pygame.init()
modes = pygame.display.list_modes()
pygame.display.set_mode(max(modes))
screen = pygame.display.get_surface()
pygame.display.set_caption('Photo Booth')
pygame.mouse.set_visible(False)
pygame.display.toggle_fullscreen()


#img = pygame.image.load("intro.png")
#img = img.convert
#set_dimensions(img.get_width(), img.get_height())

#img = pygame.transform.scale(img, (800, 480))
#screen.blit(img,(0,0))
#pygame.display.flip()

sleep(5)
pygame.quit()
c.start_preview()
sleep(2)
for i in range(5):
    sleep(2)
    n = str(i)
    led.on()
    c.capture(path + '/%s.jpg' % (n,))
    led.off()
c.stop_preview()

