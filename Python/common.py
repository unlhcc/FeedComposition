# -*- coding: utf-8 -*-
"""
Created on Thu Aug  6 16:03:43 2015

@author: acaprez
"""
import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
from scipy.stats.kde import gaussian_kde
import textwrap
import argparse
import os
import os.path
import tempfile
import csv
import StringIO
from bs4 import BeautifulSoup as bs

def parseOptions(procedure):
    """Process command-line arguments."""
    description = textwrap.wrap("Performs stastical filtering of feed compositon data according to the procedure in the following publication:") \
    + textwrap.wrap("P.S. Yoder, N.R. St-Pierre, W.P. Weiss, A statistical filtering procedure to improve "\
        "the accuracy of estimating population parameters in feed composition databases, Journal of Dairy "\
        "Science, Volume 97, Issue 9, September 2014, Pages 5645-5656, ISSN 0022-0302, "\
        "http://dx.doi.org/10.3168/jds.2013-7724.")
    description = "\n".join(description)
    epilog = "One output Excel file is created per input file."

    parser = argparse.ArgumentParser(description=description,formatter_class=argparse.RawDescriptionHelpFormatter,epilog=epilog)
    if procedure == 'a':
         parser.add_argument('input_file_list',type=argparse.FileType('rU'),help='File containing the input Excel filenames, one file per line')
    elif procedure == 'b':
         parser.add_argument('input_file_list',type=argparse.FileType('rUb'),help='File containing the input Excel filenames and key nutrients. \
                            One entry per line, comma-separated values.  The Excel filename must be listed first, then the list of nutrients.')
         parser.add_argument('-L','--logdir',help='Directory for SAS log files, defaults to current working directory',default=os.getcwd())
         parser.add_argument('-d','--datadir',help='Directory for Excel files containing full dataset after each step, defaults to current working directory',\
                             default=os.getcwd())

    parser.add_argument('-o','--outputdir',help='Output directory for files, defaults to current working directory',default=os.getcwd())
    parser.add_argument('-l','--lab',help="Name of the lab the data originates from [required]",required=True,\
                        choices=['L1','cvas','dairyone','dairyland','rockriver'])

    args = parser.parse_args()
    return args
    
def verifyInput(input_file_list,procedure):
    """Verify files in input list exist and are the correct type.  For Procedure A, returns a list of verified filenames.  For Procedure B, returns a tuple of a list of verified filenames and two-level nested list of key nutrients."""
    if procedure == 'a':
        input_files = []
        for infile in input_file_list:
            if os.path.isfile(os.path.abspath(infile.strip('"\'\n'))):
                input_files.append(os.path.abspath(infile.strip('"\'\n')))
            else:
                print "Warning, file '%s' not found.  Continuing..." % (os.path.abspath(infile.strip('"\'\n')))
        return input_files
    if procedure == 'b':
        input_files = []
        key_nutrients = []
        reader = csv.reader(input_file_list,skipinitialspace=True)
        for row in reader:
            infile = row[0]
            nutrients = row[1:]
            if os.path.isfile(os.path.abspath(infile.strip('"\'\n'))):
                input_files.append(os.path.abspath(infile.strip('"\'\n')))
                key_nutrients.append(nutrients)
            else:
                print "Warning, file '%s' not found.  Continuing..." % (os.path.abspath(infile.strip('"\'\n')))
                continue
        return (input_files,key_nutrients)
            
def filterByCutoff(x,low_cutoff,high_cutoff):
    """Filters a value given a low and high cutoff.  If the value is outside that range, return (NumPy) NaN to indicate it's missing."""
    if x < low_cutoff or x > high_cutoff:
        return np.nan
    else:
        return x
        
def dropNegatives(val):
    """If a value is less than zero, return (NumPy) NaN to set it to missing."""
    if val > 0:
        return val
    else:
        return np.nan

def filterPercentages(val):
    """If a percentage is over 100, return (NumPy) NaN to set it to missing."""
    if val < 100:
         return val
    else:
         return np.nan

def findCutoffs(data_summary,factor,indexes):
    """Calcuates low and high cutoffs for a data set summary (output of DataFrame.describe()) based on the mean and a set factor multiplied by the standard deviation.  Returns a 
    DataFrame object with one nutrient per column."""
    
    cutoffs = pd.DataFrame(index=[indexes['std'],indexes['low'],indexes['high']],columns=data_summary.columns)
    for element in data_summary.columns:
        cutoffs[element][indexes['std']] = factor*data_summary[element]['std']
        cutoffs[element][indexes['low']] = data_summary[element]['mean'] - factor*data_summary[element]['std']
        cutoffs[element][indexes['high']] = data_summary[element]['mean'] + factor*data_summary[element]['std']
    return cutoffs


