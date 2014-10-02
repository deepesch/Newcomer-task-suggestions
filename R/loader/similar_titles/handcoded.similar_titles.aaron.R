source("util.R")
source("env.R")

load_handcoded.similar_titles.aaron = tsv_loader(
    paste(DATA_DIR, "handcoded.similar_titles.aaron.tsv", sep="/"),
    "HANDCODED.SIMILAR_TITLES.AARON"
)
