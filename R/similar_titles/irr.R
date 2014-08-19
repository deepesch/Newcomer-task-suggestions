source("loader/handcoded.similar_titles.R")

handcoded = load_handcoded.similar_titles(reload=T)

overlap.titles = merge(
    handcoded[coder=="aaron"],
    handcoded[coder=="steven"],
    by=c("input_title", "similar_title")
)[,list(input_title, similar_title)]

overlap = merge(
    merge(
        merge(
            handcoded[
                coder=="aaron",
                list(
                    input_title,
                    similar_title,
                    title.aaron = title_similar,
                    text.aaron = text_similar
                )
            ],
            overlap.titles,
            by=c("input_title", "similar_title")
        ),
        merge(
            handcoded[
                coder=="steven",
                list(
                    input_title,
                    similar_title,
                    title.steven = title_similar,
                    text.steven = text_similar
                )
            ],
            overlap.titles,
            by=c("input_title", "similar_title")
        ),
        by=c("input_title", "similar_title")
    ),
    merge(
        handcoded[
            coder=="maryana",
            list(
                input_title,
                similar_title,
                title.maryana = title_similar,
                text.maryana = text_similar
            )
        ],
        overlap.titles,
        by=c("input_title", "similar_title")
    ),
    by=c("input_title", "similar_title")
)

library(irr)
kappam.fleiss(overlap[,list(title.aaron>0, title.maryana>0, title.steven>0)])
kappam.fleiss(overlap[,list(text.aaron>0, text.maryana>0, text.steven>0)])