def findChanges(old_summary,new_summary,indexes):
    """Calculates the changes (raw and % difference) for the count, mean, and standard deviation for a dataset before and after filtering.
    Takes the output of the describe() function before and after filtering as input.  Returns a DataFrame object with one nutrient per column."""
    
    changes = pd.DataFrame(index=[indexes['delta_N'],indexes['delta_mean'],indexes['delta_std'],indexes['percent_diff_N'],\
        indexes['percent_diff_mean'],indexes['percent_diff_std']],columns=old_summary.columns)
    
    for element in old_summary.columns:        
        changes[element][indexes['delta_N']] = new_summary[element]['N'] - old_summary[element]['N']
        changes[element][indexes['delta_mean']] = new_summary[element]['mean'] - old_summary[element]['mean']
        changes[element][indexes['delta_std']] = new_summary[element]['std'] - old_summary[element]['std']
        changes[element][indexes['percent_diff_N']] = 100 * abs(new_summary[element]['N'] - old_summary[element]['N']) /  old_summary[element]['N']
        changes[element][indexes['percent_diff_mean']] = 100 * abs(new_summary[element]['mean'] - old_summary[element]['mean']) /  old_summary[element]['mean']
        changes[element][indexes['percent_diff_std']] = 100 * abs(new_summary[element]['std'] - old_summary[element]['std']) /  old_summary[element]['std']
        
    return changes

def formatChangesSheet(workbook,worksheet,nutrients,headings,step_headings):
    """Adds the column headings and formatting for the summary changes Excel sheet."""
    bold_center = workbook.add_format({'bold': True,'align':'center'})
    center = workbook.add_format({'align':'center'})
    two_decimal_center = workbook.add_format({'align':'center','num_format':'0.00'})
    worksheet.set_column('A:A',15)
    worksheet.write_column(2,0,nutrients,bold_center)
    worksheet.merge_range("C1:H1",headings['n_removed'],bold_center)
    worksheet.merge_range("K1:P1",headings['percent_n_removed'],bold_center)
    worksheet.merge_range("R1:W1",headings['mean_removed'],bold_center)
    worksheet.merge_range("Y1:AD1",headings['percent_mean_removed'],bold_center)
    worksheet.merge_range("AF1:AK1",headings['std_removed'],bold_center)
    worksheet.merge_range("AM1:AR1",headings['percent_std_removed'],bold_center)
    worksheet.merge_range("B1:B2",headings['startn'],center)
    worksheet.merge_range("I1:I2",headings['finaln'],center)
    worksheet.write_row("C2",step_headings,center)
    worksheet.write_row("K2",step_headings,center)
    worksheet.write_row("R2",step_headings,center)
    worksheet.write_row("Y2",step_headings,center)
    worksheet.write_row("AF2",step_headings,center)
    worksheet.write_row("AM2",step_headings,center)

