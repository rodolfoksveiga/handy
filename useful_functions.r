# util functions ####
# convert the 'Date/Time' simlation column (character) to POSIXct
ConvDateTime = function(vector, ts_hora, days = 365, year = 2020) {
  min_ts = 60/ts_hora
  date_time_vector = seq(ISOdate(year, 1, 1, 0, min_ts, 0),
                         by = paste0(as.character(min_ts), ' min'),
                         length.out = days*24*4, tz = '')
}
# the scales in ggplot2 can be solved as follows:
  # scale_x_datetime(date_breaks = '1 hour', date_labels = '%d/%m, %H:%M')
