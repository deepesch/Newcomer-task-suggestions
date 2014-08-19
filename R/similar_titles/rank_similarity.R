source("loader/handcoded.similar_titles.R")
source("loader/subsampled_similar_titles.R")

handcoded = load_handcoded.similar_titles(reload=T)
similar_titles = load_subsampled_similar_titles(reload=T)

titles.rank = similar_titles[,list(input_title, similar_title, rank)]

handcoded.ranked = merge(
    handcoded,
    titles.rank,
    by=c("input_title", "similar_title")
)

coder.rank_bucket = handcoded.ranked[,
    list(
        n = length(title_similar),
        title_similar.k = sum(title_similar> 0),
        text_similar.k = sum(text_similar>0)
    ),
    list(coder, rank_bucket=floor(rank/5)*5)
]
coder.rank_bucket$title_similar.prop = with(
    coder.rank_bucket,
    title_similar.k/n
)
coder.rank_bucket$title_similar.se = with(
    coder.rank_bucket,
    sqrt(title_similar.prop*(1-title_similar.prop)/n)
)
coder.rank_bucket$text_similar.prop = with(
    coder.rank_bucket,
    text_similar.k/n
)
coder.rank_bucket$text_similar.se = with(
    coder.rank_bucket,
    sqrt(text_similar.prop*(1-text_similar.prop)/n)
)

svg("similar_titles/plots/similarity.by_type.by_rank_bucket.svg",
    height=5, width=9)
ggplot(
    rbind(
        coder.rank_bucket[,
            list(
                coder,
                rank_bucket,
                similarity_type="title",
                prop=title_similar.prop,
                se=title_similar.se
            )
        ],
        coder.rank_bucket[,
            list(
                coder,
                rank_bucket,
                similarity_type="text",
                prop=text_similar.prop,
                se=text_similar.se
            )
        ]
    ),
    aes(
        x = rank_bucket,
        y = prop,
        color = similarity_type
    )
) +
facet_wrap(~ coder, nrow=1) +
geom_line() +
geom_errorbar(aes(ymax=prop+se, ymin=prop-se)) +
theme_bw() +
scale_x_continuous("Rank bucket") +
scale_y_continuous("Similar proportion")
dev.off()

summary(handcoded.ranked[rank<= 3,]$text_similar > 0)
