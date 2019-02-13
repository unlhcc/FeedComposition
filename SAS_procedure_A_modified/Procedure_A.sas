/***    Parameters creation from SYSPARM where the general syntax is
/***    parametrer=value: p1=v1,p2=v2,p3=v3...
/***    Batch call: // EXEC SAS,OPTIONS='SYSPARM="A=1,B=2"'
/***    TSO call :  %sas options(sysparm="a=1,b=2")
/***    Created by: Rick Aster, Professional SAS User Interfaces   ***/
;

/* Uncomment this line to run code in SAS GUI. */
/*
options sysparm='inputf=../Raw_data/L1_ALFALFA_CUBES.xlsx,dataname=L1_ALFALFA_CUBES';
*/

data _null_;
  length  sysparm express param value $ 200;
  sysparm = symget('sysparm');
  do i=1 to 50 until(express = '');
    express = left(scan(sysparm, i, ','));
    param   = left(upcase(scan(express, 1, '=')));
    value  = left(scan(express, 2, '='));
    valid   = not verify(substr(param, 1, 1),
                         'ABCDEFGHIJKLMNOPQRSTUVWXYZ_')
      and     not verify(trim(param),
                         'ABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789')
      and     length(param) <=8;
    if valid then call symput(param, trim(left(value)));
  end;
run;

%put Input file is  &inputf;
%put Data set name is &dataname;
%let outputxls=%sysfunc(cat(&dataname,-OUT.xls));
%let outputhtml=%sysfunc(cat(&dataname,-OUT.html));
%put Output XLS name is &outputxls;
%put Output HTML name is &outputhtml;

proc import file="&inputf" out=&dataname dbms=xlsx replace; run;
ods html close;
ods html file="&outputhtml";
Title "&dataname"; 
/* set nutrient concentrations to missing. */ 
DATA a01; 
SET &dataname;
IF DM = 0 THEN DM = '.';
IF CP = 0 THEN CP = '.'; 
IF NDF = 0 THEN NDF = '.'; 
IF Ash = 0 THEN Ash = '.'; 
IF Lignin = 0 THEN Lignin = '.'; 
IF TDN = 0 THEN TDN = '.'; 
IF DE = 0 THEN DE = '.'; 
IF ME = 0 THEN ME = '.'; 
IF NEM = 0 THEN NEM = '.'; 
IF NEG = 0 THEN NEG = '.'; 
IF Starch = 0 THEN Starch = '.'; 
IF Fat = 0 THEN Fat = '.'; 
IF ADF = 0 THEN ADF = '.'; 
IF RDP = 0 THEN RDP = '.'; 
IF RUP = 0 THEN RUP = '.'; 
IF Sol_Protein = 0 THEN Sol_Protein = '.'; 
IF ADIN = 0 THEN ADIN = '.'; 
IF Ca = 0 THEN Ca = '.'; 
IF P = 0 THEN P = '.'; 
IF Mg = 0 THEN Mg = '.'; 
IF K = 0 THEN K = '.'; 
IF NA = 0 THEN NA = '.'; 
IF Cl = 0 THEN Cl = '.'; 
IF S = 0 THEN S = '.'; 
IF Co = 0 THEN Co = '.'; 
IF Cu = 0 THEN Cu = '.'; 
IF Fe = 0 THEN Fe = '.'; 
IF Mn = 0 THEN Mn = '.'; 
IF Se = 0 THEN Se = '.'; 
IF Zn = 0 THEN Zn = '.'; 

RUN; 
PROC UNIVARIATE DATA=a01; 
VAR DM Ash TDN DE ME NEM NEG Starch Fat NDF ADF Lignin CP RDP RUP Sol_Protein ADIN Ca P Mg K NA Cl S Co Cu Fe Mn Se Zn; 
OUTPUT out=a01Means mean=DM_Mean Ash_Mean TDN_Mean DE_Mean ME_Mean NEM_Mean NEG_Mean Starch_Mean Fat_Mean NDF_Mean
ADF_Mean Lignin_Mean CP_Mean RDP_Mean RUP_Mean Sol_Protein_Mean ADIN_Mean Ca_Mean P_Mean Mg_Mean K_Mean NA_Mean
Cl_Mean S_Mean CO_Mean Cu_Mean Fe_Mean Mn_Mean Se_Mean Zn_Mean;

