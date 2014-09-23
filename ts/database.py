import getpass
import os

import pymysql
import pymysql.cursors


def connection(wiki,
               host="analytics-store.eqiad.wmnet",
               user = getpass.getuser(),
               defaults_file = os.path.expanduser("~/.my.cnf")):
    
    return pymysql.connect(
        host=host,
        database=wiki,
        user=user,
        read_default_file=defaults_file#,
        #cursorclass=pymysql.cursors.DictCursor
    )
