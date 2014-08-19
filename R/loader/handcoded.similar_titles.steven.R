source("util.R")
source("env.R")

load_handcoded.similar_titles.steven = tsv_loader(
    paste(DATA_DIR, "handcoded.similar_titles.steven.tsv", sep="/"),
    "HANDCODED.SIMILAR_TITLES.STEVEN"
)
