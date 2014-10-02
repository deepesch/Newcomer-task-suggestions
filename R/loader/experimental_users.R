source("util.R")
source("env.R")

load_experimental_users = tsv_loader(
    paste(DATA_DIR, "experimental_user.tsv", sep="/"),
    "EXPERIMENTAL_USERS",
    function(dt){
        dt$bucket = sapply(
            dt$user_id %% 4,
            function(remainder){
                if(remainder == 0){
                    "control"
                }else if(remainder == 1){
                    "post-edit"
                }else if(remainder == 2){
                    "flyout"
                }else{
                    "both"
                }
            }
        )
        dt
    }
)