def populateChangesSheet(workbook,worksheet,raw_data_summary,final_data_summary,ec_changes,initial_filter_changes,pca_changes,clustering_changes,final_filter_changes,total_changes,changes_indexes):
    """Writes the data to the summary changes Excel sheet."""
    center = workbook.add_format({'align':'center'})
    two_decimal_center = workbook.add_format({'align':'center','num_format':'0.00'})
    # Start N, Final N
    worksheet.write_column("B3",raw_data_summary.transpose()['N'].values.astype(int),center)
    worksheet.write_column("I3",final_data_summary.transpose()['N'].values.astype(int),center)
    # N removed
    worksheet.write_column("C3",abs(ec_changes.transpose()[changes_indexes['delta_N']].values.astype(int)),center)
    worksheet.write_column("D3",abs(initial_filter_changes.transpose()[changes_indexes['delta_N']].values.astype(int)),center)
    worksheet.write_column("E3",abs(pca_changes.transpose()[changes_indexes['delta_N']].values.astype(int)),center)
    worksheet.write_column("F3",abs(clustering_changes.transpose()[changes_indexes['delta_N']].values.astype(int)),center)
    worksheet.write_column("G3",abs(final_filter_changes.transpose()[changes_indexes['delta_N']].values.astype(int)),center)
    worksheet.write_column("H3",abs(total_changes.transpose()[changes_indexes['delta_N']].values.astype(int)),center)
    # %N removed
    worksheet.write_column("K3",ec_changes.transpose()[changes_indexes['percent_diff_N']].values,two_decimal_center)
    worksheet.write_column("L3",initial_filter_changes.transpose()[changes_indexes['percent_diff_N']].values,two_decimal_center)
    worksheet.write_column("M3",pca_changes.transpose()[changes_indexes['percent_diff_N']].values,two_decimal_center)
    worksheet.write_column("N3",clustering_changes.transpose()[changes_indexes['percent_diff_N']].values,two_decimal_center)
    worksheet.write_column("O3",final_filter_changes.transpose()[changes_indexes['percent_diff_N']].values,two_decimal_center)
    worksheet.write_column("P3",total_changes.transpose()[changes_indexes['percent_diff_N']].values,two_decimal_center)
    # Mean removed
    worksheet.write_column("R3",abs(ec_changes.transpose()[changes_indexes['delta_mean']].values),two_decimal_center)
    worksheet.write_column("S3",abs(initial_filter_changes.transpose()[changes_indexes['delta_mean']].values),two_decimal_center)
    worksheet.write_column("T3",abs(pca_changes.transpose()[changes_indexes['delta_mean']].values),two_decimal_center)
    worksheet.write_column("U3",abs(clustering_changes.transpose()[changes_indexes['delta_mean']].values),two_decimal_center)
    worksheet.write_column("V3",abs(final_filter_changes.transpose()[changes_indexes['delta_mean']].values),two_decimal_center)
    worksheet.write_column("W3",abs(total_changes.transpose()[changes_indexes['delta_mean']].values),two_decimal_center)
    # %Mean removed
    worksheet.write_column("Y3",ec_changes.transpose()[changes_indexes['percent_diff_mean']].values,two_decimal_center)
    worksheet.write_column("Z3",initial_filter_changes.transpose()[changes_indexes['percent_diff_mean']].values,two_decimal_center)
    worksheet.write_column("AA3",pca_changes.transpose()[changes_indexes['percent_diff_mean']].values,two_decimal_center)
    worksheet.write_column("AB3",clustering_changes.transpose()[changes_indexes['percent_diff_mean']].values,two_decimal_center)
    worksheet.write_column("AC3",final_filter_changes.transpose()[changes_indexes['percent_diff_mean']].values,two_decimal_center)
    worksheet.write_column("AD3",total_changes.transpose()[changes_indexes['percent_diff_mean']].values,two_decimal_center)
    # SD removed
    worksheet.write_column("AF3",abs(ec_changes.transpose()[changes_indexes['delta_std']].values),two_decimal_center)
    worksheet.write_column("AG3",abs(initial_filter_changes.transpose()[changes_indexes['delta_std']].values),two_decimal_center)
    worksheet.write_column("AH3",abs(pca_changes.transpose()[changes_indexes['delta_std']].values),two_decimal_center)
    worksheet.write_column("AI3",abs(clustering_changes.transpose()[changes_indexes['delta_std']].values),two_decimal_center)
    worksheet.write_column("AJ3",abs(final_filter_changes.transpose()[changes_indexes['delta_std']].values),two_decimal_center)
    worksheet.write_column("AK3",abs(total_changes.transpose()[changes_indexes['delta_std']].values),two_decimal_center)
    # % SD removed
    worksheet.write_column("AM3",ec_changes.transpose()[changes_indexes['percent_diff_std']].values,two_decimal_center)
    worksheet.write_column("AN3",initial_filter_changes.transpose()[changes_indexes['percent_diff_std']].values,two_decimal_center)
    worksheet.write_column("AO3",pca_changes.transpose()[changes_indexes['percent_diff_std']].values,two_decimal_center)
    worksheet.write_column("AP3",clustering_changes.transpose()[changes_indexes['percent_diff_std']].values,two_decimal_center)
    worksheet.write_column("AQ3",final_filter_changes.transpose()[changes_indexes['percent_diff_std']].values,two_decimal_center)
    worksheet.write_column("AR3",total_changes.transpose()[changes_indexes['percent_diff_std']].values,two_decimal_center)

