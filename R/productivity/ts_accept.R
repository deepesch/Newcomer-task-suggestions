## Q: At what rate do newcomers accept recommendations (click)?

source("loader/experimental_users.R");

users = load_experimental_users(reload=T);

## Util function to resolve a filename relative to dataset directory
resolve_dd = function(filename) {
   paste(DATA_DIR, '/', filename, sep='');
}

user_recommendation_stats = data.table(read.table(
			    resolve_dd('user_recommendation_stats.tsv'),
			    fileEncoding='UTF-8', header=TRUE, sep='\t'));

user_edit_stats = data.table(read.table(
	  resolve_dd('user_edit_stats.tsv'),
	  fileEncoding='UTF-8', header=TRUE, sep='\t'));

## FIXME: look for "set ID" in the recommendations, that will allows us
## to identify multiple recommendations as a single set.
##
## FIXME: proportions: out of users who saw at least one recomendation,
#   what proportion accepted at least one?
##  Similarly, out of users who accepted at least one,
##  what proportion edited at least one?

user_stats = merge(users, user_recommendation_stats, by=c('wiki', 'user_id'));
user_edit_stats = merge(user_stats, user_edit_stats, by=c('wiki', 'user_id'));

user_stats[, recommendations_click_prop := 0];
user_stats[recommendations_seen > 0,
    recommendations_click_prop := recommendations_accepted / recommendations_seen];

click_proportions = user_stats[,list(
        n = length(user_id),
        mean_click.prop=mean(recommendations_click_prop)
    ),
    by=list(wiki, bucket)
];
click_proportions$mean_click.se = with(click_proportions,
    sqrt(mean_click.prop*(1-mean_click.prop)/n)
);

edit_stats = user_edit_stats[,
    list(
        n = length(user_id),
	edit.k = sum(accepted_edits > 0),
	edit.geo.mean = geo.mean.plus.one(accepted_edits),
	edit.geo.se.lower = geo.se.lower.plus.one(accepted_edits),
	edit.geo.se.upper = geo.se.upper.plus.one(accepted_edits)
    ),
    by=list(wiki, bucket)
];
edit_stats$edit.prop = with(edit_stats,
    edit.k/n
);
edit_stats$edit.se = with(edit_stats,
    sqrt(edit.prop*(1-edit.prop)/n)
);

svg("productivity/plots/rec_click_proportion.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    click_proportions,
    aes(
        x=bucket,
        y=mean_click.prop
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=mean_click.prop+mean_click.se,
        ymin=mean_click.prop-mean_click.se
    )
) +
theme_bw() +
scale_y_continuous("Proportion of clicked task recommendations")+
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

svg("productivity/plots/edit_proportion.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    edit_stats,
    aes(
        x=bucket,
        y=edit.prop
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=edit.prop+edit.se,
        ymin=edit.prop-edit.se
    )
) +
theme_bw() +
scale_y_continuous("Proportion of edited task recommendations")+
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()


svg("productivity/plots/edits.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    edit_stats,
    aes(
        x=bucket,
        y=edit.geo.mean
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=edit.geo.se.upper,
        ymin=edit.geo.se.lower
    )
) +
theme_bw() +
scale_y_continuous("Geometric mean task recommendation edits in 7 days")+
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()
