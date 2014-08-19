source("util.R")
source("env.R")

load_handcoded.similar_titles.maryana = tsv_loader(
    paste(DATA_DIR, "handcoded.similar_titles.maryana.tsv", sep="/"),
    "HANDCODED.SIMILAR_TITLES.MARYANA",
    function(dt){
        dt[is.na(dt[["Text..0.1."]]),][["Text..0.1."]] = 1
        
        dt
    }
)
