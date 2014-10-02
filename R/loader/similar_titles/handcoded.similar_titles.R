source("loader/handcoded.similar_titles.aaron.R")
source("loader/handcoded.similar_titles.maryana.R")
source("loader/handcoded.similar_titles.steven.R")

load_handcoded.similar_titles = data_loader(
    function(reload=F, verbose=T){
        aaron = load_handcoded.similar_titles.aaron(reload=reload)
        aaron$coder = "aaron"
        maryana = load_handcoded.similar_titles.maryana(reload=reload)
        maryana$coder = "maryana"
        steven = load_handcoded.similar_titles.steven(reload=reload)
        steven$coder = "steven"
        
        rbind(aaron, maryana, steven)
    },
    "HANDCODED.SIMILAR_TITLES",
    function(dt){
        dt$title_similar = dt[["Title..0.1."]]
        dt[["Title..0.1."]] = NULL
        
        dt$text_similar = dt[["Text..0.1."]]
        dt[["Text..0.1."]] = NULL
        
        dt$input_title = dt[["Input.title"]]
        dt[["Input.title"]] = NULL
        
        dt$similar_title = dt[["Similar.title"]]
        dt[["Similar.title"]] = NULL
        
        dt
    }
)