OUTPUT out=a01stdDev std=DM_Std Ash_Std TDN_Std DE_Std ME_Std NEM_Std NEG_Std Starch_Std Fat_Std NDF_Std ADF_Std
Lignin_Std CP_Std RDP_Std RUP_Std Sol_Protein_Std ADIN_Std Ca_Std P_Std Mg_Std K_Std NA_Std Cl_Std S_Std CO_Std
Cu_Std Fe_Std Mn_Std Se_Std Zn_Std;

OUTPUT out=a01N N=DM_N Ash_N TDN_N DE_N ME_N NEM_N NEG_N Starch_N Fat_N NDF_N
ADF_N Lignin_N CP_N RDP_N RUP_N Sol_Protein_N ADIN_N Ca_N P_N Mg_N K_N NA_N
Cl_N S_N CO_N Cu_N Fe_N Mn_N Se_N Zn_N;

RUN; 

DATA _null_;
  set a01Means;
  call symput("dm_mean_mac",DM_Mean);
  call symput("ash_mean_mac",Ash_Mean);
  call symput("tdn_mean_mac",TDN_Mean);
  call symput("de_mean_mac",DE_Mean);
  call symput("me_mean_mac",ME_Mean);
  call symput("nem_mean_mac",NEM_Mean);
  call symput("neg_mean_mac",NEG_Mean);
  call symput("starch_mean_mac",Starch_Mean);
  call symput("fat_mean_mac",Fat_Mean);
  call symput("ndf_mean_mac",NDF_Mean);
  call symput("adf_mean_mac",ADF_Mean);
  call symput("lignin_mean_mac",Lignin_Mean);
  call symput("cp_mean_mac",CP_Mean);
  call symput("rdp_mean_mac",RDP_Mean);
  call symput("rup_mean_mac",RUP_Mean);
  call symput("sol_protein_mean_mac",Sol_Protein_Mean);
  call symput("adin_mean_mac",ADIN_Mean);
  call symput("ca_mean_mac",Ca_Mean);
  call symput("p_mean_mac",P_Mean);
  call symput("mg_mean_mac",Mg_Mean);
  call symput("k_mean_mac",K_Mean);
  call symput("na_mean_mac",NA_Mean);
  call symput("cl_mean_mac",Cl_Mean);
  call symput("s_mean_mac",S_Mean);
  call symput("co_mean_mac",CO_Mean);
  call symput("cu_mean_mac",Cu_Mean);
  call symput("fe_mean_mac",Fe_Mean);
  call symput("mn_mean_mac",Mn_Mean);
  call symput("se_mean_mac",Se_Mean);
  call symput("zn_mean_mac",Zn_Mean);
run;

DATA _null_;
  set a01stdDev;
  call symput("dm_std_mac",DM_Std);
  call symput("ash_std_mac",Ash_Std);
  call symput("tdn_std_mac",TDN_Std);
  call symput("de_std_mac",DE_Std);
  call symput("me_std_mac",ME_Std);
  call symput("nem_std_mac",NEM_Std);
  call symput("neg_std_mac",NEG_Std);
  call symput("starch_std_mac",Starch_Std);
  call symput("fat_std_mac",Fat_Std);
  call symput("ndf_std_mac",NDF_Std);
  call symput("adf_std_mac",ADF_Std);
  call symput("lignin_std_mac",Lignin_Std);
  call symput("cp_std_mac",CP_Std);
  call symput("rdp_std_mac",RDP_Std);
  call symput("rup_std_mac",RUP_Std);
  call symput("sol_protein_std_mac",Sol_Protein_Std);
  call symput("adin_std_mac",ADIN_Std);
  call symput("ca_std_mac",Ca_Std);
  call symput("p_std_mac",P_Std);
  call symput("mg_std_mac",Mg_Std);
  call symput("k_std_mac",K_Std);
  call symput("na_std_mac",NA_Std);
  call symput("cl_std_mac",Cl_Std);
  call symput("s_std_mac",S_Std);
  call symput("co_std_mac",CO_Std);
  call symput("cu_std_mac",Cu_Std);
  call symput("fe_std_mac",Fe_Std);
  call symput("mn_std_mac",Mn_Std);
  call symput("se_std_mac",Se_Std);
  call symput("zn_std_mac",Zn_Std);
run;

