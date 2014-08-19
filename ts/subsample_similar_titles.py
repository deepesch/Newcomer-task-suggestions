"""
Gathers a set of related title given an input list of titles.

Usage:
    ./subsample_similar_titles <n>

Options:
    -h --help                 Show this documentation
"""
import random
import sys
import traceback

import docopt
import requests

from menagerie.formatting import tsv
from menagerie.iteration import aggregate

HEADERS = [
    'input_title',
    'similar_title',
    'rank',
    'snippet'
]

def main():
    args = docopt.docopt(__doc__)
    
    similar_titles = tsv.Reader(sys.stdin)
    n = int(args['<n>'])
    
    run(similar_titles, n)

def run(similar_titles, n):
    
    grouped_similar_titles = aggregate(similar_titles,
                                       by=lambda r:r.input_title)
    
    writer = tsv.Writer(sys.stdout, headers=HEADERS)
    for input_title, similar_titles in grouped_similar_titles:
        similar_titles = list(similar_titles)
        
        random.shuffle(similar_titles)
        
        for similar_title in similar_titles[:n]:
            writer.write(similar_title.values())
    


if __name__ == "__main__": main()
