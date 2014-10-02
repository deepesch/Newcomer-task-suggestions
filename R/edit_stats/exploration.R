source("loader/experimental_users.R")
source("loader/experimental_user_revisions.R")

users = load_experimental_users(reload=T)
revisions = load_experimental_user_revisions(reload=T)

merged_revisions = merge(users, revisions, by=c("wiki", "user_id"))

sample.or_na = function(x, samples){
        if(length(x) == 0){
                NA
        }else{
            sample(x, samples)
        }
}

sampled_rev_ids = merged_revisions[,
    list(
        rev_id = sample.or_na(rev_id, 1)
    ),
    list(wiki, user_id)
]

main_sampled_rev_ids = merged_revisions[page_namespace == 0,
    list(
        rev_id = sample.or_na(rev_id, 1)
    ),
    list(wiki, user_id)
]

sampled_revisions = merge(merged_revisions, sampled_rev_ids,
        by=c("wiki", "user_id", "rev_id"))
        
main_sampled_revisions = merge(merged_revisions, main_sampled_rev_ids,
        by=c("wiki", "user_id", "rev_id"))
        

sample_stats = sampled_revisions[,
    list(
        n = length(rev_id),
        mainspace.k = sum(page_namespace == 0),
        talk.k = sum(page_namespace %% 2 == 1)
    ),
    list(wiki, bucket)
]
sample_stats$mainspace.prop = with(
    sample_stats,
    mainspace.k/n
)
sample_stats$mainspace.se = with(
    sample_stats,
    sqrt(mainspace.prop*(1-mainspace.prop)/n)
)
sample_stats$talk.prop = with(
    sample_stats,
    talk.k/n
)
sample_stats$talk.se = with(
    sample_stats,
    sqrt(talk.prop*(1-talk.prop)/n)
)






svg("edit_stats/plots/talk.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    sample_stats,
    aes(
        x=bucket,
        y=talk.prop
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=talk.prop+talk.se,
        ymin=talk.prop-talk.se
    )
) +
theme_bw() +
scale_y_continuous("(sampled) Proportion of talk edits") +
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

svg("edit_stats/plots/mainspace.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    sample_stats,
    aes(
        x=bucket,
        y=mainspace.prop
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=mainspace.prop+mainspace.se,
        ymin=mainspace.prop-mainspace.se
    )
) +
theme_bw() +
scale_y_continuous("(sampled) Proportion of article edits") +
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

main_sample_stats = main_sampled_revisions[,
    list(
        n = length(rev_id),
        section_comment.k = sum(section_comment),
        bytes_changed.geo.mean = geo.mean.plus.one(abs(bytes_changed)),
        bytes_changed.geo.se.upper = geo.se.upper.plus.one(abs(bytes_changed)),
        bytes_changed.geo.se.lower = geo.se.lower.plus.one(abs(bytes_changed)),
        previous_bytes.geo.mean = geo.mean.plus.one(abs(previous_bytes)),
        previous_bytes.geo.se.upper =
                geo.se.upper.plus.one(abs(previous_bytes)),
        previous_bytes.geo.se.lower =
                geo.se.lower.plus.one(abs(previous_bytes))
    ),
    list(wiki, bucket)
]
main_sample_stats$section_comment.prop = with(
    main_sample_stats,
    section_comment.k/n
)
main_sample_stats$section_comment.se = with(
    main_sample_stats,
    sqrt(section_comment.prop*(1-section_comment.prop)/n)
)

svg("edit_stats/plots/section_comment.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    main_sample_stats,
    aes(
        x=bucket,
        y=section_comment.prop
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=section_comment.prop+section_comment.se,
        ymin=section_comment.prop-section_comment.se
    )
) +
theme_bw() +
scale_y_continuous("(sampled) Proportion of section edits") +
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

svg("edit_stats/plots/previous_bytes.density.by_bucket.svg",
    height=5,
    width=7)
ggplot(
    main_sampled_revisions,
    aes(x=previous_bytes+1, fill=bucket)
) +
facet_wrap(~ wiki) +
geom_density(alpha=0.5) +
scale_x_log10("(sampled) Previous bytes") +
theme_bw()
dev.off()

svg("edit_stats/plots/previous_bytes.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    main_sample_stats,
    aes(
        x=bucket,
        y=previous_bytes.geo.mean
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=previous_bytes.geo.se.upper,
        ymin=previous_bytes.geo.se.lower
    )
) +
theme_bw() +
scale_y_continuous("Geometric mean length of article edited")+
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

svg("edit_stats/plots/bytes_changed.density.by_bucket.svg",
    height=5,
    width=7)
ggplot(
    main_sampled_revisions,
    aes(x=abs(bytes_changed)+1, fill=bucket)
) +
facet_wrap(~ wiki) +
geom_density(alpha=0.5) +
scale_x_log10("(sampled) Absolute bytes changed") +
theme_bw()
dev.off()

svg("edit_stats/plots/bytes_changed.by_bucket.by_wiki.svg",
    height=5,
    width=7)
ggplot(
    main_sample_stats,
    aes(
        x=bucket,
        y=bytes_changed.geo.mean
    )
) +
facet_wrap(~ wiki, nrow=2) +
geom_point() +
geom_errorbar(
    aes(
        ymax=bytes_changed.geo.se.upper,
        ymin=bytes_changed.geo.se.lower
    )
) +
theme_bw() +
scale_y_continuous("Geometric mean article bytes changed")+
theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()
