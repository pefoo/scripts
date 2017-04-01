from Constants import *
import os

class Logwriter(object):
    @staticmethod
    def write(text):
        script_dir = os.path.dirname(__file__)
        file = os.path.join(script_dir, Constants.Logfile)
        with open(file, 'a') as writer:
            writer.write(text+"\n")