def processClusterResults(writer,workbook,sheet_name,sas_html_output,psf_png,pst2_png,k,n):
    """Process the results for PROC CLUSTER.  Determine number of clusters and write summary to Excel sheet.
    Returns the number of clusters found."""

    # There's apparently no way in SAS to write the cluster history data to a nice CSV format.
    # Have to use the html ODS and parse it from the html table into a StringIO CSV.  Oof.
    cluster_history = pd.DataFrame()
    sas_html_to_csv = StringIO.StringIO()
    soup = bs(open(sas_html_output),'html.parser')

    try:
         mytable = soup.find_all('table')[3]
    # If PROC CLUSTER can't run at all, the html table will be missing
    except IndexError:
        num_clusters = 1
        worksheet = workbook.add_worksheet(sheet_name)
        worksheet.write('A1',"No cluster history - PROC CLUSTER did not return any results.")
        worksheet.write('A2',"Assuming 1 cluster.")
        return num_clusters
    else:

        for tr in mytable.find_all('tr')[3:]:
            sas_html_to_csv.write(tr.get_text(",",strip=True))
            sas_html_to_csv.write('\n')

        sas_html_to_csv.seek(0)
        # Create a DataFrame from the StringIO CSV for sanity, write to Excel
        cluster_history = pd.read_csv(sas_html_to_csv,index_col=0,names=["NoC","CJ1","CJ2","Freq","PsF","PsT2","NFD","MD1","MD2"],dtype={'PsF':np.float64,'PsT2':np.float64},na_values=["."])
        sas_html_to_csv.close()

        # Determine Pseudo-F max and Pseudo-T^2 max, and the clustering level where they occur
        pseudo_f_max = cluster_history['PsF'].max()
        pseudo_f_max_index = cluster_history['PsF'].idxmax()
        pseudo_t2_max = cluster_history['PsT2'].max()
        pseudo_t2_max_index = cluster_history['PsT2'].idxmax()

        cluster_history.to_excel(writer,sheet_name=sheet_name)
        worksheet = writer.sheets[sheet_name]
        # Sanity check in case the plots weren't created in SAS
        if os.path.getsize(psf_png) > 0:
            worksheet.insert_image('K1',psf_png)
        if os.path.getsize(pst2_png) > 0:
            worksheet.insert_image('K32',pst2_png)

        worksheet.write(len(cluster_history.index)+4,0,"n = %s, k = %s" % (n,k))
        worksheet.write(len(cluster_history.index)+5,0,"PseudoF max is %s, Cluster Level is %s" % (pseudo_f_max,pseudo_f_max_index))
        worksheet.write(len(cluster_history.index)+6,0,"PseudoT^2 max is %s, Cluster Level is %s" % (pseudo_t2_max,pseudo_t2_max_index))

        # Determine number of clusters based on PSF/PST^2
        level_difference = pseudo_f_max_index - pseudo_t2_max_index
        worksheet.write(len(cluster_history.index)+7,0,"Level difference is %s" % (level_difference))
        num_clusters = determineNumberOfClusters(pseudo_f_max_index,pseudo_t2_max_index)
        worksheet.write(len(cluster_history.index)+8,0,"Number of clusters is %d" % num_clusters)
        return num_clusters

def generatePlot(data,nutrient,plot_title):
    """Generate the histogram/probability density plot for a given nutrient and saves it to a temporary
    file as a png.  Returns the full pathname to the file if successful, or None if no plot was created."""

    # Sanity check for too few data points
    try:
        if len(data[nutrient].dropna().values) < 2:
            print "\tWarning, cannot create plot for '%s'.  Not enough data in set." % (nutrient)
            return None
    except KeyError:
        print "\tWarning, cannot create plot for '%s'.  Nutrient not present in data." % (nutrient)

    #  Need to be sure to pass the actual values - see https://github.com/pydata/pandas/issues/6127
    try:
        n, bins, patches = plt.hist(data[nutrient].dropna().values, 15, normed=1, facecolor='lightblue', alpha=1)
        norm = mlab.normpdf(bins,data[nutrient].mean(),data[nutrient].std())
        gauss = gaussian_kde(data[nutrient].dropna(),bw_method=0.2/data[nutrient].std())
        l1,l2 = plt.plot(bins,norm,'b-',bins,gauss(bins),'r-',linewidth=2)
    except:
        print "\tWarning, error creating plot for '%s'.  Plot not created." % (nutrient)
        return None

    plt.xlabel(nutrient)
    plt.ylabel('Percent')
    plt.title("%s, $\mu=%f$, $\sigma=%f$" % (plot_title,data[nutrient].mean(),data[nutrient].std()))
    plt.legend((l1,l2),('Normal','Kernel'))
    
    (fh,fig_tempfile) = tempfile.mkstemp(suffix='.png')
    plt.savefig(fig_tempfile,format='png',delete=True)
    plt.close('all')
    os.close(fh)

    return fig_tempfile

def standardizeCvas(data):
    """Filter and standardize data from the CVAS lab."""
    mapping = { 'DryMatter' : 'DM',
                'Ash' : 'Ash',
                'Starch_DM' : 'Starch',
                'EE' : 'Fat',
                'NeutralDetergentFiber_DM' : 'NDF',
                'AcidDetergentFiber_DM' : 'ADF',
                'Lignin_DM' :  'Lignin',
                'CrudeProtein_DM' : 'CP'
                }
                
    data.rename(columns=mapping,inplace=True)
    return data

