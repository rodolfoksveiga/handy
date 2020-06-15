# useful functions ####
# convert the 'Date/Time' simlation column (character) to POSIXct
#obs.: the scales in ggplot2 can be solved as follows:
  # scale_x_datetime(date_breaks = '1 hour', date_labels = '%d/%m, %H:%M')
ConvDateTime = function(vector, ts_hora, days = 365, year = 2020) {
  min_ts = 60/ts_hora
  date_time_vector = seq(ISOdate(year, 1, 1, 0, min_ts, 0),
                         by = paste0(as.character(min_ts), ' min'),
                         length.out = days*24*4, tz = '')
}
# define interval of timesteps for each month
DefMonthTS = function(timestep) {
  # timestep: number of timesteps per hour in the simulation
  days_month = c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  days_month = cumsum(days_month)
  ts_day = 24*timestep
  ts_month = days_month*ts_day
  start = c(1, ts_month[1:11] + 1)
  end = ts_month
  year = mapply(function(x, y) list(x:y), start, end)
  names(year) = c('jan', 'feb', 'mar', 'apr', 'may', 'jun',
                  'jul', 'ago', 'sep', 'oct', 'nov', 'dec')
  return(year)
}
# extract string in between other two patterns
ExtrStrBetween = function(string, pattern, after, before) {
  # string: 
  # pattern: 
  # after: 
  # before: 
  string = str_extract(string, paste0('(?<=', before, ')', pattern,
                                      '(?=', after, ')'))
  return(string)
}