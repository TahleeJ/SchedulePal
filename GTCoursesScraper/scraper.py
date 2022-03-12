import requests
from bs4 import BeautifulSoup

def lookupCourse(course_subject='CS', semester='term_in=202202', course_title='', course_number=''):
  """ 
    Queries GT schedule of classes database for spring 2020 semester course.

    Args:
    -   course_subject (required): the abbreviation of the queried course's subject (e.g., 'CS')
    -   semester (preset): the academic semester of classes, only if different than spring 2020
    -   course_title (optional): the course's title (e.g, 'Data Structs & Algorithms')
    -   course_number (optional): the course's number (e.g., '1332')

    Returns:
    -    course_matches: JSON of courses' data that math user query
    """

  def parseHTML():
    course_matches = {'courses': []}
    table = soup.find('table', attrs={'class':'datadisplaytable'})
    rows = table.findChildren(['tr'])
    
    for courseIdx in range(0, len(rows), 4):
      title, crn, number, section = [data.strip() for data in rows[courseIdx].text.split('-')]
      type, time, days, location, date_range, schedule_type, instructors = rows[courseIdx+1].findAll('tr')[1].text.strip().split('\n')
      
      course = {
        'title': title,
        'crn': crn,
        'number': number,
        'section': section,
        'type': type,
        'time': time,
        'days': days,
        'location': location,
        'date_range': date_range,
        'schedule_type': schedule_type,
        'instructors': instructors
      }
      
      course_matches['courses'].append(course)      

    return course_matches

  
  query = f'?{semester}&sel_subj=dummy&sel_day=dummy&sel_schd=dummy\
&sel_insm=dummy&sel_camp=dummy&sel_levl=dummy&sel_sess=dummy&sel_instr=dummy\
&sel_ptrm=dummy&sel_attr=dummy&sel_subj={course_subject}&sel_crse={course_number}\
&sel_title={course_title}&sel_schd=%25&sel_from_cred=&sel_to_cred=&sel_camp=%25&sel_ptrm=%25\
&sel_instr=%25&sel_attr=%25&begin_hh=0&begin_mi=0&begin_ap=a&end_hh=0&end_mi=0&end_ap=a'
  
  url = 'https://oscar.gatech.edu/bprod/bwckschd.p_get_crse_unsec' + query
  
  page = requests.get(url)

  soup = BeautifulSoup(page.content, 'html.parser')
  
  course_matches = parseHTML()

  return course_matches