def standardizeDairyone(data):
    """Filter and standardize data from the Dairyone lab."""
    mapping = { '% Dry Matter' : 'DM',
                '% Ash' : 'Ash',
                '% Starch' : 'Starch',
                'EE' : 'Fat',
                '% Neutral Detergent Fiber' : 'NDF',
                '% Acid Detergent Fiber' : 'ADF',
                '% Lignin' :  'Lignin',
                '% Crude Protein' : 'CP'
                }
                
    data.rename(columns=mapping,inplace=True)
    return data

def standardizeDairyland(data):
    """Filter and standardize data from the Dairyland lab."""
    mapping = { 'DM, %AF' : 'DM',
                'Ash, %DM' : 'Ash',
                'Starch, %DM' : 'Starch',
                'EE, %DM' : 'Fat',
                'TFA, %DM' : 'TFA',
                'aNDF, %DM' : 'NDF',
                'ADF, %DM' : 'ADF',
                'Lignin, %DM' :  'Lignin',
                'CP, %DM' : 'CP',
                'ESC' : 'Ethanol Sol Carb',
                'Sol Protein, %CP' : 'Sol Protein',
                'NDFD30, %NDF' : 'NDFD30',
                'NDFD48, %NDF' : 'NDFD48',
                'Ca, %DM' : 'Ca',
                'P, %DM' : 'P',
                'Mg, %DM' : 'Mg',
                'K, %DM' : 'K',
                'Na, %DM' : 'Na',
                'Cl, %DM' : 'Cl',
                'S, %DM' : 'S',
                'Co, mg/kg' : 'Co',
                'Cu, mg/kg' : 'Cu',
                'Fe, mg/kg' : 'Fe',
                'Mn, mg/kg' : 'Mn',
                'Se, mg/kg' : 'Se',
                'Zn, mg/kg' : 'Zn',
                'Mo, mg/kg' : 'Mo',
                'I, mg/kg' : 'I',
                'Ace, %DM' : 'Ace',
                'Prop, %DM' : 'Prop',
                'But, %DM' : 'But',
                'Lactic, %DM' : 'Lactic'
                }

    normalize = lambda x: x*100
    data.iloc[:,range(0,23)] = data.iloc[:,range(0,23)].applymap(normalize)
    data.iloc[:,range(31,35)] = data.iloc[:,range(31,35)].applymap(normalize)
    data.rename(columns=mapping,inplace=True)
    return data  

def standardizeRockriver(data):
    """Filter and standardize data from the Rock River lab."""
    mapping = { 'fdsngNIRdm' : 'DM',
                'Ash' : 'Ash',
                'Starch' : 'Starch',
                'EE' : 'Fat',
                'aNDF' : 'NDF',
                'ADF' : 'ADF',
                'Lignin' :  'Lignin',
                'CP' : 'CP'
                }
                
    data.rename(columns=mapping,inplace=True)
    return data 
                
def standardizeL1(data):
    return data

def formatFullDataL1(worksheet):
    pass

def formatFullDataCvas(writer,sheet_name):
    writer.sheets[sheet_name].set_column('B:E', 8)
    writer.sheets[sheet_name].set_column('F:F', 18)
    writer.sheets[sheet_name].set_column('G:G', 22.50)
    writer.sheets[sheet_name].set_column('H:H', 35)
    writer.sheets[sheet_name].set_column('I:I', 5.5)
    writer.sheets[sheet_name].set_column('J:J', 29)

def formatFullDataDairyone(writer,sheet_name):
     writer.sheets[sheet_name].set_column('B:B', 8)
     writer.sheets[sheet_name].set_column('C:C', 40)
     writer.sheets[sheet_name].set_column('D:D', 8)
     writer.sheets[sheet_name].set_column('E:E', 15)
     writer.sheets[sheet_name].set_column('F:F', 18.50)

def formatFullDataDairyland(writer,sheet_name):
     writer.sheets[sheet_name].set_column('B:C', 8)
     writer.sheets[sheet_name].set_column('D:D', 22)
     writer.sheets[sheet_name].set_column('E:F', 8)
     writer.sheets[sheet_name].set_column('G:H', 16)
     writer.sheets[sheet_name].set_column('I:I', 30)
     writer.sheets[sheet_name].set_column('J:J', 11)

def formatFullDataRockriver(writer,sheet_name):
    writer.sheets[sheet_name].set_column('B:C', 8)
    writer.sheets[sheet_name].set_column('D:D', 34)
    writer.sheets[sheet_name].set_column('E:E', 10)
    writer.sheets[sheet_name].set_column('F:F', 16)
    writer.sheets[sheet_name].set_column('G:G', 21)