DATA _null_;
  set a01N;
  call symput("dm_n_mac",DM_N);
  call symput("ash_n_mac",Ash_N);
  call symput("tdn_n_mac",TDN_N);
  call symput("de_n_mac",DE_N);
  call symput("me_n_mac",ME_N);
  call symput("nem_n_mac",NEM_N);
  call symput("neg_n_mac",NEG_N);
  call symput("starch_n_mac",Starch_N);
  call symput("fat_n_mac",Fat_N);
  call symput("ndf_n_mac",NDF_N);
  call symput("adf_n_mac",ADF_N);
  call symput("lignin_n_mac",Lignin_N);
  call symput("cp_n_mac",CP_N);
  call symput("rdp_n_mac",RDP_N);
  call symput("rup_n_mac",RUP_N);
  call symput("sol_protein_n_mac",Sol_Protein_N);
  call symput("adin_n_mac",ADIN_N);
  call symput("ca_n_mac",Ca_N);
  call symput("p_n_mac",P_N);
  call symput("mg_n_mac",Mg_N);
  call symput("k_n_mac",K_N);
  call symput("na_n_mac",NA_N);
  call symput("cl_n_mac",Cl_N);
  call symput("s_n_mac",S_N);
  call symput("co_n_mac",CO_N);
  call symput("cu_n_mac",Cu_N);
  call symput("fe_n_mac",Fe_N);
  call symput("mn_n_mac",Mn_N);
  call symput("se_n_mac",Se_N);
  call symput("zn_n_mac",Zn_N);
run;

ODS TAGSETS.EXCELXP
file="&outputxls"
STYLE=minimal
OPTIONS ( Orientation = 'landscape'
FitToPage = 'yes'
Pages_FitWidth = '1'
Pages_FitHeight = '100' );


PROC CORR DATA=a01;
VAR DM Ash TDN DE ME NEM NEG Starch Fat NDF ADF Lignin CP RDP RUP Sol_Protein ADIN Ca P Mg K NA Cl S Co Cu Fe Mn Se Zn;
RUN;


PROC CORR DATA=a01; 
VAR DM Ash TDN DE ME NEM NEG Starch Fat NDF ADF Lignin CP RDP RUP Sol_Protein ADIN Ca P;
RUN; 

ODS PDF FILE = "&dataname-PLOT-1.pdf";
proc sgplot data=a01 nocycleattrs;
  histogram  DM;
  density DM ;
  density DM / type=kernel;
  keylegend / location = inside position = topright; 
run;
ODS PDF CLOSE;

ODS PDF FILE = "&dataname-PLOT-2.pdf";
proc sgplot data=a01 nocycleattrs;
  histogram  CP;
  density CP ;
  density CP / type=kernel;
  keylegend / location = inside position = topright; 
run;
ODS PDF CLOSE;

/*remove extreme values based on output of 1% quantile*/
DATA a01a; 
SET a01; 
IF DM < (&dm_mean_mac-(3.5*&dm_std_mac)) or DM > (&dm_mean_mac+(3.5*&dm_std_mac)) THEN DM ='.';
IF ASH < (&ash_mean_mac-(3.5*&ash_std_mac)) or ASH > (&ash_mean_mac+(3.5*&ash_std_mac)) THEN ASH ='.';
IF TDN < (&tdn_mean_mac-(3.5*&tdn_std_mac)) or TDN > (&tdn_mean_mac+(3.5*&tdn_std_mac)) THEN TDN = '.'; 
IF DE < (&de_mean_mac-(3.5*&de_std_mac)) or DE > (&de_mean_mac+(3.5*&de_std_mac)) THEN DE = '.'; 
IF ME < (&me_mean_mac-(3.5*&me_std_mac)) or ME > (&me_mean_mac+(3.5*&me_std_mac)) THEN ME = '.'; 
IF NEM < (&nem_mean_mac-(3.5*&nem_std_mac)) or NEM > (&nem_mean_mac+(3.5*&nem_std_mac)) THEN NEM = '.'; 
IF NEG < (&neg_mean_mac-(3.5*&neg_std_mac)) or NEG > (&neg_mean_mac+(3.5*&neg_std_mac)) THEN NEG = '.'; 
IF Starch < (&starch_mean_mac-(3.5*&starch_std_mac)) or STARCH > (&starch_mean_mac+(3.5*&starch_std_mac)) THEN Starch = '.'; 
IF Fat < (&fat_mean_mac-(3.5*&fat_std_mac)) or FAT > (&fat_mean_mac+(3.5*&fat_std_mac)) THEN Fat = '.'; 
IF NDF < (&ndf_mean_mac-(3.5*&ndf_std_mac)) or NDF > (&ndf_mean_mac+(3.5*&ndf_std_mac)) THEN NDF = '.'; 
IF ADF < (&adf_mean_mac-(3.5*&adf_std_mac)) or ADF > (&adf_mean_mac+(3.5*&adf_std_mac)) THEN ADF = '.'; 
IF CP < (&cp_mean_mac-(3.5*&cp_std_mac)) or CP > (&cp_mean_mac+(3.5*&cp_std_mac)) THEN CP='.';
IF ADIN < (&adin_mean_mac-(3.5*&adin_std_mac)) or ADIN > (&adin_mean_mac+(3.5*&adin_std_mac)) THEN ADIN = '.'; 
IF Ca < (&ca_mean_mac-(3.5*&ca_std_mac)) or Ca > (&ca_mean_mac+(3.5*&ca_std_mac)) THEN Ca = '.'; 
IF P < (&p_mean_mac-(3.5*&p_std_mac)) or P > (&p_mean_mac+(3.5*&p_std_mac)) THEN P = '.'; 
IF Mg < (&mg_mean_mac-(3.5*&mg_std_mac)) or Mg > (&mg_mean_mac+(3.5*&mg_std_mac)) THEN Mg = '.'; 
IF NA < (&na_mean_mac-(3.5*&na_std_mac)) or NA > (&na_mean_mac+(3.5*&na_std_mac)) THEN NA = '.'; 
IF Cu < (&cu_mean_mac-(3.5*&cu_std_mac)) or Cu > (&cu_mean_mac+(3.5*&cu_std_mac)) THEN Cu = '.'; 
IF Fe < (&fe_mean_mac-(3.5*&fe_std_mac)) or Fe > (&fe_mean_mac+(3.5*&fe_std_mac)) THEN Fe = '.'; 
IF Mn < (&mn_mean_mac-(3.5*&mn_std_mac)) or Mn > (&mn_mean_mac+(3.5*&mn_std_mac)) THEN Mn = '.'; 
IF Zn < (&zn_mean_mac-(3.5*&zn_std_mac)) or Zn > (&zn_mean_mac+(3.5*&zn_std_mac)) THEN Zn = '.'; 
RUN;

