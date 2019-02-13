proc import file='C:\Users\Huyen Tran\Documents\NANP\BeefNRC\L1.test\L1_CORN_SILAGE.xlsx' out=L1_CORN_SILAGE dbms=xlsx replace; run;
ods html close;
ods html;
Title "LAB 1 DAIRYONE RAW DATA WITHIN L1_CORN_SILAGE."; 
/* set nutrient concentrations to missing. */ 
DATA a01; 
SET L1_CORN_SILAGE;
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
PROC univariate DATA=a01; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN; 
proc corr data = a01;
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN; 
proc sgplot data=a01;
  histogram  DM;
  density DM;
  density DM / type=kernel;
  keylegend / location = inside position = topright; 
run;


/* STEP 1: Remove nutrient concentrations 3.5 STD units from the mean. */ 
/* ----------------------------------------------------------------------*/ 
/* Values in this step are typed in the code from the output of */ 
/* PROC UNIVARIATE. */ 
/* This step could be programmed from the output to increase automation. */ 
/* This wasn’t done here to improve the clarity of the code. */ 

DATA a01_a; 
SET a01; 
IF dm > 70 THEN DELETE; 
IF Ash > 8.64 THEN DELETE; 
IF CP < 4.57 or CP > 11.93 THEN DELETE; 
IF NDF < 22.89 or NDF > 63.32 THEN DELETE; 
IF STARCH < 6.93 or STARCH > 57.96 THEN DELETE; 
IF LIGNIN < 0.9 or LIGNIN > 5.47 THEN DELETE; 
run;


proc univariate DATA=a01_a;
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;
proc corr DATA=a01_a;
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
run;

proc corr DATA=a01_a;
VAR DM	Ash	CP NDF Starch Lignin; 
run;
DATA a01_b; 
SET a01_a; 
zDM = dm; 
zAsh = ash; 
zCP = cp; 
zNDF = ndf; 
zSTARCH = STARCH;
zLIGNIN = LIGNIN;
RUN; 
/* Standardize all nutrient concentrations */ 
PROC STANDARD DATA=a01_b MEAN=0 STD=1 OUT=stand_a01; 
VAR zDM zCP zNDF zASH zSTARCH zLIGNIN; 
RUN;
/* Prin. component analysis using the cov option */ 

PROC PRINCOMP DATA=stand_a01 COV OUT=a01_princomp; 
VAR zDM zCP zNDF zASH zSTARCH zLIGNIN; 
RUN;
PROC UNIVARIATE DATA=a01_princomp; 
VAR Prin1 Prin2 Prin3 Prin4 Prin5 Prin6; 
RUN;
PROC corr DATA=a01_princomp; 
VAR Prin1 Prin2 Prin3 Prin4  Prin5 Prin6; 
RUN;
/* STEP 2: Remove PCA scores that are 3.5 STD from the mean. */ 
/* ----------------------------------------------------------------------*/ 
/* Values in this step are typed in the code from the output of */ 
/* PROC UNIVARIATE. */ 
/* This step could be programmed from the output to increase automation. */ 
/* This wasn’t done here to improve the clarity of the code. */ 
DATA a01_princomp1; 
SET a01_princomp; 
IF Prin1 < -6.29 or Prin1 > 6.29 THEN DELETE; 
IF Prin2 < -3.54 or Prin2 > 3.54 THEN DELETE; 
IF Prin3 < -3.03 or Prin3 > 3.03 THEN DELETE; 
IF Prin4 < -2.66 or Prin4 > 2.66 THEN DELETE; 
IF Prin5 < -2.14 or Prin5 > 2.14 THEN DELETE; 
IF Prin6 < -0.80 or Prin6 > 0.80 THEN DELETE; 
RUN; 
proc CORR DATA=a01_princomp1;
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;
proc CORR DATA=a01_princomp1;
VAR DM	Ash	CP NDF Starch Lignin; 
RUN;

/* Two stage cluster analysis, k = n^0.3 */ 
PROC CLUSTER DATA=a01_princomp1 OUTTREE=tree1 METHOD=twostage 
k=36 PRINT=40 PSEUDO;
copy DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
VAR zDM zAsh zCP zNDF zStarch zLignin; 
RUN; 

PROC GPLOT DATA=tree1; 
/* Repeat gplot of tree1 two times, once for PSF and once for PST2. */ 
PLOT _PSF_ *_NCL_; 
RUN; 


/* Determine number of clusters from PSF and PST2 maximum values. */ 
PROC TREE DATA=tree1 NOPRINT OUT=out n=1; 
COPY zCP zNDF zDM zAsh zStarch zLignin DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn
_dens_ _freq_; 
RUN; 
PROC SORT DATA=out; 
BY CLUSTER; 
RUN; 
PROC CORR DATA=out; 
BY CLUSTER; 
VAR DM Ash CP NDF starch Lignin; 
RUN; 
PROC CORR DATA=out; 
BY CLUSTER; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;
/* ONLY 1 CLUSTER IDENTIFIED*/
/* removed 3.5 SD on all nutrients in the final step*/


DATA final; 
SET out;
if DM < 14.29 or DM > 51.71 then DM ='.';
if Ash < 0.49 or Ash > 7.9 then Ash ='.';
IF TDN < 59.99 or TDN > 76.3 THEN TDN = '.'; 
IF DE > 2.62 THEN DE = '.'; 
IF ME < 2.2 or ME > 2.88 THEN ME = '.'; 
IF NEM < 1.19 or NEM > 2.13 THEN NEM = '.'; 
IF NEG < 0.63 or NEG > 1.47 THEN NEG = '.'; 
if starch < 9.6 then starch ='.';
IF fat <  1.62 or FAT > 4.94 THEN Fat = '.'; 
IF NDF < 24.89 or NDF > 60.46 THEN NDF = '.'; 
IF ADF < 12.67 or ADF > 37.63 THEN ADF = '.'; 
if lignin < 1.13 or lignin > 5.17 then lignin ='.';
IF CP < 5.06 or CP > 11.38 THEN CP='.';
if RDP < 51.8 then RDP ='.';
if RUP > 48.12 then RUP ='.';
IF SOL_PROTEIN < 24.21  THEN SOL_PROTEIN = '.'; 
IF ADIN < 0.13 or ADIN > 1.04 THEN ADIN = '.'; 
IF Ca > 0.46 THEN Ca = '.'; 
IF P < 0.12 or  P > 0.35 THEN P = '.'; 
IF Mg < 0.05 or Mg > 0.29 THEN Mg = '.'; 
IF K < 0.23 or K > 1.88 THEN K = '.'; 
IF Na > 0.19 THEN Na = '.'; 
IF Cl >0.66 THEN Cl = '.'; 
IF S < 0.04 or S > 0.16 THEN S = '.'; 
IF Cu > 16.72 THEN Cu = '.'; 
IF Fe > 919.46 THEN Fe = '.'; 
IF Mn > 85.63 THEN Mn = '.'; 
IF Zn > 77.48 THEN Zn = '.'; 
RUN;

RUN; 
PROC CORR DATA=final; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;
PROC CORR DATA=final; 
VAR DM Ash CP NDF starch Lignin; 
RUN; 
