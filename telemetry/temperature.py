import sys
import os
import time

# pip3 install setuptools
# pip3 install vcgencmd
from vcgencmd import Vcgencmd

def main():
    start_time = time.time()
    fb = open("/home/pi/readings.txt","a+")
    fb.write("Elapsed Time (s),Temperature (°C),Clock Speed (MHz),Throttled\n")
    vcgm = Vcgencmd()
    while True:
        temp = vcgm.measure_temp()
        clock = int(vcgm.measure_clock('arm')/1000000)
        throttled = vcgm.get_throttled()['breakdown']['2']

        string = '%.0f,%s,%s,%s\n' % ((time.time() - start_time),temp,clock,throttled)
        print(string, end='')
        fb.write(string)
        time.sleep(1)

if __name__ == '__main__':
    main()