DATA cutoffs;
        LENGTH Variable $12 stddev_mac $21 mean_mac $21;
	INPUT Variable= stddev_mac=  mean_mac= ;
	sd35=dequote(resolve(quote(stddev_mac)))*3.5;
	mean_minus35=dequote(resolve(quote(mean_mac)))-3.5*dequote(resolve(quote(stddev_mac)));
	mean_plus35=dequote(resolve(quote(mean_mac)))+3.5*dequote(resolve(quote(stddev_mac)));
	DATALINES;
Variable=DM stddev_mac=&dm_std_mac mean_mac=&dm_mean_mac
Variable=ASH stddev_mac=&ash_std_mac mean_mac=&ash_mean_mac
Variable=TDN stddev_mac=&tdn_std_mac mean_mac=&tdn_mean_mac
Variable=DE stddev_mac=&de_std_mac mean_mac=&de_mean_mac
Variable=ME stddev_mac=&me_std_mac mean_mac=&me_mean_mac
Variable=NEM stddev_mac=&nem_std_mac mean_mac=&nem_mean_mac
Variable=NEG stddev_mac=&neg_std_mac mean_mac=&neg_mean_mac
Variable=Starch stddev_mac=&starch_std_mac mean_mac=&starch_mean_mac
Variable=Fat stddev_mac=&fat_std_mac mean_mac=&fat_mean_mac
Variable=NDF stddev_mac=&ndf_std_mac mean_mac=&ndf_mean_mac
Variable=ADF stddev_mac=&adf_std_mac mean_mac=&adf_mean_mac
Variable=Lignin stddev_mac=&lignin_std_mac mean_mac=&lignin_mean_mac
Variable=CP stddev_mac=&cp_std_mac mean_mac=&cp_mean_mac
Variable=RDP stddev_mac=&rdp_std_mac mean_mac=&rdp_mean_mac
Variable=RUP stddev_mac=&rup_std_mac mean_mac=&rup_mean_mac
Variable=Sol_Protein stddev_mac=&sol_protein_std_mac mean_mac=&sol_protein_mean_mac
Variable=ADIN stddev_mac=&adin_std_mac mean_mac=&adin_mean_mac
Variable=Ca stddev_mac=&ca_std_mac mean_mac=&ca_mean_mac
Variable=P stddev_mac=&p_std_mac mean_mac=&p_mean_mac
Variable=Mg stddev_mac=&mg_std_mac mean_mac=&mg_mean_mac
Variable=K stddev_mac=&k_std_mac mean_mac=&k_mean_mac
Variable=NA stddev_mac=&na_std_mac mean_mac=&na_mean_mac
Variable=Cl stddev_mac=&cl_std_mac mean_mac=&cl_mean_mac
Variable=S stddev_mac=&s_std_mac mean_mac=&s_mean_mac
Variable=Co stddev_mac=&co_std_mac mean_mac=&co_mean_mac
Variable=Cu stddev_mac=&cu_std_mac mean_mac=&cu_mean_mac
Variable=Fe stddev_mac=&fe_std_mac mean_mac=&fe_mean_mac
Variable=Mn stddev_mac=&mn_std_mac mean_mac=&mn_mean_mac
Variable=Se stddev_mac=&se_std_mac mean_mac=&se_mean_mac
Variable=Zn stddev_mac=&zn_std_mac mean_mac=&zn_mean_mac
;
run;


