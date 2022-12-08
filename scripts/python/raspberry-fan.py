import RPi.GPIO as GPIO
import subprocess
from re import findall
from time import sleep
from subprocess import check_output


def get_temp():
        output = subprocess.check_output(['sensors'], shell=True).decode('utf-8')
        for row in output.split('\n'):
                if 'temp1' in row:
                        key, value = row.split(': ')
                        result = float(value.strip().replace('°C','').replace('+',''))
        return(result)

try:
        GPIO.setwarnings(False)
        tempOn = 44
        threshold = 10
        controlPin = 5
        cur = 0
        pinState = False
        GPIO.setmode(GPIO.BCM)
        GPIO.setup(controlPin, GPIO.OUT, initial=0)
        while True:
                if not pinState:
                        temp = get_temp()
                        print("current: " + str(temp))
                        if temp > tempOn:
                                print("We've got a problem. Let's chill")
                                pinState = not pinState
                                GPIO.output(controlPin, pinState)
                                cur = 0
                else:
                        cur += 1
                        if cur < threshold:
                                print("Still chilling")
                        else:
                                pinState = not pinState
                                GPIO.output(controlPin, pinState)
                                print("Chill is done")
                sleep(5)
except KeyboardInterrupt:
        print("Exit pressed Ctrl+C")
except:
        print("Other Exception")
        print("--- Start Exception Data:")
        traceback.print_exc(limit=2, file=sys.stdout)
        print("--- End Exception Data:")
finally:
        print("CleanUp")
        GPIO.cleanup()
        print("End of program")