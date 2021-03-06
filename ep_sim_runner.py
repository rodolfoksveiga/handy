import os
import glob
import numpy as np
import pandas as pd

# epjson_sim_runner()
	# the function run simulations with energyplus using 'epjson' files
def epjson_sim_runner(epjson_dir, pattern, output_dir, epw_dir, weather_names):
	# epjson_dir - the directory path where the 'epjson' files are (you can put as many files as you
		# wish)
	# output_dir - the directory path where the outputs from the simulations will be
		# in the output directory will be only the errors (compiled in one file ('errors.txt')) and
			# the main 'csvs' files
		# the name of the output will have the following structure: name of the weather and the name
			# of the 'epjson' file (e.g. 'rio_de_janeiro_apto_oeste.csv')
	# epw_dir - the directory path where the 'epw' files are (you can put as many files as you wish)
	# weather_names - the names of the weathers (in alphabetic order and using underlines as spaces)
		# to be simulated (they must be in a numpy array)
		
	epjson_files = glob.glob(epjson_dir + '*' + pattern + '*.epJSON')
	list.sort(epjson_files)
	
	epjson_names = map(str,np.empty([len(epjson_files)]))
	for count,value in enumerate(epjson_files):
		epjson_names[count] = value
		epjson_names[count] = epjson_names[count].replace(epjson_dir, '')[:-7]

	epw_files = glob.glob(epw_dir + '*.epw')
	list.sort(epw_files)

	# run simulations
	sim_count = 0
	for count_1, value_1 in enumerate(epjson_files):
		for count_2, value_2 in enumerate(epw_files):
			sim_count += 1
			print '\nSimulation count: ', sim_count
			print 'Model file: ' + epjson_names[count_1] + '.epJSON'
			print 'Weather file: ' + value_2.replace(epw_dir, '')
			os.system('energyplus -r -w ' + value_2 + ' -d ' + output_dir + ' -p ' +
					  weather_names[count_2] + '_' + epjson_names[count_1] + '_ ' + value_1)

	# remove unuseful files from simulations
	os.system('rm ' + output_dir + '*tbl.csv ' + output_dir + '*.rvaudit ' + output_dir +
			  '*.audit ' + output_dir + '*.bnd ' + output_dir + '*.dxf ' + output_dir + '*.eio ' +
			  output_dir + '*.end ' + output_dir + '*.eso ' + output_dir + '*.mdd ' + output_dir +
			  '*.mtd ' + output_dir + '*.rdd ' + output_dir + '*.edd ' + output_dir + '*.shd ' +
			  output_dir + 'sqlite.err && rm sqlite.err')

	os.system('rm ' + output_dir + pattern + '_errors.txt')
	# bundle the 'err' files
	error_files = glob.glob(output_dir + '*.err')
	for value in error_files:
		with open(value) as input_file:
			with open(output_dir + pattern + '_errors.txt', 'a') as output_file:
				output_file.write(value + '\n')
				for line in input_file:
					output_file.write(line)
				output_file.write('\n\n')

	# remove errors files from simulations
	os.system('rm ' + output_dir + '*.err')

	# rename files without "_out"
	output_files = glob.glob(output_dir + '*.csv')
	for value in output_files:
		os.system('mv ' + value + ' ' + value[:-8] + value[-4:])	
	return;


# application
