"""
User stats -- Generates productivity stats for new editors in Wikipedia.

Usage:
    ./user_stats [--users=PATH] [--revert-cutoff=SECONDS]
                 [--revert-radius=EDITS] [--user=USER] [--host=HOST]
                 [--defaults-file=PATH]

Options:
    -h | --help              Show this help message
    --users=PATH             The path to a TSV containing the list of users
                             [default: <sys.stdin>]
    --revert-cutoff=SECONDS  The number of seconds to wait for a revert
                             [default: 172800]
    --revert-radius=EDITS    The number of revisions to look back for a revert
                             [default: 15]
    --user=USER              The username with which to connect to the database
                             [default: <getpass.getuser()>]
    --host=HOST              The hostname of the database server
                             [default: analytics-store.eqiad.wmnet]
    --defaults-file=PATH     Database defaults file
                             [default: ~/.my.cnf]
"""

import getpass
import sys
from itertools import chain, groupby

import docopt
from mw import database, Timestamp
from mw.lib import reverts, sessions

from menagerie.formatting import tsv

from .database import connection

HEADERS = [
    "wiki",
    "user_id",
    "day_revisions",
    "day_deleted_revisions",
    "day_main_revisions",
    "day_deleted_main_revisions",
    "day_reverted_main_revisions",
    "day_productive_edits",
    "week_revisions",
    "week_deleted_revisions",
    "week_main_revisions",
    "week_deleted_main_revisions",
    "week_reverted_main_revisions",
    "week_productive_edits",
    "week_sessions",
    "week_session_seconds"
]

def parse_users(f):
    if not f.isatty():
        return tsv.Reader(f, types=[int, str, str])

def main():
    args = docopt.docopt(__doc__)
    
    if args['--users'] == "<sys.stdin>":
        users = tsv.Reader(sys.stdin)
    else:
        users = tsv.Reader(open(args['users'], "r"))
    
    revert_cutoff = int(args['--revert-cutoff'])
    revert_radius = int(args['--revert-radius'])
    
    if args['--user'] == "<getpass.getuser()>":
        dbuser = getpass.getuser()
    else:
        dbuser = args['--user']
    
    host = args['--host']
    defaults_file = args['--defaults-file']
    
    
    run(users, revert_cutoff, revert_radius, dbuser, host, defaults_file)

def run(users, revert_cutoff, revert_radius, dbuser, host, defaults_file):
    
    output = tsv.Writer(sys.stdout, headers=HEADERS)
    
    for wiki, users in groupby(users, lambda u:u.wiki):
        db = database.DB(connection(wiki, host, dbuser, defaults_file))
        
        for user in users:
            sys.stderr.write("{0}, {1}: ".format(wiki, user.user_id))
            
            day_revisions = 0
            day_deleted_revisions = 0
            day_main_revisions = 0
            day_deleted_main_revisions = 0
            day_reverted_main_revisions = 0
            day_productive_edits = 0
            week_revisions = 0
            week_deleted_revisions = 0
            week_main_revisions = 0
            week_deleted_main_revisions = 0
            week_reverted_main_revisions = 0
            week_productive_edits = 0
            week_sessions = 0
            week_session_seconds = 0
            
            registration = Timestamp(user.user_registration)
            end_of_life = registration + 60*60*24*7 # One week after reg.
            
            user_revisions = db.all_revisions.query(
                user_id=user.user_id,
                direction="newer",
                before=end_of_life,
                include_page=True
            )
            
            user_events = chain(
                [
                    (
                        user.user_id,
                        registration,
                        ('registration', registration, None)
                    )
                ],
                (
                    (
                        rev['rev_user'],
                        rev['rev_timestamp'],
                        ('revision', Timestamp(rev['rev_timestamp']), rev)
                    )
                    for rev in user_revisions
                )
            )
            
            for _, events in sessions.sessions(user_events):
                
                for event_type, timestamp, payload in events:
                    
                    if event_type == "revision":
                        rev = payload
                        day = Timestamp(rev['rev_timestamp']) - registration <= 60*60*24 # one day
                        
                        week_revisions += 1
                        day_revisions += day
                        
                        week_deleted_revisions += rev['archived']
                        day_deleted_revisions += rev['archived'] * day
                        
                        if rev['page_namespace'] == 0:
                            week_main_revisions += 1
                            day_main_revisions += day
                            
                            rev_timestamp = Timestamp(rev['rev_timestamp'])
                            cutoff_timestamp = Timestamp(int(rev_timestamp) + revert_cutoff)
                            
                            if rev['archived']:
                                week_deleted_main_revisions += 1
                                day_deleted_main_revisions += day
                                sys.stderr.write("a")
                            else:
                                revert = reverts.database.check(
                                    db, rev_id=rev['rev_id'],
                                    page_id=rev['page_id'],
                                    radius=revert_radius,
                                    before=int(Timestamp(rev['rev_timestamp'])) + revert_cutoff
                                )
                                
                                if revert != None: # Reverted edit!
                                    week_reverted_main_revisions += 1
                                    day_reverted_main_revisions += day
                                    sys.stderr.write("r")
                                else:
                                    day_productive_edits += day
                                    week_productive_edits += 1
                                    sys.stderr.write(".")
                        else:
                            sys.stderr.write("_")
                    
                
                week_sessions += 1
                week_session_seconds += events[-1][1] - events[0][1]
                
                
            
            sys.stderr.write("\n")
            output.write([
                wiki,
                user.user_id,
                day_revisions,
                day_deleted_revisions,
                day_main_revisions,
                day_deleted_main_revisions,
                day_reverted_main_revisions,
                day_productive_edits,
                week_revisions,
                week_deleted_revisions,
                week_main_revisions,
                week_deleted_main_revisions,
                week_reverted_main_revisions,
                week_productive_edits,
                week_sessions,
                week_session_seconds
            ])
