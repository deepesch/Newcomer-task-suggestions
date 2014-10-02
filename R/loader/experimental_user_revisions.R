source("util.R")
source("env.R")

load_experimental_user_revisions = tsv_loader(
    paste(DATA_DIR, "experimental_user_revision.tsv", sep="/"),
    "EXPERIMENTAL_USER_REVISION"
)
