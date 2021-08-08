from bs4 import BeautifulSoup
import datetime
import requests
import hashlib
import time
import json
import re

today = datetime.date.today()


def get_data(list_url):
    '''Main scraping function
    Parameters: 
    list_url (str): a valid url

    Returns:
    movie_dict: a dictionary of movie data
    '''
    print(f'Opening {list_url}')
    try:
        headers = {'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36'}
        main_page = requests.get(list_url, headers=headers, timeout=5)
        print('Successfully opened the main url')
    except requests.ConnectionError as e:
        print("Connection Error. Make sure you are connected to Internet. Technical Details given below.\n")
        print(str(e))
    except requests.Timeout as e:
        print("Timeout Error")
        print(str(e))
    
    # store data in a dict
    movie_dict = {}

    # parse the html using beautiful soup and store in variable `soup`
    print('Pulling the main page\'s html')
    soup = BeautifulSoup(main_page.text, 'html.parser')

    movie_rows = soup.find_all('tr')

    for movie in movie_rows[1:]:
        # break down each column of data for this movie
        columns = movie.find_all('td')
        cols = [ele for ele in columns]
        
        # grab some data points
        release_date = cols[1].text.strip()
        title = cols[2].text.strip()
        production_budget = cols[3].text.strip()
        domestic_gross = cols[4].text.strip()
        worldwide_gross = cols[5].text.strip()

        # if the movie isn't released yet or release date unknown
        # move to the next iteration
        if (release_date == 'Unknown'):
            continue

        # for weird release dates
        try:
            rel_date_formatted = datetime.datetime.strptime(release_date, '%b %d, %Y').date()
        except:
            continue
        
        if rel_date_formatted > today:
            continue

        # hashing the title as a key
        hashed_title = hashlib.sha1(title.encode('utf8')).hexdigest()

        # push the above data points into a dictionary
        movie_dict[hashed_title] = {}
        movie_dict[hashed_title]['title'] = title
        movie_dict[hashed_title]['release_date'] = release_date
        movie_dict[hashed_title]['production_budget'] = production_budget
        movie_dict[hashed_title]['domestic_gross'] = domestic_gross
        movie_dict[hashed_title]['worldwide_gross'] = worldwide_gross

        # go to the summary page for the current movie
        movie_summary_link = BeautifulSoup(str(cols[2]), 'html.parser')
        movie_summary_link = movie_summary_link.find('a')['href']
        movie_summary_link = 'https://www.the-numbers.com' + movie_summary_link
        
        # get summary data
        genre, story_source, creative_type, production_method, production_company, MPAA_Rating, runtime, opening_theater_count, max_theater_count, avg_run_per_theater = get_movie_summary(movie_summary_link, title)

        # push the summary data to the dictionary
        movie_dict[hashed_title]['genre'] = genre
        movie_dict[hashed_title]['story_source'] = story_source
        movie_dict[hashed_title]['creative_type'] = creative_type    
        movie_dict[hashed_title]['production_method'] = production_method
        movie_dict[hashed_title]['production_company'] = production_company
        movie_dict[hashed_title]['MPAA_Rating'] = MPAA_Rating
        movie_dict[hashed_title]['runtime'] = runtime
        movie_dict[hashed_title]['opening_theater_count'] = opening_theater_count
        movie_dict[hashed_title]['max_theater_count'] = max_theater_count
        movie_dict[hashed_title]['avg_run_per_theater'] = avg_run_per_theater

        # link to cast and crew page
        cast_crew_link = re.sub('summary', 'cast-and-crew', movie_summary_link)

        # get cast and crew data
        actors, directors = get_cast_crew(cast_crew_link, title)

        # push the cast and crew data to the dictionary
        movie_dict[hashed_title]['actors'] = actors
        movie_dict[hashed_title]['directors'] = directors

        print(f'Done with {title}\'s data')

    return movie_dict



