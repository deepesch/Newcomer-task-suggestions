source("loader/experimental_users.R")
source("loader/experimental_user_stats.R")


users = load_experimental_users(reload=T)
stats = load_experimental_user_stats(reload=T)

user_stats = merge(users, stats, by=c("wiki", "user_id"))

bucket_stats = user_stats[,
    list(
        n = length(user_id),
        week_productive.k = sum(week_productive_edits > 0),
        week_second_productive.k = sum(week_productive_edits > 1),
        week_editing.k = sum(week_revisions > 0),
        week_activated.k = sum(week_revisions >= 5),
        week_main_editing.k = sum(week_main_revisions > 0),
        week_revisions.geo.mean = geo.mean.plus.one(week_revisions),
        week_revisions.geo.se.lower = geo.se.lower.plus.one(week_revisions),
        week_revisions.geo.se.upper = geo.se.upper.plus.one(week_revisions),
        week_main_revisions.geo.mean = geo.mean.plus.one(week_main_revisions),
        week_main_revisions.geo.se.lower =
                geo.se.lower.plus.one(week_main_revisions),
        week_main_revisions.geo.se.upper =
                geo.se.upper.plus.one(week_main_revisions),
        week_productive_revisions.geo.mean =
                geo.mean.plus.one(week_productive_edits),
        week_productive_revisions.geo.se.lower =
                 geo.se.lower.plus.one(week_productive_edits),
        week_productive_revisions.geo.se.upper =
                geo.se.upper.plus.one(week_productive_edits)
    ),
    by=list(wiki, bucket)
]

bucket_stats$week_productive.prop = with(bucket_stats,
    week_productive.k/n
)
bucket_stats$week_productive.se = with(bucket_stats,
    sqrt(week_productive.prop*(1-week_productive.prop)/n)
)

bucket_stats$week_second_productive.prop = with(bucket_stats,
    week_productive.k/n
)
bucket_stats$week_second_productive.se = with(bucket_stats,
    sqrt(week_second_productive.prop*(1-week_second_productive.prop)/n)
)

bucket_stats$week_activated.prop = with(bucket_stats,
    week_activated.k/n
)
bucket_stats$week_activated.se = with(bucket_stats,
    sqrt(week_activated.prop*(1-week_activated.prop)/n)
)

svg("productivity/plots/week_productive.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    bucket_stats,
    aes(
        x=bucket,
        y=week_productive.prop
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=week_productive.prop+week_productive.se,
        ymin=week_productive.prop-week_productive.se
    )
) +
theme_bw() +
scale_y_continuous("Proportion of productive editors")+
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

svg("productivity/plots/week_second_productive.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    bucket_stats,
    aes(
        x=bucket,
        y=week_second_productive.prop
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=week_second_productive.prop+week_second_productive.se,
        ymin=week_second_productive.prop-week_second_productive.se
    )
) +
theme_bw() +
scale_y_continuous("Proportion of 2-edit productive editors") +
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

svg("productivity/plots/week_activated.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    bucket_stats,
    aes(
        x=bucket,
        y=week_activated.prop
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=week_activated.prop+week_activated.se,
        ymin=week_activated.prop-week_activated.se
    )
) +
theme_bw() +
scale_y_continuous("Proportion activated (5+ 24h) editors")+
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

svg("productivity/plots/week_main_revisions.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    bucket_stats,
    aes(
        x=bucket,
        y=week_main_revisions.geo.mean
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=week_main_revisions.geo.se.upper,
        ymin=week_main_revisions.geo.se.lower
    )
) +
theme_bw() +
scale_y_continuous("Geometric mean article edits in 24h")+
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

svg("productivity/plots/week_productive_revisions.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    bucket_stats,
    aes(
        x=bucket,
        y=week_productive_revisions.geo.mean
    )
) +
facet_wrap(~ wiki, nrow = 2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=week_productive_revisions.geo.se.upper,
        ymin=week_productive_revisions.geo.se.lower
    )
) +
theme_bw() +
scale_y_continuous("Geometric mean productive edits in 24h") +
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()
