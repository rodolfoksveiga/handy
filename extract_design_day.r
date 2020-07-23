# load libraries ####
pkgs = c('dplyr', 'parallel', 'stringr')
lapply(pkgs, library, character.only = TRUE)

# base functions ####
IsolateDDs = function(start, end, str) str[start:end]
ListDDs = function(dd_str) {
  dd = as.list(dd_str[-1])
  names(dd) = dd %>% str_to_lower() %>% str_extract('(?<=- ).*') %>%
    str_remove(' \\{.*') %>% str_replace_all('[ -]', '_')
  names(dd)[grepl('(dewpoint|wetbulb)_at_maximum_dry_bulb', names(dd))] =
                     'wetbulb_or_dewpoint_at_maximum_dry_bulb'
  names(dd)[names(dd) == 'rain'] = 'rain_indicator'
  names(dd)[names(dd) == 'snow_on_ground'] = 'snow_indicator'
  names(dd)[names(dd) == 'clearness'] = 'sky_clearness'
  names(dd) = ifelse(grepl('ashrae', names(dd)), str_remove(names(dd), '\\(tau.\\)'), names(dd))
  names(dd) = str_replace(names(dd), 'savings', 'saving')
  dd = lapply(dd, RepairValue)
  hct = dd[['humidity_condition_type']]
  dd['humidity_condition_type'] = ifelse(hct == 'Dewpoint', 'DewPoint',
                                         ifelse(hct == 'Wetbulb', 'WetBulb', hct))
  dd[c('idf_max_extensible_fields', 'idf_max_fields')] = c(0, 26)
  return(dd)
}
NameDDs = function(dd_str) {
  pattern = c('Ann', 'January', 'February', 'March', 'April', 'May', 'June',
              'July', 'August', 'September', 'October', 'November', 'December')
  pattern = str_flatten(pattern, '|')
  dd_str = dd_str[1] %>% str_remove('^\\s*') %>% str_remove(paste0('.*(?=(', pattern, '))'))
  return(dd_str)
}
RepairValue = function(val) {
  val = val %>% str_extract('(?<= ).+?[,;]') %>% str_remove('[,;]') %>%
    str_remove('^ *')
  val = ifelse(grepl('\\d', val), as.numeric(val), val)
  return(val)
}

# main function ####
ExtractDDs = function(ddy_path) {
  ddy = readLines(ddy_path)
  starts = grep(' SizingPeriod:DesignDay,', ddy)
  ends = which(ddy == ' ')
  new_ends = c()
  for (start in starts) {
    end = ends[which(ends > start)[1]]
    new_ends = c(new_ends, start:end)
  }
  ddy = ddy[new_ends]
  rem = c(' SizingPeriod:DesignDay,',
          '           ,      !- Dry-Bulb Temperature Range Modifier Day Schedule Name',
          '           ,      !- Humidity Indicating Day Schedule Name',
          '           ,      !- Wetbulb or Dewpoint at Maximum Dry-Bulb',
          '           ,      !- Humidity Ratio at Maximum Dry-Bulb {kgWater/kgDryAir}',
          '           ,      !- Enthalpy at Maximum Dry-Bulb {J/kg}',
          '           ,      !- Daily Wet-Bulb Temperature Range {deltaC}',
          '           ,      !- ASHRAE Clear Sky Optical Depth for Beam Irradiance (taub)',
          '           ,      !- ASHRAE Clear Sky Optical Depth for Diffuse Irradiance (taud)',
          '           ,      !- Beam Solar Day Schedule Name',
          '           ,      !- Diffuse Solar Day Schedule Name')
  rem = !ddy %in% rem
  ddy = ddy[rem]
  ddy = ddy %>% str_remove(',     !- Name$| \\[N/A\\]')
  ends = which(ddy == ' ')
  starts = c(0, ends[-length(ends)]) + 1
  ends = ends - 1
  dd_list = mapply(IsolateDDs, starts, ends, MoreArgs = list(ddy), SIMPLIFY = FALSE)
  tags = sapply(dd_list, NameDDs)
  dd_list = lapply(dd_list, ListDDs)
  names(dd_list) = tags
  return(dd_list)
}
GenDDList = function(input_dir, output_dir, cores_left) {
  ddy_lists = input_dir %>% dir('\\.ddy', full.names = TRUE) %>%
    mclapply(ExtractDDs, mc.cores = detectCores() - cores_left)
  names(ddy_lists) = input_dir %>% dir('\\.ddy') %>% str_remove('\\.ddy')
  save(ddy_lists, file = paste0(output_dir, 'ddy_lists.rds'))
}

# application ####
GenDDList(input_dir = '~/rolante/weather/', output_dir = '~/Desktop/', cores_left = 1)