def determineNumberOfClusters(pseudo_f_max_index,pseudo_t2_max_index):
    """Determine the number of clusters based on where the max of PSF/PST^2 occur."""

    # Sanity check; when either PSF/PST^2 is missing/null, assume 1 cluster.
    if pd.isnull(pseudo_f_max_index) or pd.isnull(pseudo_t2_max_index):
         num_clusters = 1
         return num_clusters

    level_difference = pseudo_f_max_index - pseudo_t2_max_index
    if 1 <= level_difference <= 2:
         num_clusters = pseudo_f_max_index
    elif level_difference <= 0:
         num_clusters = 1
    elif level_difference > 2:
         num_clusters = 1

    return num_clusters

def generateClusteringScript(pca_input_csv,html_output,k,all_vars,standardized_vars,psf_graph,pst2_graph,csv_output):
    """Generate the SAS input script for cluster analysis"""

    # Convert to SAS name literals as var names may contain spaces, special characters, etc.
    all_vars_literal = [ "'%s'n" % var for var in all_vars]
    standardized_vars_literal = [ "'%s'n" % var for var in standardized_vars]

    # SAS converts spaces to underscores when reading CSV with PROC IMPORT
    # Rename using name literals to restore the correct name
    all_vars_underscores = [var.replace(' ','_') for var in all_vars if ' ' in var]
    standardized_vars_underscores = [var.replace(' ','_') for var in standardized_vars if ' ' in var]
    contains_spaces = all_vars_underscores + standardized_vars_underscores
    rename_vars = str()
    for var in contains_spaces:
         rename_vars += "%s='%s'n\n" % (var,var.replace('_',' '))

    sas_cluster_script_readcsv = """
    OPTIONS VALIDVARNAME=ANY;
        PROC IMPORT datafile="%s"
        out = princomp1
        dbms = csv
        replace;
        guessingrows = 2147483647;
        getnames=yes;
        run;
    """

    sas_cluster_script_rename_vars = """
        PROC DATASETS noprint;
        MODIFY princomp1;
              RENAME %s
           ;
        RUN;
    """

    sas_cluster_script_main = """
        ODS html file="%s";
        PROC CLUSTER DATA=princomp1 OUTTREE=tree1 METHOD=twostage
        k=%s PRINT=40 PSEUDO PLOTS(MAXPOINTS= 434);
        COPY %s;
        VAR %s ;
        RUN;
        ODS html close;

        filename psfgraph '%s';
        goptions reset=all device=png gsfname=psfgraph;

        PROC GPLOT DATA=tree1;
        PLOT _PSF_ *_NCL_;
        RUN;

        filename pstgraph '%s';
        goptions reset=all device=png gsfname=pstgraph;

        PROC GPLOT DATA=tree1;
        PLOT _PST2_ * _NCL_;
        RUN;

        PROC PRINT DATA=tree1;
        run;

        PROC EXPORT DATA=tree1
        outfile='%s'
        dbms=csv
        replace;
        run; 
    """

    if contains_spaces:
         sas_cluster_script = (sas_cluster_script_readcsv + sas_cluster_script_rename_vars + sas_cluster_script_main) % \
        (pca_input_csv,rename_vars,html_output,k,'\t\n'.join(all_vars_literal),' '.join(standardized_vars_literal),\
        psf_graph,pst2_graph,csv_output)
    else:
         sas_cluster_script = (sas_cluster_script_readcsv + sas_cluster_script_main) % (pca_input_csv,html_output,k,\
        '\t\n'.join(all_vars_literal),' '.join(standardized_vars_literal),psf_graph,pst2_graph,csv_output)

    return sas_cluster_script

def generateTreeScript(cluster_input_csv,num_clusters,csv_output,all_vars,standardized_vars):
    """Generate the SAS input script for the tree diagram procedure"""

    # Convert to SAS name literals as var names may contain spaces, special characters, etc.
    all_vars_literal = [ "'%s'n" % var for var in all_vars]
    standardized_vars_literal = [ "'%s'n" % var for var in standardized_vars]

    # SAS converts spaces to underscores when reading CSV with PROC IMPORT
    # Rename using name literals to restore the correct name
    all_vars_underscores = [var.replace(' ','_') for var in all_vars if ' ' in var]
    standardized_vars_underscores = [var.replace(' ','_') for var in standardized_vars if ' ' in var]
    contains_spaces = all_vars_underscores + standardized_vars_underscores
    rename_vars = str()
    for var in contains_spaces:
         rename_vars += "%s='%s'n\n" % (var,var.replace('_',' '))

    sas_tree_script_readcsv = """
        OPTIONS VALIDVARNAME=ANY;
        PROC IMPORT datafile="%s"
        out = tree1
        dbms = csv
        replace;
        guessingrows = 2147483647;
        getnames=yes;
    run;
    """

    sas_tree_script_rename_vars = """
        PROC DATASETS noprint;
        MODIFY tree1;
              RENAME %s
           ;
        RUN;
    """

    sas_tree_script_main = """
        PROC TREE DATA=tree1 NOPRINT OUT=out n=%s;
        COPY %s %s _dens_ _freq_ ;
        RUN;

        PROC SORT DATA=out ;
        BY CLUSTER;
        RUN;

        PROC EXPORT DATA=out
        outfile='%s'
        dbms=csv
        replace;
        run;
    """

    if contains_spaces:
         sas_tree_script = (sas_tree_script_readcsv + sas_tree_script_rename_vars + sas_tree_script_main) % \
         (cluster_input_csv,rename_vars,num_clusters,' '.join(standardized_vars_literal), '\t\n'.join(all_vars_literal),\
         csv_output)
    else:
         sas_tree_script = (sas_tree_script_readcsv + sas_tree_script_main) % (cluster_input_csv,num_clusters,\
                ' '.join(standardized_vars_literal), '\t\n'.join(all_vars_literal),csv_output)

    return sas_tree_script