ODS PDF FILE = "&dataname-PLOT-3.pdf";
proc sgplot data=a01a nocycleattrs;
  histogram  CP;
  density CP ;
  density CP/ type=kernel;
  keylegend / location = inside position = topright; 
run;
ODS PDF CLOSE;

PROC univariate DATA=a01a; 
VAR DM Ash TDN DE ME NEM NEG Starch Fat NDF ADF Lignin CP RDP RUP Sol_Protein ADIN Ca P Mg K NA Cl S Co Cu Fe Mn Se Zn; 

OUTPUT out=a01aMeans mean=DM_Mean2 Ash_Mean2 TDN_Mean2 DE_Mean2 ME_Mean2 NEM_Mean2 NEG_Mean2 Starch_Mean2 Fat_Mean2 NDF_Mean2
ADF_Mean2 Lignin_Mean2 CP_Mean2 RDP_Mean2 RUP_Mean2 Sol_Protein_Mean2 ADIN_Mean2 Ca_Mean2 P_Mean2 Mg_Mean2 K_Mean2 NA_Mean2
Cl_Mean2 S_Mean2 CO_Mean2 Cu_Mean2 Fe_Mean2 Mn_Mean2 Se_Mean2 Zn_Mean2;

OUTPUT out=a01astdDev std=DM_Std2 Ash_Std2 TDN_Std2 DE_Std2 ME_Std2 NEM_Std2 NEG_Std2 Starch_Std2 Fat_Std2 NDF_Std2 ADF_Std2
Lignin_Std2 CP_Std2 RDP_Std2 RUP_Std2 Sol_Protein_Std2 ADIN_Std2 Ca_Std2 P_Std2 Mg_Std2 K_Std2 NA_Std2 Cl_Std2 S_Std2 CO_Std2
Cu_Std2 Fe_Std2 Mn_Std2 Se_Std2 Zn_Std2;

OUTPUT out=a01aN N=DM_N2 Ash_N2 TDN_N2 DE_N2 ME_N2 NEM_N2 NEG_N2 Starch_N2 Fat_N2 NDF_N2
ADF_N2 Lignin_N2 CP_N2 RDP_N2 RUP_N2 Sol_Protein_N2 ADIN_N2 Ca_N2 P_N2 Mg_N2 K_N2 NA_N2
Cl_N2 S_N2 CO_N2 Cu_N2 Fe_N2 Mn_N2 Se_N2 Zn_N2;
RUN;

DATA _null_;
  set a01aMeans;
  call symput("dm_mean_mac2",DM_Mean2);
  call symput("ash_mean_mac2",Ash_Mean2);
  call symput("tdn_mean_mac2",TDN_Mean2);
  call symput("de_mean_mac2",DE_Mean2);
  call symput("me_mean_mac2",ME_Mean2);
  call symput("nem_mean_mac2",NEM_Mean2);
  call symput("neg_mean_mac2",NEG_Mean2);
  call symput("starch_mean_mac2",Starch_Mean2);
  call symput("fat_mean_mac2",Fat_Mean2);
  call symput("ndf_mean_mac2",NDF_Mean2);
  call symput("adf_mean_mac2",ADF_Mean2);
  call symput("lignin_mean_mac2",Lignin_Mean2);
  call symput("cp_mean_mac2",CP_Mean2);
  call symput("rdp_mean_mac2",RDP_Mean2);
  call symput("rup_mean_mac2",RUP_Mean2);
  call symput("sol_protein_mean_mac2",Sol_Protein_Mean2);
  call symput("adin_mean_mac2",ADIN_Mean2);
  call symput("ca_mean_mac2",Ca_Mean2);
  call symput("p_mean_mac2",P_Mean2);
  call symput("mg_mean_mac2",Mg_Mean2);
  call symput("k_mean_mac2",K_Mean2);
  call symput("na_mean_mac2",NA_Mean2);
  call symput("cl_mean_mac2",Cl_Mean2);
  call symput("s_mean_mac2",S_Mean2);
  call symput("co_mean_mac2",CO_Mean2);
  call symput("cu_mean_mac2",Cu_Mean2);
  call symput("fe_mean_mac2",Fe_Mean2);
  call symput("mn_mean_mac2",Mn_Mean2);
  call symput("se_mean_mac2",Se_Mean2);
  call symput("zn_mean_mac2",Zn_Mean2);