def get_movie_summary(movie_url, title):
    '''Takes a specific movie & scrapes a few data points
    Parameters: 
    movie_url (str): the url of a movie's summary page
    title (str): the name of said movie - just for printing

    Returns:
    genre, story_source, creative_type, production_method, production_company, MPAA_Rating, runtime, opening_theater_count, max_theater_count, avg_run_per_theater
    (the above are all strings)
    '''
    print(f'Trying to open {title}\'s summary page')
    try:
        headers = {'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36'}
        page = requests.get(movie_url, headers=headers, timeout=5)
        print(f'Successfully {title}\'s summary page')
    except requests.ConnectionError as e:
        print("Connection Error. Make sure you are connected to Internet. Technical Details given below.\n")
        print(str(e))
    except requests.Timeout as e:
        print("Timeout Error")
        print(str(e))

    # parse the html using beautiful soup and store in variable `detail_soup`
    print(f'Pulling {title}\'s summary html')
    detail_soup = BeautifulSoup(page.text, 'html.parser')

    # grab some data points, self explanatory
    genre = get_specific_tag(detail_soup, 'a', 'genre')
    story_source = get_specific_tag(detail_soup, 'a', 'source')
    creative_type = get_specific_tag(detail_soup, 'a', 'creative-type')
    production_method = get_specific_tag(detail_soup, 'a', 'production-method')
    production_company = get_specific_tag(detail_soup, 'a', 'production-company') 
    MPAA_Rating = get_specific_tag(detail_soup, 'a', 'mpaa-rating')
    runtime = get_specific_tag(detail_soup, 'td', '.* minutes')
    theater_master = get_specific_tag(detail_soup, 'td', '.* opening theaters')
    # some regex work for theatre counts & theatre residency times
    if theater_master:     
        theater_counts = re.compile('\d+(?:,\d+)?')
        theater_counts = theater_counts.findall(theater_master)
        opening_theater_count = theater_counts[0]
        max_theater_count = theater_counts[1]
        avg_run_per_theater = theater_counts[2] + '.' + theater_counts[3] + ' weeks'
    else:
        opening_theater_count, max_theater_count, avg_run_per_theater = 0, 0, 0

    print(f'Done with {title}\'s summary page')
    return genre, story_source, creative_type, production_method, production_company, MPAA_Rating, runtime, opening_theater_count, max_theater_count, avg_run_per_theater

def get_specific_tag(soup, tag, value):
    '''Helper to shorten some repetitive bs4 find's

    Parameters: 
    soup (bs4 obj): a beautiful soup object
    tag (str): an html tag. Ex: 'a'
    value (str): the value being searched for. Ex: if tag='a', value='director'

    Returns:
    text (str)
    '''
    if tag == 'a':
        if soup.find(tag, href=re.compile(value)):
            return soup.find(tag, href=re.compile(value)).text.strip()
        else:
            return ''
    if tag == 'td':
        if soup.find(tag, text=re.compile(value)):
            return soup.find(tag, text=re.compile(value)).text.strip()
        else:
            return ''

def get_cast_crew(movie_url, title):
    '''Takes a specific movie & scrapes a few data points around cast and crew

    Parameters: 
    movie_url (str): the url of a movie's cast and crew page
    title (str): the name of said movie - just for printing

    Returns:
    actors (str): a pipe joined list of actor name strings
    directors (str): a pipe joined list of director name strings
    '''
    print(f'Trying to open {title}\'s cast and crew page')
    try:
        headers = {'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36'}
        page = requests.get(movie_url, headers=headers, timeout=5)
        print(f'Successfully opened {title}\'s cast and crew page')
    except requests.ConnectionError as e:
        print("Connection Error. Make sure you are connected to Internet. Technical Details given below.\n")
        print(str(e))
    except requests.Timeout as e:
        print("Timeout Error")
        print(str(e))

    # parse the html using beautiful soup and store in variable `soup`
    print(f'Pulling {title}\'s cast and crew html')

    # parse the html using beautiful soup and store in variable `soup`
    cast_soup = BeautifulSoup(page.text, 'html.parser')

    actors = get_cast_group('actor', cast_soup)
    directors = get_cast_group('director', cast_soup)

    print(f'Successfully pulled {title}\'s cast and crew data')
    return actors, directors
    

def get_cast_group(group, soup):
    '''A helper to format cast and crew data

    Parameters: 
    group (str): actors or directors
    soup (bs4 obj): a valid beautiful soup object

    Returns:
    cast_group (str): a pipe joined list of name strings
    '''
    parent_list = soup.find_all('td', attrs={'itemprop': f'{group}'})
    cast_group = []

    for sub_list in parent_list:
        child_list = sub_list.find_all('span', attrs={'itemprop': 'name'})
        for person in child_list:
            cast_group.append(person.text)

    cast_group = ' | '.join(cast_group)    

    return cast_group 