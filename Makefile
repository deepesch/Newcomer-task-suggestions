
dbstore = --defaults-file=~/.my.research.cnf -u research -h analytics-store.eqiad.wmnet

datasets/sampled_returns.tsv: sql/sampled_returns.sql
	cat sql/sampled_returns.sql | \
	mysql $(dbstore) log > \
	datasets/sampled_returns.tsv

datasets/sampled_similar_titles.tsv: datasets/sampled_returns.tsv \
                                     ts/get_similar_titles.py
	cat datasets/sampled_returns.tsv | \
	./get_similar_titles 50 > \
	datasets/sampled_similar_titles.tsv
