source("util.R")
source("env.R")

load_experimental_user_stats = tsv_loader(
    paste(DATA_DIR, "experimental_user_stats.tsv", sep="/"),
    "EXPERIMENTAL_USER_STATS"
)
