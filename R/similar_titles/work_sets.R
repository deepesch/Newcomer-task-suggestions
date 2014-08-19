source("loader/subsampled_similar_titles.R")

overlap_n = 54
set_n = 307

similar_titles = load_subsampled_similar_titles()

shuffled_i = sample(1:nrow(similar_titles), nrow(similar_titles))

overlap_i = shuffled_i[1:overlap_n]

aaron_i = c(shuffled_i[(overlap_n+set_n*0+1):(overlap_n+set_n*1)], overlap_i)
steven_i = c(shuffled_i[(overlap_n+set_n*1+1):(overlap_n+set_n*2)], overlap_i)
maryana_i = c(shuffled_i[(overlap_n+set_n*2+1):(overlap_n+set_n*3)], overlap_i)

aaron_i = sample(aaron_i, length(aaron_i))
steven_i = sample(steven_i, length(steven_i))
maryana_i = sample(maryana_i, length(maryana_i))

write.csv(similar_titles[aaron_i,], "aaron.sample.csv")
write.csv(similar_titles[steven_i,], "steven.sample.csv")
write.csv(similar_titles[maryana_i,], "maryana.sample.csv")
