#!/usr/bin/env python

# -*- coding: utf-8 -*-
"""
Created on Thu Aug  6 16:36:04 2015

@author: acaprez
"""

import pandas as pd
import os
import os.path
import StringIO
from bs4 import BeautifulSoup as bs
import subprocess

from common import *

if __name__ == '__main__':
    
    args = parseOptions(procedure='b')
    (input_files, key_nutrients) = verifyInput(args.input_file_list,procedure='b')
    lab = args.lab
    logdir = args.logdir
    datadir = args.datadir

    for data_file, principal_components in zip(input_files,key_nutrients):
        print "Processing file '%s'..." % (data_file)
        print "\tKey nutrients are %s" % (principal_components)

        # Get the correct list of PCA variables based on the number of key nutrients
        pca_vars = PRINCOMP_LIST[len(principal_components)]

        # Create the list of vars for the standardized set by prepending 'z' to the name of
        # each principal_component
        standardized_set_vars = [ 'z%s' % x for x in principal_components]

        # Dictionary mapping the original var names to the standardized set names
        pc_to_ss_mapping = dict(zip(principal_components,standardized_set_vars))

        # Create the output filename based on the input filename and suffix        
        basename = os.path.splitext(os.path.split(data_file)[1])[0]
        output_excel = basename + OUTPUT_FILE_SUFFIX
        # Create the filename for the Excel file with the full dataset after each step
        dataout_excel = basename + DATA_FILE_SUFFIX

        # Read in raw data, setting anything with a 0 value to missing
        raw_data = pd.read_excel(data_file,parse_cols=COLUMNS_TO_PARSE[lab],na_values=MISSING_VALUES[lab])
        # The column labels in Excel have trailing spaces, so strip all whitespace
        raw_data.rename(columns=lambda x: x.strip(),inplace=True)

        # Read in other data; will be appended to the full data sheets but otherwise not processed
        other_data = pd.read_excel(data_file,parse_cols=NONDATA_COLUMNS[lab])
        # The column labels in Excel have trailing spaces, so strip all whitespace
        other_data.rename(columns=lambda x: x.strip(),inplace=True)

        # Standardize per lab
        raw_data = STANDARDIZE_BY_LAB[lab](raw_data)

        # Create the output Excel file writer object
        writer = pd.ExcelWriter(os.path.join(args.outputdir,output_excel))
        # Create the Excel file writer object for the full dataset file
        # According to the XlsxWriter docs, formatting cells/columns/rows that contain dates/datetimes is not possible.
        # As a workaround, set the date and datetime formats globally for the ExcelWriter instance.
        writer_fulldata = pd.ExcelWriter(os.path.join(args.datadir,dataout_excel),date_format='MM/DD/YY',datetime_format='MM/DD/YY')

        # Get the underlying Xlsxwriter book object to use for formatting cells and inserting plots
        workbook = writer.book

        # Write initial raw data summary to spreadsheet
        raw_data_summary = raw_data.describe(percentiles=[0.10,0.90])
        raw_data_summary.rename(index={'count': 'N'},inplace=True)
        raw_data_summary.transpose().to_excel(writer,sheet_name=SHEET_NAMES['raw_summary'])
        worksheet = writer.sheets[SHEET_NAMES['raw_summary']]
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('C:I',None,cell_format)
        worksheet.set_column('A:A',15)

        # Write raw data to full dataset file
        raw_data.to_excel(writer_fulldata,sheet_name=SHEET_NAMES['raw_data'],na_rep='.')

        # Perform error-correction and write to spreadsheet
        ec_data = raw_data
        # Set any negative values to missing
        ec_data = ec_data.applymap(dropNegatives)
        # Set any percentage value over 100 to missing
        for column in PERCENTAGE_COLUMNS[lab]:
            ec_data[column] = ec_data[column].map(filterPercentages)

        # Remove any duplicate samples
        ec_data.drop_duplicates(inplace=True)
        ec_data.reset_index(inplace=True)
        # Rename the column containing the original indexes from the source data.
        # This column is used to do a join with the 'other_data' frame to match up entries for
        # the full dataset output.
        ec_data.rename(columns={'index':'original_index'},inplace=True)
        # Write error-corrected data summary to spreadsheet
        ec_data_summary = ec_data.drop(['original_index'],axis=1).describe(percentiles=[0.10,0.90])
        ec_data_summary.rename(index={'count': 'N'},inplace=True)
        ec_data_summary.transpose().to_excel(writer,sheet_name=SHEET_NAMES['ec_summary'])
        worksheet = writer.sheets[SHEET_NAMES['ec_summary']]
        worksheet.set_column('A:A',15)
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('C:I',None,cell_format)

        # Write error-corrected data to full dataset file
        combined_data = ec_data.set_index('original_index')
        combined_data = other_data.join(combined_data,how='inner')
        combined_data.to_excel(writer_fulldata,sheet_name=SHEET_NAMES['ec_data'],na_rep='.')
        FORMAT_FULLDATA_BY_LAB[lab](writer_fulldata,SHEET_NAMES['ec_data'])
        del(combined_data)
        
        # Calcuate cutoffs and write to spreadsheet
        cutoffs = findCutoffs(ec_data_summary,CUTOFF_FACTOR,CUTOFF_INDEXES)
        cutoffs.transpose().to_excel(writer,sheet_name=SHEET_NAMES['cutoffs'])
        worksheet = writer.sheets[SHEET_NAMES['cutoffs']]
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('B:D',20,cell_format)
        worksheet.set_column('A:A',15)
                     
        # Calculate EC data Pearson stats and write to spreadsheet
        pearson_stats_ec = ec_data.drop(['original_index'],axis=1).corr(method='pearson')
        pearson_stats_ec.to_excel(writer,sheet_name=SHEET_NAMES['ec_pearson'])
        worksheet = writer.sheets[SHEET_NAMES['ec_pearson']]
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('B:AE',None,cell_format)
        worksheet.set_column('A:A',15)
        
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
        filtered_data = ec_data
        
        # http://stats.stackexchange.com/questions/82050/principal-component-analysis-and-regression-in-python
        # http://connor-johnson.com/2014/04/02/computing-principal-components-in-python/
        # http://sebastianraschka.com/Articles/2014_pca_step_by_step.html
        # https://plot.ly/ipython-notebooks/principal-component-analysis/#Sections
        
        
        for index,row in filtered_data.iterrows():
            for nutrient in principal_components:
                #if (float(row[nutrient]) < float(cutoffs[nutrient][CUTOFF_INDEXES['low']])) or (float(row[nutrient]) > float(cutoffs[nutrient][CUTOFF_INDEXES['high']])) or pd.isnull(row[nutrient]):
                if (float(row[nutrient]) < float(cutoffs[nutrient][CUTOFF_INDEXES['low']])) \
                    or (float(row[nutrient]) > float(cutoffs[nutrient][CUTOFF_INDEXES['high']])):
                    filtered_data.drop(index,inplace=True,errors='ignore')

        filtered_data.reset_index(drop=True,inplace=True)
        filtered_data_summary = filtered_data.drop(['original_index'],axis=1).describe(percentiles=[0.10,0.90])
        filtered_data_summary.rename(index={'count': 'N'},inplace=True)
        filtered_data_summary.transpose().to_excel(writer,sheet_name=SHEET_NAMES['filtered_summary'])
        worksheet = writer.sheets[SHEET_NAMES['filtered_summary']]
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('C:I',None,cell_format)
        worksheet.set_column('A:A',15)

        # Write filtered data to full dataset file
        combined_data = filtered_data.set_index('original_index')
        combined_data = other_data.join(combined_data,how='inner')
        combined_data.to_excel(writer_fulldata,sheet_name=SHEET_NAMES['filtered_data'],na_rep='.')
        FORMAT_FULLDATA_BY_LAB[lab](writer_fulldata,SHEET_NAMES['filtered_data'])
        del(combined_data)

        # Calculate filtered data Pearson stats and write to spreadsheet
        pearson_stats_filtered = filtered_data.drop(['original_index'],axis=1).corr(method="pearson")
        pearson_stats_filtered.transpose().to_excel(writer,sheet_name=SHEET_NAMES['filtered_pearson'])
        worksheet = writer.sheets[SHEET_NAMES['filtered_pearson']]
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('B:AE',None,cell_format)
        worksheet.set_column('A:A',15)

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

        reduced_set = pd.DataFrame()
        for nutrient in principal_components:
            reduced_set[nutrient] = filtered_data[nutrient]

        # Create standardized data set (mean = 0, std = 1) for principal components
        standardized_set = (reduced_set - reduced_set.mean())/reduced_set.std()
        standardized_set.rename(columns=pc_to_ss_mapping,inplace=True)
        standardized_set_summary = standardized_set.describe(percentiles=[0.10,0.90])

        # Create covariance matrix and find eigenvalues/eigenvectors
        cov_matrix = standardized_set.cov()
        try:
            eig_val_cov, eig_vec_cov = np.linalg.eig(cov_matrix)
        except np.linalg.LinAlgError:
            print("\tError finding eigenvalues/eigenvectors!  Cannot continue analysis.")
            continue
        tot = sum(eig_val_cov)
        var_exp = [(i / tot) for i in sorted(eig_val_cov, reverse=True)]
        cum_var_exp = np.cumsum(var_exp)

        eigenval_summary = pd.DataFrame({'Eigenvalue' : eig_val_cov, 'Proportion': var_exp, 'Cumulative' : cum_var_exp, })       

        # Write results and summary data
        standardized_set_summary.to_excel(writer,sheet_name=SHEET_NAMES['pca_results'],startrow=1)
        worksheet = writer.sheets[SHEET_NAMES['pca_results']]
        worksheet.write(0,0,"Standardized Nutrients:")
        worksheet.write(len(standardized_set_summary.index)+3,0,"Covariance Matrix:")
        cov_matrix.to_excel(writer,sheet_name=SHEET_NAMES['pca_results'],startrow=len(standardized_set_summary.index)+4)
        worksheet.write(len(standardized_set_summary.index) + len(cov_matrix) + 6,0,"Eigenvalues of the Covariance Matrix:")
        eigenval_summary.to_excel(writer,sheet_name=SHEET_NAMES['pca_results'],startrow=len(standardized_set_summary.index) + len(cov_matrix) + 7, columns=['Eigenvalue','Proportion','Cumulative'] )
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('B:I',None,cell_format)
        general_cell_format = workbook.add_format()
        general_cell_format.set_num_format('General')
        worksheet.set_row(2,None,general_cell_format)

        # Transform the standardized dataset
        transformed_pca_set = np.dot(standardized_set,eig_vec_cov)
        pca_set = pd.DataFrame(transformed_pca_set,columns=pca_vars)
        pearson_stats_pca_set = pca_set.corr(method='pearson')
        pca_set2 = pca_set.join(filtered_data,how='left')
        pca_set2 = pca_set2.join(standardized_set,how='left')
        pca_set2.reset_index(drop=True,inplace=True)
        pca_prefilter_set_summary = pca_set2.drop(['original_index'],axis=1).describe(percentiles=[0.10,0.90])
        pca_prefilter_set_summary.rename(index={'count': 'N'},inplace=True)
        pca_prefilter_set_summary.transpose().to_excel(writer,sheet_name=SHEET_NAMES['pca_prefilter'])
        worksheet = writer.sheets[SHEET_NAMES['pca_prefilter']]
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('C:I',None,cell_format)
        worksheet.set_column('A:A',15)
        pca_cutoffs = findCutoffs(pca_prefilter_set_summary,CUTOFF_FACTOR,CUTOFF_INDEXES)
        pca_set_filtered = pca_set2

        # Filter PCA data based on cutoffs
        for pc in pca_vars:
            pca_set_filtered = pca_set_filtered[(float(pca_cutoffs[pc][CUTOFF_INDEXES['low']]) \
                    < pca_set_filtered[pc] ) & ( pca_set_filtered[pc] \
                    < float(pca_cutoffs[pc][CUTOFF_INDEXES['high']])) ]

        pca_set_filtered.reset_index(drop=True,inplace=True)
        pca_set_summary = pca_set_filtered.drop(['original_index'],axis=1).describe(percentiles=[0.10,0.90])
        pca_set_summary.rename(index={'count': 'N'},inplace=True)
        pca_set_summary.transpose().to_excel(writer,sheet_name=SHEET_NAMES['pca_postfilter'])
        worksheet = writer.sheets[SHEET_NAMES['pca_postfilter']]
        worksheet.write(len(pca_set_summary.transpose().index)+4,0,"Pearson Stats:")
        pearson_stats_pca = pca_set_filtered[principal_components].corr(method='pearson')
        pearson_stats_pca.to_excel(writer,sheet_name=SHEET_NAMES['pca_postfilter'],startrow=len(pca_set_summary.transpose().index)+5)
        cell_format = workbook.add_format()
        cell_format.set_num_format('0.00')
        worksheet.set_column('C:I',None,cell_format)
        worksheet.set_column('A:A',15)
        for rnum in range(len(pca_set_summary.transpose().index)+6,len(pca_set_summary.transpose().index)+6+len(pearson_stats_pca.index)):
            worksheet.set_row(rnum,None,cell_format)

        # Write PCA post-filter data to full dataset file
        combined_data = pca_set_filtered.set_index('original_index')
        combined_data = other_data.join(combined_data,how='inner')
        combined_data.to_excel(writer_fulldata,sheet_name=SHEET_NAMES['pcapf_data'],na_rep='.')
        FORMAT_FULLDATA_BY_LAB[lab](writer_fulldata,SHEET_NAMES['pcapf_data'])
        del(combined_data)


        # Determine k from n, k=n^0.3
        n = len(pca_set_filtered.index)
        k = int(round(n**0.3))

        # Create temporary files for SAS input/output, SAS script
        (pca_tmp_csv_fh,pca_tmp_csv) = tempfile.mkstemp(suffix='.csv')
        (sasout_tmp_html_fh,sasout_tmp_html) = tempfile.mkstemp(suffix='.html')
        (psf_tmp_png_fh,psf_tmp_png) = tempfile.mkstemp(suffix='.png')
        (pst2_tmp_png_fh,pst2_tmp_png) = tempfile.mkstemp(suffix='.png')
        (sasout_tmp_csv_fh,sasout_tmp_csv) = tempfile.mkstemp(suffix='.csv')
        (sas_cluster_input_fh,sas_cluster_input) = tempfile.mkstemp(suffix='.sas')

        # Create CSV input for SAS
        pca_set_filtered.to_csv(pca_tmp_csv,na_rep='.',index=False)

        # Create SAS script to run PROC CLUSTER, write to file
        sas_cluster_script = generateClusteringScript(pca_tmp_csv,sasout_tmp_html,k,filtered_data.columns,\
            standardized_set.columns,psf_tmp_png,pst2_tmp_png,sasout_tmp_csv)
        sas_input_script = open(sas_cluster_input,'w')
        sas_input_script.write(textwrap.dedent(sas_cluster_script))
        sas_input_script.close()

        # SAS log file name
        sas_log = os.path.join(logdir,(basename + '_PROC_CLUSTER_round_1' + '.log'))
        # SAS print output .lst name
        sas_lst = os.path.join(logdir,(basename + '_PROC_CLUSTER_round_1' + '.lst'))
        # Run SAS for PROC CLUSTER
        subprocess.call(["sas",sas_cluster_input,"-log",sas_log,"-print",sas_lst])

        # Process PROC CLUSTER results and find number of clusters
        num_clusters = processClusterResults(writer,workbook,SHEET_NAMES['cluster_history'],sasout_tmp_html,psf_tmp_png,pst2_tmp_png,k,n)

        os.close(pca_tmp_csv_fh)
        os.close(sasout_tmp_html_fh)
        os.close(psf_tmp_png_fh)
        os.close(pst2_tmp_png_fh)
        os.close(sasout_tmp_csv_fh)
        os.close(sas_cluster_input_fh)

        print "\t%s clusters found" % num_clusters
        if num_clusters == 1:
        # Single cluster case.  No need to run PROC TREE, just perform final 3.5SD filtering and find changes.

            pca_out_reduced = pca_set_filtered[filtered_data.columns]

            # Cluster summary before 3.5SD final filter
            cluster_summary = pca_out_reduced.drop(['original_index'],axis=1).describe(percentiles=[0.10,0.90])
            cluster_summary.rename(index={'count': 'N'},inplace=True)
            cluster_summary.transpose().to_excel(writer,sheet_name=SHEET_NAMES['cluster_summary'] % (1,1))
            worksheet = writer.sheets[SHEET_NAMES['cluster_summary'] % (1,1)]
            worksheet.set_column('A:A',15)
            cell_format = workbook.add_format()
            cell_format.set_num_format('0.00')
            worksheet.set_column('C:I',None,cell_format)

            # Determine cutoffs and write to Excel
            final_data_cutoffs = findCutoffs(pca_out_reduced.drop(['original_index'],axis=1).describe(),CUTOFF_FACTOR,CUTOFF_INDEXES)
            final_data_cutoffs.transpose().to_excel(writer,sheet_name=SHEET_NAMES['cutoffs_cluster'] % (1))
            worksheet = writer.sheets[SHEET_NAMES['cutoffs_cluster'] % (1)]
            worksheet.set_column('A:A',15)
            cell_format = workbook.add_format()
            cell_format.set_num_format('0.00')
            worksheet.set_column('B:D',20,cell_format)

            # Create final filtered data set based on cutoffs
            final_filtered_data = pd.DataFrame()
            for nutrient in pca_out_reduced.columns:
                try:
                    if nutrient == 'original_index':
                        final_filtered_data[nutrient] = pca_out_reduced[nutrient]
                    else:
                        final_filtered_data[nutrient] = pca_out_reduced[nutrient].apply(filterByCutoff,\
                        low_cutoff=final_data_cutoffs[nutrient][CUTOFF_INDEXES['low']],high_cutoff=final_data_cutoffs[nutrient][CUTOFF_INDEXES['high']] )
                except KeyError:
                    pass

            # Write final (single) cluster data to full dataset file
            combined_data = final_filtered_data.set_index('original_index')
            combined_data = other_data.join(combined_data,how='inner')
            combined_data.to_excel(writer_fulldata,sheet_name=SHEET_NAMES['final_cluster_data'] % (1),na_rep='.')
            FORMAT_FULLDATA_BY_LAB[lab](writer_fulldata,SHEET_NAMES['final_cluster_data'] % (1))
            del(combined_data)

            # Write final data summary and Pearson stats to Excel
            final_data_summary = final_filtered_data.drop(['original_index'],axis=1).describe(percentiles=[0.10,0.90])
            final_data_summary.rename(index={'count': 'N'},inplace=True)
            final_data_summary.transpose().to_excel(writer,sheet_name=SHEET_NAMES['final'],startrow=1)
            worksheet = writer.sheets[SHEET_NAMES['final']]
            worksheet.set_column('A:A',15)
            cell_format = workbook.add_format()
            cell_format.set_num_format('0.00')
            worksheet.set_column('C:I',None,cell_format)
            worksheet.write(0,0,"Final Results, Cluster # 1")
            worksheet.write(len(final_data_summary.transpose().index)+4,0,"Pearson Stats, Cluster # 1")
            pearson_stats_final = final_filtered_data[principal_components].corr(method='pearson')
            pearson_stats_final.to_excel(writer,sheet_name=SHEET_NAMES['final'],startrow=len(final_data_summary.transpose().index)+5)
            for rnum in range(len(final_data_summary.transpose().index)+6,len(final_data_summary.transpose().index)+6+len(pearson_stats_final.index)):
                worksheet.set_row(rnum,None,cell_format)

            # Find changes after each step
            ec_changes = findChanges(raw_data_summary,ec_data_summary,CHANGES_INDEXES)
            initial_filter_changes = findChanges(raw_data_summary,filtered_data_summary,CHANGES_INDEXES)
            pca_changes = findChanges(filtered_data_summary,pca_set_summary,CHANGES_INDEXES)
            # For a single cluster, these changes should always be zero
            clustering_changes = findChanges(pca_set_summary[filtered_data.drop(['original_index'],axis=1).columns], \
                                            pca_set_summary[filtered_data.drop(['original_index'],axis=1).columns],CHANGES_INDEXES)
            final_filter_changes = findChanges(pca_set_summary[filtered_data.drop(['original_index'],axis=1).columns],final_data_summary,CHANGES_INDEXES)
            total_changes = findChanges(raw_data_summary,final_data_summary,CHANGES_INDEXES)

            # Replace np.nan by 0 to avoid errors when writing the data to Excel
            ec_changes.fillna(0,inplace=True)
            initial_filter_changes.fillna(0,inplace=True)
            pca_changes.fillna(0,inplace=True)
            clustering_changes.fillna(0,inplace=True)
            final_filter_changes.fillna(0,inplace=True)
            total_changes.fillna(0,inplace=True)

            # Setup sheet formatting, add column headings
            worksheet = workbook.add_worksheet(SHEET_NAMES['changes'])
            formatChangesSheet(workbook,worksheet,raw_data.columns,FINAL_CHANGES_HEADINGS,FINAL_CHANGES_STEP_HEADINGS)

            # Write data to Excel
            populateChangesSheet(workbook,worksheet,raw_data_summary,final_data_summary,ec_changes,initial_filter_changes,pca_changes,\
            clustering_changes,final_filter_changes,total_changes,CHANGES_INDEXES)

        else:
            # Multiple cluster case. Do an initial round of cluster removal by running PROC TREE and removing any cluster
            # with too few samples.
            filter_round = 1
            (cluster_tmp_csv_fh,cluster_tmp_csv) = tempfile.mkstemp(suffix='.csv')
            (sasout_tree_tmp_csv_fh,sasout_tree_tmp_csv) = tempfile.mkstemp(suffix='.csv')
            (sas_tree_input_fh,sas_tree_input) = tempfile.mkstemp(suffix='.sas')

            sas_tree_script = generateTreeScript(sasout_tmp_csv,num_clusters,sasout_tree_tmp_csv,filtered_data.columns,\
                                standardized_set.columns)

            sas_input_script = open(sas_tree_input,'w')
            sas_input_script.write(textwrap.dedent(sas_tree_script))
            sas_input_script.close()

            # SAS log file name
            sas_log = os.path.join(logdir,(basename + '_PROC_TREE_round_%d' % (filter_round) + '.log'))
            # SAS print output .lst name
            sas_lst = os.path.join(logdir,(basename + '_PROC_TREE_round_%d' % (filter_round) + '.lst'))
            # Run SAS for PROC TREE
            subprocess.call(["sas",sas_tree_input,"-log",sas_log,"-print",sas_lst])

            os.close(cluster_tmp_csv_fh)
            os.close(sasout_tree_tmp_csv_fh)
            os.close(sas_tree_input_fh)

            sorted_tree = pd.read_csv(sasout_tree_tmp_csv,na_values=["."])
            print "\tBefore cluster removal: %d number of samples" % (len(sorted_tree.index))
            delete_threshold = int(round(CLUSTER_REMOVAL_FACTOR*len(sorted_tree.index)))
            # List of indexes of remaining clusters
            clusters_remaining = range(1,num_clusters+1)
            # List of indexes of removed clusters
            clusters_removed = []
            # Object holding the DataFrames for every removed cluster.
            # Consists of a dictionary where the keys are the filter removal round integer values and
            # the values are a list.  Each list item is the DataFrame object for the removed cluster.
            all_clusters_removed_by_round = {}
            all_clusters_removed_by_round[filter_round] = []

            print "\tDelete threshold is %d samples" % (delete_threshold)
            for cluster_index in range(1,num_clusters+1):
                print "\tCluster %d has %d samples" % (cluster_index, \
                            len(sorted_tree.loc[sorted_tree['CLUSTER'] == cluster_index].index))
                tmp_summary = sorted_tree.loc[sorted_tree['CLUSTER'] == cluster_index].describe(percentiles=[0.10,0.90])
                tmp_summary = tmp_summary[filtered_data.columns].drop(['original_index'],axis=1)
                tmp_summary.rename(index={'count': 'N'},inplace=True)
                tmp_summary.transpose().to_excel(writer,sheet_name=SHEET_NAMES['cluster_summary'] % (cluster_index,filter_round))
                worksheet = writer.sheets[SHEET_NAMES['cluster_summary'] % (cluster_index,filter_round)]
                worksheet.set_column('A:A',15)
                cell_format = workbook.add_format()
                cell_format.set_num_format('0.00')
                worksheet.set_column('C:I',None,cell_format)

                if len(sorted_tree.loc[sorted_tree['CLUSTER'] == cluster_index].index) < delete_threshold:
                    all_clusters_removed_by_round[filter_round].append(sorted_tree.loc[sorted_tree.CLUSTER == cluster_index])
                    sorted_tree = sorted_tree[sorted_tree.CLUSTER != cluster_index]
                    clusters_removed.append(cluster_index)
                    clusters_remaining.remove(cluster_index)

            print "\tAfter initial cluster removal:"
            print "\tClusters removed: %s" % (clusters_removed)
            print "\tClusters remaining %s" % (clusters_remaining)
            print "\t%d number of samples" % (len(sorted_tree.index))

            # At least one cluster was removed.  Continue running PROC CLUSTER, PROC TREE until no more clusters are removed.
            while clusters_removed:
                clusters_removed = []
                filter_round +=1
                print "\tContinue cluster removal"
                remaining_clusters_raw = sorted_tree
                all_clusters_removed_by_round[filter_round] = []
                # Determine k from n, k=n^0.3
                n = len(remaining_clusters_raw.index)
                k = int(round(n**0.3))

                # Create temporary files for SAS input/output, SAS script
                (clusters_tmp_csv_fh,clusters_tmp_csv) = tempfile.mkstemp(suffix='.csv')
                (sasout_tmp_html_fh,sasout_tmp_html) = tempfile.mkstemp(suffix='.html')
                (psf_tmp_png_fh,psf_tmp_png) = tempfile.mkstemp(suffix='.png')
                (pst2_tmp_png_fh,pst2_tmp_png) = tempfile.mkstemp(suffix='.png')
                (sasout_tmp_csv_fh,sasout_tmp_csv) = tempfile.mkstemp(suffix='.csv')
                (sas_cluster_input_fh,sas_cluster_input) = tempfile.mkstemp(suffix='.sas')

                # Create CSV input for SAS
                remaining_clusters_raw.to_csv(clusters_tmp_csv,na_rep='.',index=False)

                # Create SAS script to run PROC CLUSTER, write to file
                sas_cluster_script = generateClusteringScript(clusters_tmp_csv,sasout_tmp_html,k,filtered_data.columns,\
                    standardized_set.columns,psf_tmp_png,pst2_tmp_png,sasout_tmp_csv)
                sas_input_script = open(sas_cluster_input,'w')
                sas_input_script.write(textwrap.dedent(sas_cluster_script))
                sas_input_script.close()

                # SAS log file name
                sas_log = os.path.join(logdir,(basename + '_PROC_CLUSTER_round_%d' % (filter_round) + '.log'))
                # SAS print output .lst name
                sas_lst = os.path.join(logdir,(basename + '_PROC_CLUSTER_round_%d' % (filter_round) + '.lst'))
                # Run SAS for PROC CLUSTER
                subprocess.call(["sas",sas_cluster_input,"-log",sas_log,"-print",sas_lst])

                # Process PROC CLUSTER results and find number of clusters
                num_clusters = processClusterResults(writer,workbook,SHEET_NAMES['cluster_filter'] % filter_round,sasout_tmp_html,psf_tmp_png,pst2_tmp_png,k,n)
                print "\tCluster removal round %d, number of clusters is %d" % (filter_round,num_clusters)
                clusters_remaining = range(1,num_clusters+1)
                os.close(pca_tmp_csv_fh)
                os.close(sasout_tmp_html_fh)
                os.close(psf_tmp_png_fh)
                os.close(pst2_tmp_png_fh)
                os.close(sasout_tmp_csv_fh)
                os.close(sas_cluster_input_fh)

                (cluster_tmp_csv_fh,cluster_tmp_csv) = tempfile.mkstemp(suffix='.csv')
                (sasout_tree_tmp_csv_fh,sasout_tree_tmp_csv) = tempfile.mkstemp(suffix='.csv')
                (sas_tree_input_fh,sas_tree_input) = tempfile.mkstemp(suffix='.sas')

                sas_tree_script = generateTreeScript(sasout_tmp_csv,num_clusters,sasout_tree_tmp_csv,filtered_data.columns,\
                                                        standardized_set.columns)

                sas_input_script = open(sas_tree_input,'w')
                sas_input_script.write(textwrap.dedent(sas_tree_script))
                sas_input_script.close()

                # SAS log file name
                sas_log = os.path.join(logdir,(basename + '_PROC_TREE_round_%d' % (filter_round) + '.log'))
                # SAS print output .lst name
                sas_lst = os.path.join(logdir,(basename + '_PROC_TREE_round_%d' % (filter_round) + '.lst'))
                # Run SAS for PROC TREE
                subprocess.call(["sas",sas_tree_input,"-log",sas_log,"-print",sas_lst])

                os.close(cluster_tmp_csv_fh)
                os.close(sasout_tree_tmp_csv_fh)
                os.close(sas_tree_input_fh)

                try:
                    sorted_tree = pd.read_csv(sasout_tree_tmp_csv,na_values=["."])
                except ValueError:
                    print "\tWarning, PROC TREE returned no results.  Skipping to final filtering..."
                    clusters_removed = []
                    continue

                print "\tBefore cluster removal: %d number of samples" % (len(sorted_tree.index))
                delete_threshold = int(round(CLUSTER_REMOVAL_FACTOR*len(sorted_tree.index)))
                clusters_remaining = range(1,num_clusters+1)
                clusters_removed = []
                print "\tDelete threshold is %d samples" % (delete_threshold)
                for cluster_index in range(1,num_clusters+1):
                    print "\tCluster %d has %d samples" % (cluster_index, \
                        len(sorted_tree.loc[sorted_tree['CLUSTER'] == cluster_index].index))
                    tmp_summary = pd.DataFrame()
                    tmp_summary = sorted_tree.loc[sorted_tree['CLUSTER'] == cluster_index].drop(['original_index'],axis=1).describe(percentiles=[0.10,0.90])
                    tmp_summary = tmp_summary[filtered_data.drop(['original_index'],axis=1).columns]
                    tmp_summary.rename(index={'count': 'N'},inplace=True)
                    tmp_summary.transpose().to_excel(writer,sheet_name=SHEET_NAMES['cluster_summary'] % (cluster_index,filter_round))
                    worksheet = writer.sheets[SHEET_NAMES['cluster_summary'] % (cluster_index,filter_round)]
                    worksheet.set_column('A:A',15)
                    cell_format = workbook.add_format()
                    cell_format.set_num_format('0.00')
                    worksheet.set_column('C:I',None,cell_format)
                    if len(sorted_tree.loc[sorted_tree['CLUSTER'] == cluster_index].index) < delete_threshold:
                        all_clusters_removed_by_round[filter_round].append(sorted_tree.loc[sorted_tree.CLUSTER == cluster_index])
                        sorted_tree = sorted_tree[sorted_tree.CLUSTER != cluster_index]
                        clusters_removed.append(cluster_index)
                        clusters_remaining.remove(cluster_index)


            else:
                # All clusters with too few samples have been removed.  Do final 3.5SD filtering per cluster and find total changes.
                print "\tCluster removal complete"
                # DataFrame with all remaining clusters, before final 3.5SD filtering
                remaining_clusters_raw = sorted_tree.loc[sorted_tree['CLUSTER'].isin(clusters_remaining)]
                # Summary for all remaining clusters, before 3.5SD final filtering
                remaining_clusters_raw_summary = remaining_clusters_raw.drop(['original_index'],axis=1).describe(percentiles=[0.10,0.90])
                remaining_clusters_raw_summary.rename(index={'count': 'N'},inplace=True)
                # DataFrame for all remaining clusters after final 3.5SD filtering
                all_clusters_filtered = pd.DataFrame()

                # Workaround to force sheets to be in the proper order.
                # Proper way would be to call workbook.add_worksheet() method first to define order and then populate the sheet,
                # but if you do then DataFrame.to_excel() will raise an exception that the sheet name is already in use.
                for cluster_number in clusters_remaining:
                    dummy_df = pd.DataFrame()
                    dummy_df.to_excel(writer,sheet_name=SHEET_NAMES['cutoffs_cluster'] % (cluster_number))

                for cluster_number in clusters_remaining:
                    # Create per cluster results data set and determine cutoffs
                    tmp_df_final = pd.DataFrame()
                    tmp_df_final = sorted_tree[sorted_tree.CLUSTER == cluster_number]
                    tmp_df_final = tmp_df_final[filtered_data.columns]

                    # Find cutoffs
                    tmp_df_final_cutoffs = findCutoffs(tmp_df_final.drop(['original_index'],axis=1).describe(),CUTOFF_FACTOR,CUTOFF_INDEXES)
                    tmp_df_final_cutoffs.transpose().to_excel(writer,sheet_name=SHEET_NAMES['cutoffs_cluster'] % (cluster_number))
                    worksheet = writer.sheets[SHEET_NAMES['cutoffs_cluster'] % (cluster_number)]
                    worksheet.set_column('A:A',15)
                    cell_format = workbook.add_format()
                    cell_format.set_num_format('0.00')
                    worksheet.set_column('B:D',20,cell_format)

                    # Create per cluster final filtered data set based on cutoffs
                    tmp_final_filtered_data = pd.DataFrame()
                    for nutrient in tmp_df_final.columns:
                        try:
                            if nutrient == 'original_index':
                                tmp_final_filtered_data[nutrient] = tmp_df_final[nutrient]
                            else:
                                tmp_final_filtered_data[nutrient] = tmp_df_final[nutrient].apply(filterByCutoff,\
                                low_cutoff=tmp_df_final_cutoffs[nutrient][CUTOFF_INDEXES['low']],\
                                high_cutoff=tmp_df_final_cutoffs[nutrient][CUTOFF_INDEXES['high']] )
                        except KeyError as e:
                            pass


                    # Write final cluster data to full dataset file, one cluster per worksheet
                    combined_data = tmp_final_filtered_data.set_index('original_index')
                    combined_data = other_data.join(combined_data,how='inner')
                    combined_data.to_excel(writer_fulldata,sheet_name=SHEET_NAMES['final_cluster_data'] % (cluster_number),na_rep='.')
                    FORMAT_FULLDATA_BY_LAB[lab](writer_fulldata,SHEET_NAMES['final_cluster_data'] % (cluster_number))
                    del(combined_data)

                    # Add the per-cluster 3.5SD filtered DataFrame to the one containing data for all
                    all_clusters_filtered = all_clusters_filtered.append(tmp_final_filtered_data)

                    # Write final cluster(s) summary to a single sheet
                    start_col = 10*(cluster_number-1)
                    tmp_final_data_summary = tmp_final_filtered_data.drop(['original_index'],axis=1).describe(percentiles=[0.10,0.90])
                    tmp_final_data_summary.rename(index={'count': 'N'},inplace=True)
                    tmp_final_data_summary.transpose().to_excel(writer,sheet_name=SHEET_NAMES['final'],startcol=start_col,startrow=1)
                    worksheet = writer.sheets[SHEET_NAMES['final']]
                    worksheet.write(0,start_col,"Final Results, Cluster # %d" % (cluster_number))
                    worksheet.set_column(start_col,start_col,15)
                    cell_format = workbook.add_format()
                    cell_format.set_num_format('0.00')
                    worksheet.set_column(start_col+2,start_col+8,None,cell_format)
                    worksheet.write(len(tmp_final_data_summary.transpose().index)+5,start_col,"Pearson Stats, Cluster # %d" % (cluster_number))
                    tmp_pearson_stats_final = tmp_final_filtered_data[principal_components].corr(method='pearson')
                    tmp_pearson_stats_final.to_excel(writer,sheet_name=SHEET_NAMES['final'],\
                        startrow=len(tmp_final_data_summary.transpose().index)+6,startcol=start_col)

                    for rnum in range(len(tmp_final_data_summary.transpose().index)+7,len(tmp_final_data_summary.transpose().index)+7+len(tmp_pearson_stats_final.index)):
                        worksheet.set_row(rnum,None,cell_format)


                # Create summary data for all clusters together after 3.5SD filtering
                all_clusters_filtered_data_summary = all_clusters_filtered.drop(['original_index'],axis=1).describe(percentiles=[0.10,0.90])
                all_clusters_filtered_data_summary.rename(index={'count': 'N'},inplace=True)

                # Find changes after each step
                ec_changes = findChanges(raw_data_summary,ec_data_summary,CHANGES_INDEXES)
                initial_filter_changes = findChanges(raw_data_summary,filtered_data_summary,CHANGES_INDEXES)
                pca_changes = findChanges(filtered_data_summary,pca_set_summary,CHANGES_INDEXES)
                clustering_changes = findChanges(pca_set_summary[filtered_data.drop(['original_index'],axis=1).columns], \
                                                remaining_clusters_raw_summary[filtered_data.drop(['original_index'],axis=1).columns],\
                                                CHANGES_INDEXES)
                final_filter_changes = findChanges(remaining_clusters_raw_summary[filtered_data.drop(['original_index'],axis=1).columns],\
                                                    all_clusters_filtered_data_summary,CHANGES_INDEXES)
                total_changes = findChanges(raw_data_summary,all_clusters_filtered_data_summary,CHANGES_INDEXES)

                # Replace np.nan by 0 to avoid errors when writing the data to Excel
                ec_changes.fillna(0,inplace=True)
                initial_filter_changes.fillna(0,inplace=True)
                pca_changes.fillna(0,inplace=True)
                clustering_changes.fillna(0,inplace=True)
                final_filter_changes.fillna(0,inplace=True)
                total_changes.fillna(0,inplace=True)

                # Setup sheet formatting, add column headings
                worksheet = workbook.add_worksheet(SHEET_NAMES['changes'])
                formatChangesSheet(workbook,worksheet,raw_data.columns,FINAL_CHANGES_HEADINGS,FINAL_CHANGES_STEP_HEADINGS)

                # Write data to Excel
                populateChangesSheet(workbook,worksheet,raw_data_summary,all_clusters_filtered_data_summary,ec_changes,initial_filter_changes,pca_changes,\
                    clustering_changes,final_filter_changes,total_changes,CHANGES_INDEXES)

                # Write all deleted clusters to a single worksheet
                for a_round in range(1,filter_round+1):
                    if all_clusters_removed_by_round[a_round]:
                        removed_index = 1
                        for deleted_cluster in all_clusters_removed_by_round[a_round]:
                            deleted_cluster_summary = deleted_cluster[filtered_data.columns].drop(['original_index'],axis=1).describe(percentiles=[0.10,0.90])
                            deleted_cluster_summary.rename(index={'count': 'N'},inplace=True)
                            start_col = 10 * (removed_index-1)
                            deleted_cluster_summary.transpose().to_excel(writer,sheet_name=SHEET_NAMES['clusters_removed'] % (a_round),startcol=start_col,startrow=1)
                            worksheet = writer.sheets[SHEET_NAMES['clusters_removed'] % (a_round)]
                            worksheet.write(0,start_col,"Deleted Cluster #%d, round %d" % (removed_index,a_round))
                            worksheet.set_column(start_col,start_col,15)
                            cell_format = workbook.add_format()
                            cell_format.set_num_format('0.00')
                            worksheet.set_column(start_col+2,start_col+8,None,cell_format)

                            # Write deleted cluster data to full dataset file, one cluster per worksheet
                            combined_data = deleted_cluster[filtered_data.columns].set_index('original_index')
                            combined_data = other_data.join(combined_data,how='inner')
                            combined_data.to_excel(writer_fulldata, sheet_name=SHEET_NAMES['deleted_cluster_data'] % (removed_index,a_round),na_rep='.')
                            FORMAT_FULLDATA_BY_LAB[lab](writer_fulldata, SHEET_NAMES['deleted_cluster_data'] % (removed_index,a_round))
                            del(combined_data)

                            removed_index = removed_index + 1

        workbook.close()
        writer.close()
        writer_fulldata.close()
        
