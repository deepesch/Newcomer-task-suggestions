source("loader/experimental_users.R")
source("loader/experimental_user_stats.R")


users = load_experimental_users(reload=T)
stats = load_experimental_user_stats(reload=T)

user_stats = merge(users, stats, by=c("wiki", "user_id"))

bucket_stats = user_stats[,
    list(
        n = length(user_id),
        day_productive.k = sum(day_productive_edits > 0),
        day_second_productive.k = sum(day_productive_edits > 1),
        day_editing.k = sum(day_revisions > 0),
        day_activated.k = sum(day_revisions >= 5),
        day_main_editing.k = sum(day_main_revisions > 0),
        day_revisions.geo.mean = geo.mean.plus.one(day_revisions),
        day_revisions.geo.se.lower = geo.se.lower.plus.one(day_revisions),
        day_revisions.geo.se.upper = geo.se.upper.plus.one(day_revisions),
        day_main_revisions.geo.mean = geo.mean.plus.one(day_main_revisions),
        day_main_revisions.geo.se.lower =
                geo.se.lower.plus.one(day_main_revisions),
        day_main_revisions.geo.se.upper =
                geo.se.upper.plus.one(day_main_revisions),
        day_productive_revisions.geo.mean =
                geo.mean.plus.one(day_productive_edits),
        day_productive_revisions.geo.se.lower =
                 geo.se.lower.plus.one(day_productive_edits),
        day_productive_revisions.geo.se.upper =
                geo.se.upper.plus.one(day_productive_edits),
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

bucket_stats$day_productive.prop = with(bucket_stats,
    day_productive.k/n
)
bucket_stats$day_productive.se = with(bucket_stats,
    sqrt(day_productive.prop*(1-day_productive.prop)/n)
)

bucket_stats$day_second_productive.prop = with(bucket_stats,
    day_productive.k/n
)
bucket_stats$day_second_productive.se = with(bucket_stats,
    sqrt(day_second_productive.prop*(1-day_second_productive.prop)/n)
)

bucket_stats$day_editing.prop = with(bucket_stats,
    day_editing.k/n
)
bucket_stats$day_editing.se = with(bucket_stats,
    sqrt(day_editing.prop*(1-day_editing.prop)/n)
)

bucket_stats$day_activated.prop = with(bucket_stats,
    day_activated.k/n
)
bucket_stats$day_activated.se = with(bucket_stats,
    sqrt(day_activated.prop*(1-day_activated.prop)/n)
)

bucket_stats$day_main_editing.prop = with(bucket_stats,
    day_main_editing.k/n
)
bucket_stats$day_main_editing.se = with(bucket_stats,
    sqrt(day_main_editing.prop*(1-day_main_editing.prop)/n)
)

svg("productivity/plots/day_productive.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    bucket_stats,
    aes(
        x=bucket,
        y=day_productive.prop
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=day_productive.prop+day_productive.se,
        ymin=day_productive.prop-day_productive.se
    )
) +
theme_bw() +
scale_y_continuous("Proportion of productive editors")+
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

svg("productivity/plots/day_second_productive.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    bucket_stats,
    aes(
        x=bucket,
        y=day_second_productive.prop
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=day_second_productive.prop+day_second_productive.se,
        ymin=day_second_productive.prop-day_second_productive.se
    )
) +
theme_bw() +
scale_y_continuous("Proportion of 2-edit productive editors") +
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

svg("productivity/plots/day_activated.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    bucket_stats,
    aes(
        x=bucket,
        y=day_activated.prop
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=day_activated.prop+day_activated.se,
        ymin=day_activated.prop-day_activated.se
    )
) +
theme_bw() +
scale_y_continuous("Proportion activated (5+ 24h) editors")+
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

svg("productivity/plots/day_main_revisions.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    bucket_stats,
    aes(
        x=bucket,
        y=day_main_revisions.geo.mean
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=day_main_revisions.geo.se.upper,
        ymin=day_main_revisions.geo.se.lower
    )
) +
theme_bw() +
scale_y_continuous("Geometric mean article edits in 24h")+
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

svg("productivity/plots/day_productive_revisions.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    bucket_stats,
    aes(
        x=bucket,
        y=day_productive_revisions.geo.mean
    )
) +
facet_wrap(~ wiki, nrow = 2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=day_productive_revisions.geo.se.upper,
        ymin=day_productive_revisions.geo.se.lower
    )
) +
theme_bw() +
scale_y_continuous("Geometric mean productive edits in 24h") +
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()
