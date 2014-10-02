
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

datasets/tables/experimental_user.created: \
		sql/tables/experimental_user.create.sql
	cat sql/tables/experimental_user.create.sql | \
	mysql $(dbstore) staging > \
	datasets/tables/experimental_user.created

datasets/tables/experimental_user.loaded: \
		datasets/tables/experimental_user.created \
		datasets/experimental_user.tsv
	ln -sf experimental_user.tsv datasets/tr_experimental_user && \
	mysql $(dbstore) staging -e "TRUNCATE tr_experimental_user;" && \
	mysqlimport $(dbstore) --local \
		--ignore-lines=1 staging datasets/tr_experimental_user && \
	rm -f datasets/tr_experimental_user && \
	mysql $(dbstore) staging \
		-e "SELECT NOW(), COUNT(*) FROM tr_experimental_user" > \
	datasets/tables/experimental_user.loaded

datasets/user_recommendation_stats.tsv: sql/user_recommendation_stats.sql
	cat sql/user_recommendation_stats.sql | \
	mysql $(dbstore) log
	datasets/user_recommendation_stats.tsv

datasets/user_edit_stats.tsv: sql/user_edit_stats.sql
	./query_wikis --query=sql/user_edit_stats.sql \
		datasets/deployed_wikis.tsv > \
	datasets/user_edit_stats.tsv

datasets/experimental_user_revision.tsv: \
		datasets/tables/experimental_user.loaded \
		sql/experimental_user_revision.sql
	./query_wikis --query=sql/experimental_user_revision.sql \
		datasets/deployed_wikis.tsv > \
	datasets/experimental_user_revision.tsv

datasets/tables/experimental_user_revision.created: \
	sql/tables/experimental_user_revision.create.sql
	cat sql/tables/experimental_user_revision.create.sql | \
	mysql $(dbstore) staging > \
	datasets/tables/experimental_user_revision.created

datasets/tables/experimental_user_revision.loaded: \
		datasets/tables/experimental_user_revision.created \
		datasets/experimental_user_revision.tsv
	ln -sf experimental_user_revision.tsv \
		datasets/tr_experimental_user_revision && \
	mysql $(dbstore) staging -e "TRUNCATE tr_experimental_user_revision;" && \
	mysqlimport $(dbstore) --local \
		--ignore-lines=1 staging datasets/tr_experimental_user_revision && \
	rm -f datasets/tr_experimental_user_revision && \
	mysql $(dbstore) staging \
		-e "SELECT NOW(), COUNT(*) FROM tr_experimental_user_revision" > \
	datasets/tables/experimental_user_revision.loaded
