# main function ####
# remove 'idf_order' fields
RmIDFOrder = function(seed_path) {
  seed = readLines(seed_path)
  print(paste('Old IDF order count:', sum(grepl('idf_order', seed))))
  index = which(grepl('idf\\_order', seed) & !grepl('\\,$', seed))
  length(index)
  seed[index - 1] = stringr::str_sub(seed[index - 1], 0, -2)
  seed = seed[!grepl('idf\\_order', seed)]
  print(paste('New IDF order count:', sum(grepl('idf_order', seed))))
  # write the 'epJSON' file
  writeLines(seed, seed_path)
  print(seed_path)
}