# Useful links
# http://pandas-xlsxwriter-charts.readthedocs.org/en/latest/pandas.html
# http://matplotlib.org/examples/statistics/histogram_demo_features.html
# http://stackoverflow.com/questions/20656663/matplotlib-pandas-error-using-histogram

# This will be appended to the basename of the input file to create the output file
OUTPUT_FILE_SUFFIX = '-OUTPUT.xlsx'

# This will be appended to the basename of the input file to create the Excel file
# with the full dataset after each step
DATA_FILE_SUFFIX = '-DATA.xlsx'
    
# The Excel column names in 'first:last' syntax to parse for nutrients for each lab
COLUMNS_TO_PARSE = {     'L1': 'E:AH',
                         'cvas' : 'J:AR',
                         'dairyone' : 'F:AP',
                         'dairyland' : 'J:AR',
                         'rockriver' : 'K:AK'
                         }

# The Excel column names in 'first:last' syntax that contain information that will not be processed.
# Data in these columns will be appended to the full dataset output.
# NOTE:  If the list of columns is changed, the corresponding formatFullData<lab name> method will need
# changed as well.
NONDATA_COLUMNS = {     'L1' : 'A:D',
                        'cvas' : 'A:I',
                        'dairyone' : 'A:E',
                        'dairyland' : 'A:I',
                        'rockriver' : 'A:F'
                        }


# Function names by lab to format the fulldata output
FORMAT_FULLDATA_BY_LAB = {  'L1': formatFullDataL1,
                            'cvas' : formatFullDataCvas,
                            'dairyone' : formatFullDataDairyone,
                            'dairyland' : formatFullDataDairyland,
                            'rockriver' : formatFullDataRockriver
                            }

# The strings that should be parsed as missing data for each lab    
MISSING_VALUES = {  'L1' : ["0"],
                    'cvas' : ["NULL","Lodine"],
                    'dairyone' : ["0"],
                    'dairyland' : ["%", "     %", "%", "", "%Value!"],
                    'rockriver' : ["0"]
                       }


# Function names by lab to standardize data
STANDARDIZE_BY_LAB = {  'L1' : standardizeL1,
                        'cvas' : standardizeCvas,
                        'dairyone' : standardizeDairyone,
                        'dairyland' : standardizeDairyland,
                        'rockriver' : standardizeRockriver
                        }

# Numerical factor to multiply the standard deviation by to determine cutoffs
CUTOFF_FACTOR = 3.5
# Dictionary of strings to use for naming of cutoff value indexes
CUTOFF_INDEXES = {  'std'  : '%s * std' % (CUTOFF_FACTOR),
                    'low'  : 'Mean - %s * std' % (CUTOFF_FACTOR),
                    'high' : 'Mean + %s * std' % (CUTOFF_FACTOR)
               }
    
# Dictionary of strings to use for naming of changes indexes    
CHANGES_INDEXES = {     'delta_N' : u'\u0394 N',
                        'delta_mean' : u'\u0394 mean',
                        'delta_std' : u'\u0394 std',
                        'percent_diff_N' : '% diff N',
                        'percent_diff_mean' : '% diff mean',
                        'percent_diff_std' : '% diff std'
                }
    
