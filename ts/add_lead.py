"""
Gathers a set of related title given an input list of titles.

Usage:
    ./add_lead [--api-url=<url>]

Options:
    -h --help        Show this documentation
    --api-url=<url>  The URL of the mediawiki api to use
                     [default: https://en.wikipedia.org/w/api.php]
"""
import random
import sys
import traceback, re

import docopt
import mwparserfromhell
import requests

from mw.api import Session
from menagerie.formatting import tsv
from menagerie.iteration import aggregate

HEADERS = [
    'input_title',
    'lead_bit',
    'similar_title',
    'rank',
    'snippet',
]

def main():
    args = docopt.docopt(__doc__)

    similar_titles = tsv.Reader(sys.stdin)
    session = Session(args['--api-url'])

    run(similar_titles, session)

def run(similar_titles, session):

    grouped_similar_titles = aggregate(similar_titles,
                                       by=lambda r:r.input_title)

    writer = tsv.Writer(sys.stdout, headers=HEADERS)
    for input_title, rows in grouped_similar_titles:

        try:
            content = list(session.revisions.query(titles={input_title}, properties={'content'}, limit=1))[0]['*']
        except Exception as e:
            content = ""
            sys.stderr.write(traceback.format_exc())
            
            
        parsed = mwparserfromhell.parse(content)
        lead_bit = "".join(str(v) for v in parsed.strip_code())[:200] + "..."
            
        
        sys.stderr.write(".");sys.stderr.flush()
        for row in rows:
            writer.write([
                re.sub(re.compile(r"\#.*"), "", 
                       row.input_title.replace("_", " ")),
                lead_bit,
                row.similar_title.replace("_", " "),
                row.rank,
                row.snippet
            ])
        
    
    sys.stderr.write("\n");sys.stderr.flush()





if __name__ == "__main__": main()
