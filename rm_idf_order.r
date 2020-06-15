# main function ####
# remove 'idf_order'
RmIDFOrder = function(seed_path) {
  seed = readLines(seed_path)
  print(paste('Old IDF order count:', sum(grepl('idf_order', seed))))
  index = which(grepl('idf\\_order', seed) & !grepl('\\,$', seed))
  length(index)
  seed[index - 1] = stringr::str_sub(seed[index - 1], 0, -2)
  seed = seed[!grepl('idf\\_order', seed)]
  print(paste('New IDF order count:', sum(grepl('idf_order', seed))))
  # write the 'epJSON' file
  file_path = paste0(dirname(seed_path), '/no_order_', basename(seed_path))
  writeLines(seed, file_path)
  print(file_path)
}

# application
RmIDFOrder('/home/rodox/git/master_ufsc/seed/l_9.0.epJSON')