# Dictionary of strings to use for naming the Excel sheets
SHEET_NAMES = {     'raw_summary' : 'Raw Data Summary',
                    'ec_summary' : 'Error-Corrected Data Summary',
                     'ec_pearson' : 'Error-Corrected Data Pearson',
                     'ec_plots' : 'Error-Corrected Data Plots',
                     'cutoffs' : 'Cutoffs',
                     'raw_pearson' : 'Raw Data Pearson',
                     'raw_plots' : 'Raw Data Plots',
                     'filtered_summary' : 'Filtered Data Summary',
                     'filtered_pearson' : 'Filtered Data Pearson',
                     'filtered_plots' : 'Filtered Data Plots',
                     'changes' : 'Changes',
                     'cluster_history' : 'Cluster History',
                     'cluster_filter' : 'Cluster History, round %d',
                     'cluster_summary' : 'Cluster # %d Summary, round %d',
                     'pca_results' : 'PCA Results',
                     'pca_prefilter' : 'PCA Summary, before filtering',
                     'pca_postfilter' : 'PCA Summary, after filtering',
                     'final_cutoffs' : 'Final Set Cutoffs',
                     'final' : 'Final Results',
                     'final_cluster' : 'Final Results, Cluster # %d',
                     'cutoffs_cluster' : 'Cutoffs, Cluster # %d',
                     'clusters_removed' : 'Deleted Clusters, round %d',
                     'raw_data' : 'Raw Data',
                     'ec_data' : 'Error Corrected Data',
                     'filtered_data' : 'Filtered Data',
                     'pcapf_data' : 'PCA Data, after filtering',
                     'final_cluster_data' : 'Final Cluster Data, Cluster # %d',
                     'deleted_cluster_data' : 'Deleted Cluster # %d, round %d'
                    }

# List of names for Excel sub-column headings in final changes sheet
FINAL_CHANGES_STEP_HEADINGS = ["EC","Uni","PCA","Cluster","2nd Uni","Tot"]

# Dictionary of strings for Excel column headings in final changes sheet
FINAL_CHANGES_HEADINGS = {  'startn' : 'Start N',
                            'finaln' : 'Final N',
                            'n_removed' : 'N removed',
                            'percent_n_removed' : '% N removed',
                            'mean_removed' : 'Mean removed',
                            'percent_mean_removed' : '% Mean removed',
                            'std_removed' : 'SD removed',
                            'percent_std_removed' : '% SD removed'
            }

# Principal component variable list to use, based on number of nutrient principal components
PRINCOMP_LIST = { 1 : ['Prin1'],
          2 : ['Prin1','Prin2'],
          3 : ['Prin1','Prin2','Prin3'],
          4 : ['Prin1','Prin2','Prin3','Prin4'],
          5 : ['Prin1','Prin2','Prin3','Prin4','Prin5'],
          6 : ['Prin1','Prin2','Prin3','Prin4','Prin5','Prin6']
        }

# List of columns per lab that have data in percentages, and thus cannot have values >100
PERCENTAGE_COLUMNS = {  'L1' : ['DM','Ash','TDN','DE', 'ME', 'NEM', 'NEG', 'Starch', 'Fat',\
            'NDF', 'ADF', 'Lignin', 'CP', 'RDP', 'RUP', 'Sol_Protein', 'ADIN', 'Ca',\
            'P', 'Mg', 'K', 'NA', 'Cl', 'S'],

            'cvas' : ['DM','Ash','Fat','INDF30','NDFD48','Starch Digestibility',\
            'Starch','Total Fatty Acids','NDF','ADF','Ethanol Sol Carb',\
            'Lignin','CP','Sol Protein','ADICP','NDICP','NDFD240','Ca','P','Mg',\
            'K','Na','Cl','S','Acetic Acid','Propionic Acid','Butyric Acid','Lactic Acid'],

            'dairyone' : ['DM','Ash','Starch','Fat','NDF','ADF','Sugar','Ethanol Sol Carb',\
            'Lignin','CP','Sol Protein','ADICP','NDICP','uNDFom240','NDFDom240','NDFD24',\
            'NDFD30','NDFD48','Starch Digestibility','Ca','P','Mg','K','Na','Cl','Zn','Mo',\
            'Acetic Acid','Propionic Acid','Butyric Acid','Lactic Acid'],

            'dairyland' : ['DM','Ash','Starch','Fat','TFA','NDF','ADF','WSC','Ethanol Sol Carb',\
            'Lignin','CP','Sol Protein','ADICP','NDICP','NDFD30','NDFD48','Ca','P','Mg','K','Na',\
            'Cl','S','Ace','Prop','But','Lactic'],

            'rockriver' : ['DM','Ash','Starch','Fat','NDF','ADF','Ethanol Sol Carb','Lignin',\
            'CP','Sol Protein','ADICP','NDICP','uNDF240','sNDFD30','sNDFD48','Ca','P','Mg',\
            'K','Na','Cl']
        }

# Factor (percentage) to determine if a cluster is removed
CLUSTER_REMOVAL_FACTOR = 0.10
