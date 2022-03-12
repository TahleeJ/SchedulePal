from flask import Flask, request
from threading import Thread
from scraper import lookupCourse

app = Flask('')

@app.route('/')
def home():
    return 'Scraping web server is live!'

@app.route('/lookup')
def lookup():
    args = request.args
    course_subject = args.get('course_subject', default='CS', type=str)
    semester = args.get('semester', default='term_in=202202', type=str)
    course_title = args.get('course_title', default='', type=str)
    course_number = args.get('course_number', default='', type=str)

    return lookupCourse(course_subject=course_subject, semester=semester, course_title=course_title, course_number=course_number)

def run():
  app.run(host='0.0.0.0',port=8080)

def keep_alive():
    t = Thread(target=run)
    t.start()

if __name__ == "__main__" :
  keep_alive()