run;

DATA _null_;
  set a01astdDev;
  call symput("dm_std_mac2",DM_Std2);
  call symput("ash_std_mac2",Ash_Std2);
  call symput("tdn_std_mac2",TDN_Std2);
  call symput("de_std_mac2",DE_Std2);
  call symput("me_std_mac2",ME_Std2);
  call symput("nem_std_mac2",NEM_Std2);
  call symput("neg_std_mac2",NEG_Std2);
  call symput("starch_std_mac2",Starch_Std2);
  call symput("fat_std_mac2",Fat_Std2);
  call symput("ndf_std_mac2",NDF_Std2);
  call symput("adf_std_mac2",ADF_Std2);
  call symput("lignin_std_mac2",Lignin_Std2);
  call symput("cp_std_mac2",CP_Std2);
  call symput("rdp_std_mac2",RDP_Std2);
  call symput("rup_std_mac2",RUP_Std2);
  call symput("sol_protein_std_mac2",Sol_Protein_Std2);
  call symput("adin_std_mac2",ADIN_Std2);
  call symput("ca_std_mac2",Ca_Std2);
  call symput("p_std_mac2",P_Std2);
  call symput("mg_std_mac2",Mg_Std2);
  call symput("k_std_mac2",K_Std2);
  call symput("na_std_mac2",NA_Std2);
  call symput("cl_std_mac2",Cl_Std2);
  call symput("s_std_mac2",S_Std2);
  call symput("co_std_mac2",CO_Std2);
  call symput("cu_std_mac2",Cu_Std2);
  call symput("fe_std_mac2",Fe_Std2);
  call symput("mn_std_mac2",Mn_Std2);
  call symput("se_std_mac2",Se_Std2);
  call symput("zn_std_mac2",Zn_Std2);
run;

DATA _null_;
  set a01aN;
  call symput("dm_n_mac2",DM_N2);
  call symput("ash_n_mac2",Ash_N2);
  call symput("tdn_n_mac2",TDN_N2);
  call symput("de_n_mac2",DE_N2);
  call symput("me_n_mac2",ME_N2);
  call symput("nem_n_mac2",NEM_N2);
  call symput("neg_n_mac2",NEG_N2);
  call symput("starch_n_mac2",Starch_N2);
  call symput("fat_n_mac2",Fat_N2);
  call symput("ndf_n_mac2",NDF_N2);
  call symput("adf_n_mac2",ADF_N2);
  call symput("lignin_n_mac2",Lignin_N2);
  call symput("cp_n_mac2",CP_N2);
  call symput("rdp_n_mac2",RDP_N2);
  call symput("rup_n_mac2",RUP_N2);
  call symput("sol_protein_n_mac2",Sol_Protein_N2);
  call symput("adin_n_mac2",ADIN_N2);
  call symput("ca_n_mac2",Ca_N2);
  call symput("p_n_mac2",P_N2);
  call symput("mg_n_mac2",Mg_N2);
  call symput("k_n_mac2",K_N2);
  call symput("na_n_mac2",NA_N2);
  call symput("cl_n_mac2",Cl_N2);
  call symput("s_n_mac2",S_N2);
  call symput("co_n_mac2",CO_N2);
  call symput("cu_n_mac2",Cu_N2);
  call symput("fe_n_mac2",Fe_N2);
  call symput("mn_n_mac2",Mn_N2);
  call symput("se_n_mac2",Se_N2);
  call symput("zn_n_mac2",Zn_N2);
run;

