"""
Gathers a set of related title given an input list of titles.

Usage:
    ./get_similar_titles <n> [--exclude-category=<cat>] [--api-url=<url>]

Options:
    -h --help                 Show this documentation
    --exclude-category=<cat>  The name of a category to exclude from results
                              [default: Living_people]
    --api-url=<url>           The API URL to use
                              [default: http://en.wikipedia.org/w/api.php]
"""
import requests, docopt, sys, traceback

from menagerie.formatting import tsv

HEADERS = [
    'input_title',
    'similar_title',
    'rank',
    'snippet'
]

def main():
    args = docopt.docopt(__doc__)
    
    titles = tsv.Reader(sys.stdin)
    similar_n = int(args['<n>'])
    exclude_category = args['--exclude-category']
    api_url = args['--api-url']
    
    run(titles, similar_n, exclude_category, api_url)

def run(titles, similar_n, exclude_category, api_url):
    
    writer = tsv.Writer(sys.stdout, headers=HEADERS)
    for row in titles:
        try:
            page_docs = get_similar(api_url, row.title)
            
            filtered_page_docs = list(filter_category(api_url, page_docs,
                                                      exclude_category, similar_n))
            
            for i, page_doc in enumerate(filtered_page_docs):
                writer.write(
                    [
                        row.title,
                        page_doc['title'],
                        i+1,
                        filter_spans(page_doc['snippet'])
                    ]
                )
                sys.stderr.write(".");sys.stderr.flush()
                
            sys.stderr.write("|");sys.stderr.flush()
        except Exception as e:
            sys.stderr.write(traceback.format_exc())
    


def filter_spans(snippet):
    
    snippet = snippet.replace("<span class=\"searchmatch\">", "")
    return snippet.replace("</span>", "")

def filter_category(api_url, page_docs, category, n):
    """
    Basically just performs a call to ...api.php?prop=categories
    and checks whether a category match occured and filters those titles until
    either titles run out or n results have been returned.
    """
    params = {
        'action': "query",
        'prop': "categories",
        'titles': "|".join(d['title'] for d in page_docs),
        'cllimit': 1,
        'clcategories': "Category:" + category,
        'format': "json"
    }
    
    response = requests.get(api_url, params=params)
    
    doc = response.json()
    
    pages = doc['query']['pages'].values()
    matched_titles = set(p['title'] for p in pages if 'categories' in p)
    
    
    pages_yielded = 0
    for page_doc in page_docs:
        if page_doc['title'] not in matched_titles:
            yield page_doc
            pages_yielded += 1
            
            if pages_yielded >= n: #we're done!
                break

def get_similar(api_url, title):
    """
    Basically just performs a call to ...api.php?list=search
    """
    
    params = {
        'action': "query",
        'list': "search",
        'srsearch': "morelike:" + title,
        'srnamespace': 0,
        'srbackend': "CirrusSearch",
        'format': 'json',
        'srprop': 'snippet',
        'srlimit': 50
    }
    
    response = requests.get(api_url, params=params)
    
    doc = response.json()
    result_docs = doc['query']['search']
    
    return result_docs

if __name__ == "__main__": main()
