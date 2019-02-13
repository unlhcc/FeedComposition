#!/usr/bin/env python

import pandas as pd
import os
import os.path

from common import *

if __name__ == '__main__':
    
    args = parseOptions(procedure='a')
    input_files = verifyInput(args.input_file_list,procedure='a')
    lab = args.lab
    
    for data_file in input_files:
        print "Processing file '%s'..." % (data_file)

        # Create the output filename based on the input filename and suffix        
        basename = os.path.splitext(os.path.split(data_file)[1])[0]
        output_excel = basename + OUTPUT_FILE_SUFFIX
        
        # Read in raw data, setting anything with a 0 value to missing
        raw_data = pd.read_excel(data_file,parse_cols=COLUMNS_TO_PARSE[lab],na_values=MISSING_VALUES[lab])
        # The column labels in Excel have trailing spaces, so strip all whitespace
        raw_data.rename(columns=lambda x: x.strip(),inplace=True)
        
        # Standardize per lab
        raw_data = STANDARDIZE_BY_LAB[lab](raw_data)

        # Create the output Excel file writer object
        writer = pd.ExcelWriter(os.path.join(args.outputdir,output_excel))
        
        # Get the underlying Xlsxwriter book object to use for formatting cells and inserting plots
        workbook = writer.book

        # Write initial raw data summary to spreadsheet
        raw_data_summary = raw_data.describe(percentiles=[0.10,0.90])
        raw_data_summary.rename(index={'count': 'N'},inplace=True)
        raw_data_summary.transpose().to_excel(writer,sheet_name=SHEET_NAMES['raw_summary'])
        worksheet = writer.sheets[SHEET_NAMES['raw_summary']]
        worksheet.set_column('A:A',15)
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('C:I',None,cell_format)

        # Perform error-correction and write to spreadsheet
        ec_data = raw_data
        # Set any negative values to missing
        ec_data = ec_data.applymap(dropNegatives)
        # Set any percentage value over 100 to missing
        for column in PERCENTAGE_COLUMNS[lab]:
            ec_data[column] = ec_data[column].map(filterPercentages)
        ec_data_summary = ec_data.describe(percentiles=[0.10,0.90])
        ec_data_summary.rename(index={'count': 'N'},inplace=True)
        ec_data_summary.transpose().to_excel(writer,sheet_name=SHEET_NAMES['ec_summary'])
        worksheet = writer.sheets[SHEET_NAMES['ec_summary']]
        worksheet.set_column('A:A',15)
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('C:I',None,cell_format)


        # Calcuate cutoffs and write to spreadsheet
        cutoffs = findCutoffs(ec_data_summary,CUTOFF_FACTOR,CUTOFF_INDEXES)
        cutoffs.transpose().to_excel(writer,sheet_name=SHEET_NAMES['cutoffs'])
        worksheet = writer.sheets[SHEET_NAMES['cutoffs']]
        worksheet.set_column('A:A',15)
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('B:D',20,cell_format)
                     
        # Calculate EC data Pearson stats and write to spreadsheet
        pearson_stats_ec = ec_data.corr(method='pearson')
        pearson_stats_ec.to_excel(writer,sheet_name=SHEET_NAMES['ec_pearson'])
        worksheet = writer.sheets[SHEET_NAMES['ec_pearson']]
        worksheet.set_column('A:A',15)
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('B:AE',None,cell_format)
        
        # Generate EC data histogram and probability density plots for specified nutrients
        dm_plot_ec = generatePlot(ec_data,'DM',basename)
        cp_plot_ec = generatePlot(ec_data,'CP',basename)
        ash_plot_ec = generatePlot(ec_data,'Ash',basename)
        starch_plot_ec = generatePlot(ec_data,'Starch',basename)
        fat_plot_ec = generatePlot(ec_data,'Fat',basename)
        ndf_plot_ec = generatePlot(ec_data,'NDF',basename)
        adf_plot_ec = generatePlot(ec_data,'ADF',basename)
        lignin_plot_ec = generatePlot(ec_data,'Lignin',basename)


        # The Pandas dataframe writer doesn't provide a wrapper function for 
        # inserting image files.  Instead, get the underlying Xlswriter object and
        # use its insert_image function directly.
        worksheet = workbook.add_worksheet(SHEET_NAMES['ec_plots'])
        if dm_plot_ec:
            worksheet.insert_image('A1',dm_plot_ec)
        if cp_plot_ec:
            worksheet.insert_image('M1',cp_plot_ec)
        if ash_plot_ec:
            worksheet.insert_image('A30',ash_plot_ec)
        if starch_plot_ec:
            worksheet.insert_image('M30',starch_plot_ec)
        if fat_plot_ec:
            worksheet.insert_image('A59',fat_plot_ec)
        if ndf_plot_ec:
            worksheet.insert_image('M59',ndf_plot_ec)
        if adf_plot_ec:
            worksheet.insert_image('A89',adf_plot_ec)
        if lignin_plot_ec:
            worksheet.insert_image('M89',lignin_plot_ec)

        # Create filtered data set based on cutoffs 
        filtered_data = pd.DataFrame()       
        for nutrient in ec_data.columns:
            try:
                filtered_data[nutrient] = ec_data[nutrient].apply(filterByCutoff,\
                low_cutoff=cutoffs[nutrient][CUTOFF_INDEXES['low']],high_cutoff=cutoffs[nutrient][CUTOFF_INDEXES['high']] )
            except KeyError:
                pass

        filtered_data_summary = filtered_data.describe(percentiles=[0.10,0.90])
        filtered_data_summary.rename(index={'count': 'N'},inplace=True)
        filtered_data_summary.transpose().to_excel(writer,sheet_name=SHEET_NAMES['filtered_summary'])
        worksheet = writer.sheets[SHEET_NAMES['filtered_summary']]
        worksheet.set_column('A:A',15)
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('C:I',None,cell_format)
        
        # Calculate filtered data Pearson stats and write to spreadsheet
        pearson_stats_filtered = filtered_data.corr(method="pearson")
        pearson_stats_filtered.transpose().to_excel(writer,sheet_name=SHEET_NAMES['filtered_pearson'])
        worksheet = writer.sheets[SHEET_NAMES['filtered_pearson']]
        worksheet.set_column('A:A',15)
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('B:AE',None,cell_format)

        # Generate filtered data histogram and probability density plots for specified nutrients
        dm_plot_filtered = generatePlot(filtered_data,'DM',basename)
        cp_plot_filtered = generatePlot(filtered_data,'CP',basename)
        ash_plot_filtered = generatePlot(filtered_data,'Ash',basename)
        starch_plot_filtered = generatePlot(filtered_data,'Starch',basename)
        fat_plot_filtered = generatePlot(filtered_data,'Fat',basename)
        ndf_plot_filtered = generatePlot(filtered_data,'NDF',basename)
        adf_plot_filtered = generatePlot(filtered_data,'ADF',basename)
        lignin_plot_filtered = generatePlot(filtered_data,'Lignin',basename)

        # Insert filtered data plots into spreadsheet
        worksheet = workbook.add_worksheet(SHEET_NAMES['filtered_plots'])
        if dm_plot_filtered:
            worksheet.insert_image('A1',dm_plot_filtered)
        if cp_plot_filtered:
            worksheet.insert_image('M1',cp_plot_filtered)
        if ash_plot_filtered:
            worksheet.insert_image('A30',ash_plot_filtered)
        if starch_plot_filtered:
            worksheet.insert_image('M30',starch_plot_filtered)
        if fat_plot_filtered:
            worksheet.insert_image('A59',fat_plot_filtered)
        if ndf_plot_filtered:
            worksheet.insert_image('M59',ndf_plot_filtered)
        if adf_plot_filtered:
            worksheet.insert_image('A89',adf_plot_filtered)
        if lignin_plot_filtered:
            worksheet.insert_image('M89',lignin_plot_filtered)

        # Calculate changes between raw and filtered data and write to spreadsheet
        changes = findChanges(raw_data_summary,filtered_data_summary,CHANGES_INDEXES)            
        changes.transpose().to_excel(writer,sheet_name=SHEET_NAMES['changes'])
        worksheet = writer.sheets[SHEET_NAMES['changes']]
        worksheet.set_column('A:A',15)
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('C:G',15,cell_format)
        
        workbook.close()
        writer.close()