DATA changes;
        LENGTH Variable $12 n_mac $21 n_mac2 $21 stddev_mac $21 stddev_mac2 $21 mean_mac $21 mean_mac2 $21;
        INPUT Variable= n_mac=  n_mac2= stddev_mac= stddev_mac2= mean_mac= mean_mac2=;
        delta_n=dequote(resolve(quote(n_mac2)))-dequote(resolve(quote(n_mac)));
	percent_n=100*(dequote(resolve(quote(n_mac2)))-dequote(resolve(quote(n_mac))))/dequote(resolve(quote(n_mac)));
	delta_mean=dequote(resolve(quote(mean_mac2)))-dequote(resolve(quote(mean_mac)));
	percent_mean=100*(dequote(resolve(quote(mean_mac2)))-dequote(resolve(quote(mean_mac))))/dequote(resolve(quote(mean_mac)));
	delta_sd=dequote(resolve(quote(stddev_mac2)))-dequote(resolve(quote(stddev_mac)));
	percent_sd=100*(dequote(resolve(quote(stddev_mac2)))-dequote(resolve(quote(stddev_mac))))/dequote(resolve(quote(stddev_mac)));
        DATALINES;
Variable=DM n_mac=&dm_n_mac n_mac2=&dm_n_mac2 stddev_mac=&dm_std_mac stddev_mac2=&dm_std_mac2 mean_mac=&dm_mean_mac mean_mac2=&dm_mean_mac2
Variable=ASH n_mac=&ash_n_mac n_mac2=&ash_n_mac2 stddev_mac=&ash_std_mac stddev_mac2=&ash_std_mac2 mean_mac=&ash_mean_mac mean_mac2=&ash_mean_mac2
Variable=TDN n_mac=&tdn_n_mac n_mac2=&tdn_n_mac2 stddev_mac=&tdn_std_mac stddev_mac2=&tdn_std_mac2 mean_mac=&tdn_mean_mac mean_mac2=&tdn_mean_mac2
Variable=DE n_mac=&de_n_mac n_mac2=&de_n_mac2 stddev_mac=&de_std_mac stddev_mac2=&de_std_mac2 mean_mac=&de_mean_mac mean_mac2=&de_mean_mac2
Variable=ME n_mac=&me_n_mac n_mac2=&me_n_mac2 stddev_mac=&me_std_mac stddev_mac2=&me_std_mac2 mean_mac=&me_mean_mac mean_mac2=&me_mean_mac2
Variable=NEM n_mac=&nem_n_mac n_mac2=&nem_n_mac2 stddev_mac=&nem_std_mac stddev_mac2=&nem_std_mac2 mean_mac=&nem_mean_mac mean_mac2=&nem_mean_mac2
Variable=NEG n_mac=&neg_n_mac n_mac2=&neg_n_mac2 stddev_mac=&neg_std_mac stddev_mac2=&neg_std_mac2 mean_mac=&neg_mean_mac mean_mac2=&neg_mean_mac2
Variable=Starch n_mac=&starch_n_mac n_mac2=&starch_n_mac2 stddev_mac=&starch_std_mac stddev_mac2=&starch_std_mac2 mean_mac=&starch_mean_mac mean_mac2=&starch_mean_mac2
Variable=Fat n_mac=&fat_n_mac n_mac2=&fat_n_mac2 stddev_mac=&fat_std_mac stddev_mac2=&fat_std_mac2 mean_mac=&fat_mean_mac mean_mac2=&fat_mean_mac2
Variable=NDF n_mac=&ndf_n_mac n_mac2=&ndf_n_mac2 stddev_mac=&ndf_std_mac stddev_mac2=&ndf_std_mac2 mean_mac=&ndf_mean_mac mean_mac2=&ndf_mean_mac2
Variable=ADF n_mac=&adf_n_mac n_mac2=&adf_n_mac2 stddev_mac=&adf_std_mac stddev_mac2=&adf_std_mac2 mean_mac=&adf_mean_mac mean_mac2=&adf_mean_mac2
Variable=Lignin n_mac=&lignin_n_mac n_mac2=&lignin_n_mac2 stddev_mac=&lignin_std_mac stddev_mac2=&lignin_std_mac2 mean_mac=&lignin_mean_mac mean_mac2=&lignin_mean_mac2
Variable=CP n_mac=&cp_n_mac n_mac2=&cp_n_mac2 stddev_mac=&cp_std_mac stddev_mac2=&cp_std_mac2 mean_mac=&cp_mean_mac mean_mac2=&cp_mean_mac2
Variable=RDP n_mac=&rdp_n_mac n_mac2=&rdp_n_mac2 stddev_mac=&rdp_std_mac stddev_mac2=&rdp_std_mac2 mean_mac=&rdp_mean_mac mean_mac2=&rdp_mean_mac2
Variable=RUP n_mac=&rup_n_mac n_mac2=&rup_n_mac2 stddev_mac=&rup_std_mac stddev_mac2=&rup_std_mac2 mean_mac=&rup_mean_mac mean_mac2=&rup_mean_mac2
Variable=Sol_Protein n_mac=&sol_protein_n_mac n_mac2=&sol_protein_n_mac2 stddev_mac=&sol_protein_std_mac stddev_mac2=&sol_protein_std_mac2 mean_mac=&sol_protein_mean_mac mean_mac2=&sol_protein_mean_mac2
Variable=ADIN n_mac=&adin_n_mac n_mac2=&adin_n_mac2 stddev_mac=&adin_std_mac stddev_mac2=&adin_std_mac2 mean_mac=&adin_mean_mac mean_mac2=&adin_mean_mac2
Variable=Ca n_mac=&ca_n_mac n_mac2=&ca_n_mac2 stddev_mac=&ca_std_mac stddev_mac2=&ca_std_mac2 mean_mac=&ca_mean_mac mean_mac2=&ca_mean_mac2
Variable=P n_mac=&p_n_mac n_mac2=&p_n_mac2 stddev_mac=&p_std_mac stddev_mac2=&p_std_mac2 mean_mac=&p_mean_mac mean_mac2=&p_mean_mac2
Variable=Mg n_mac=&mg_n_mac n_mac2=&mg_n_mac2 stddev_mac=&mg_std_mac stddev_mac2=&mg_std_mac2 mean_mac=&mg_mean_mac mean_mac2=&mg_mean_mac2
Variable=K n_mac=&k_n_mac n_mac2=&k_n_mac2 stddev_mac=&k_std_mac stddev_mac2=&k_std_mac2 mean_mac=&k_mean_mac mean_mac2=&k_mean_mac2
Variable=NA n_mac=&na_n_mac n_mac2=&na_n_mac2 stddev_mac=&na_std_mac stddev_mac2=&na_std_mac2 mean_mac=&na_mean_mac mean_mac2=&na_mean_mac2
Variable=Cl n_mac=&cl_n_mac n_mac2=&cl_n_mac2 stddev_mac=&cl_std_mac stddev_mac2=&cl_std_mac2 mean_mac=&cl_mean_mac mean_mac2=&cl_mean_mac2
Variable=S n_mac=&s_n_mac n_mac2=&s_n_mac2 stddev_mac=&s_std_mac stddev_mac2=&s_std_mac2 mean_mac=&s_mean_mac mean_mac2=&s_mean_mac2
Variable=Co n_mac=&co_n_mac n_mac2=&co_n_mac2 stddev_mac=&co_std_mac stddev_mac2=&co_std_mac2 mean_mac=&co_mean_mac mean_mac2=&co_mean_mac2
Variable=Cu n_mac=&cu_n_mac n_mac2=&cu_n_mac2 stddev_mac=&cu_std_mac stddev_mac2=&cu_std_mac2 mean_mac=&cu_mean_mac mean_mac2=&cu_mean_mac2
Variable=Fe n_mac=&fe_n_mac n_mac2=&fe_n_mac2 stddev_mac=&fe_std_mac stddev_mac2=&fe_std_mac2 mean_mac=&fe_mean_mac mean_mac2=&fe_mean_mac2
Variable=Mn n_mac=&mn_n_mac n_mac2=&mn_n_mac2 stddev_mac=&mn_std_mac stddev_mac2=&mn_std_mac2 mean_mac=&mn_mean_mac mean_mac2=&mn_mean_mac2
Variable=Se n_mac=&se_n_mac n_mac2=&se_n_mac2 stddev_mac=&se_std_mac stddev_mac2=&se_std_mac2 mean_mac=&se_mean_mac mean_mac2=&se_mean_mac2
Variable=Zn n_mac=&zn_n_mac n_mac2=&zn_n_mac2 stddev_mac=&zn_std_mac stddev_mac2=&zn_std_mac2 mean_mac=&zn_mean_mac mean_mac2=&zn_mean_mac2
;
run;

PROC corr DATA=a01a; 
VAR DM Ash TDN DE ME NEM NEG Starch Fat NDF ADF Lignin CP RDP RUP Sol_Protein ADIN Ca P Mg K NA Cl S Co Cu Fe Mn Se Zn; 
RUN;
PROC corr DATA=a01A; 
VAR DM Ash TDN DE ME NEM NEG Starch Fat NDF ADF Lignin CP RDP RUP Sol_Protein ADIN Ca P;
RUN;

PROC PRINT DATA=cutoffs;
var Variable sd35 mean_minus35 mean_plus35;
run;

PROC PRINT DATA=changes;
var Variable delta_n percent_n delta_mean percent_mean delta_sd percent_sd;
run;

ods tagsets.excelxp close;

