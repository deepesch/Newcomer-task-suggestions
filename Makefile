
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

datasets/experimental_user.tsv: sql/experimental_user.sql
	./query_wikis --query=sql/experimental_user.sql \
		datasets/deployed_wikis.tsv > \
	datasets/experimental_user.tsv

datasets/experimental_user_stats.tsv: datasets/experimental_user.tsv
	cat datasets/experimental_user.tsv | \
	./user_stats --user research > \
	datasets/experimental_user_stats.tsv
