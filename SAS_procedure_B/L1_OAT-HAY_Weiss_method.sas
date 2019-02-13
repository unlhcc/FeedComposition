proc import file='C:\Users\Huyen Tran\Documents\NANP\BeefNRC\L1.test\L1_oat_hay.xlsx' out=L1_oat_hay dbms=xlsx replace; run;
ods html close;
ods html;
Title "LAB 1 DAIRYONE RAW DATA WITHIN L1_OAT_HAY."; 
/* set nutrient concentrations to missing. */ 
DATA a01; 
SET L1_oat_hay;
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

DATA a01_a; 
SET a01; 
IF dm < 84.88 or DM > 96.37 THEN DELETE; 
IF Ash > 15 THEN DELETE; 
IF NDF < 35.71 or NDF > 82.32 then DELETE; 
IF LIGNIN > 10.07 THEN DELETE; 
IF CP > 19.99 THEN DELETE; 
IF STARCH > 14.91 THEN DELETE; 
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
IF Prin1 < -4.85 or Prin1 > 4.85 THEN DELETE; 
IF Prin2 < -4.39 or Prin2 > 4.39 THEN DELETE; 
IF Prin3 < -3.49 or Prin3 > 3.49 THEN DELETE; 
IF Prin4 < -2.95 or Prin4 > 2.95 THEN DELETE; 
IF Prin5 < -1.97 or Prin5 > 1.97 THEN DELETE; 
IF Prin6 < -1.87 or Prin6 > 1.87 THEN DELETE; 
RUN; 
proc CORR DATA=a01_princomp1;
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;
proc CORR DATA=a01_princomp1;
VAR DM	Ash	CP NDF Starch Lignin; 
RUN;

/* Two stage cluster analysis, k = n^0.3 */ 
PROC CLUSTER DATA=a01_princomp1 OUTTREE=tree1 METHOD=twostage 
k=15 PRINT=40 PSEUDO;
copy DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
VAR zDM zAsh zCP zNDF zStarch zLignin; 
RUN; 

PROC GPLOT DATA=tree1; 
/* Repeat gplot of tree1 two times, once for PSF and once for PST2. */ 
PLOT _PSF_ *_NCL_; 
RUN; 

/* Look at Cluster history, PSF max = 1129 at cluster =4 and PST2 max = 1508 at cluster =2*/
/*number of cluster =4*/

/* Determine number of clusters from PSF and PST2 maximum values. */ 
PROC TREE DATA=tree1 NOPRINT OUT=out n=4; 
COPY zCP zNDF zDM zAsh zStarch zLignin DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn _dens_ _freq_; 
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

/* remove cluster 4, n = 74 */
DATA out1; 
SET out; 
IF CLUSTER = 4 THEN DELETE; 
RUN; 

/* rerun cluster after remove cluster 4 */
PROC CLUSTER DATA=out1 OUTTREE=tree2 METHOD=twostage 
k=15 PRINT=40 PSEUDO PLOTS;
COPY DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
VAR zDM zAsh zCP zNDF zStarch zLignin; 
RUN; 

PROC GPLOT DATA=tree2; 
/* Repeat gplot of tree2 two times, once for PSF and once for PST2. */ 
PLOT _PSF_ *_NCL_; 
RUN; 
/* Determine number of clusters from PSF and PST2 maximum values. */ 

PROC TREE DATA=tree2 NOPRINT OUT=out2 n=3; 
COPY zCP zNDF zDM zAsh zLignin DM Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn _dens_ _freq_; 
RUN; 

PROC SORT DATA=out2; 
BY CLUSTER; 
RUN; 
PROC CORR DATA=out2; 
BY CLUSTER; 
VAR DM Ash CP NDF starch Lignin; 
RUN; 
PROC CORR DATA=out2; 
BY CLUSTER; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN; 


/*Tempory delete cluster 2 and 3 from the dataset to obtain simple statistic for cluster 1*/
data cluster1;
set out2;
if cluster = 2 or cluster =3 then delete;
run;

DATA CLUSTER1_1; 
SET cluster1;
IF DM > 92.9 THEN DM ='.';
IF  ASH > 8.15 THEN ASH ='.';
IF TDN < 51.78 THEN TDN = '.'; 
IF DE < 2.24 THEN DE = '.'; 
IF ME < 1.81 THEN ME = '.'; 
IF NEM < 0.88 or NEM > 1.31 THEN NEM = '.'; 
IF NEG < 0.34 or NEG > 0.74 THEN NEG = '.'; 
IF STARCH > 8.52 THEN Starch = '.'; 
IF Fat < 0.84 or FAT > 2.99 THEN Fat = '.'; 
IF NDF < 60.85 or NDF > 73.49 THEN NDF = '.'; 
IF ADF < 36.15 or ADF > 48.14 THEN ADF = '.'; 
IF CP < 4.17 or CP > 8.95 THEN CP='.';
IF SOL_PROTEIN < 19.58 or SOL_PROTEIN > 61.24 THEN SOL_PROTEIN = '.'; 
IF Ca > 0.37 THEN Ca = '.'; 
IF P < 0.06 or P > 0.27 THEN P = '.'; 
IF Mg < 0.03 or Mg > 0.17 THEN Mg = '.'; 
IF Fe > 530.49 THEN Fe = '.'; 
RUN;

RUN; 
PROC CORR DATA=CLUSTER1_1; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;
PROC CORR DATA=CLUSTER1_1; 
VAR DM Ash CP NDF starch Lignin; 
RUN; 

/*Tempory delete cluster 1 and 3 from the dataset to obtain simple statistic for cluster 2*/

data cluster2;
set out2;
if cluster = 1 or cluster =3 then delete;
run;

DATA CLUSTER2_1; 
SET cluster2;
IF DM < 86.19 or DM > 93.83 THEN DM ='.';
IF TDN < 53.59 THEN TDN = '.'; 
IF DE < 2.31 THEN DE = '.'; 
IF ME < 1.89 THEN ME = '.'; 
IF NEM < 0.85 THEN NEM = '.'; 
IF NEG < 0.31 THEN NEG = '.'; 
IF STARCH > 10.49 THEN Starch = '.'; 
IF FAT > 3.82 THEN Fat = '.'; 
IF NDF > 72.29 THEN NDF = '.'; 
IF ADF > 47.92 THEN ADF = '.'; 
IF CP > 11.89 THEN CP='.';
if RDP < 46.9 then RDP ='.';
if RUP > 53.15 then RUP ='.';
IF SOL_PROTEIN < 19.53 or SOL_PROTEIN > 63.62 THEN SOL_PROTEIN = '.'; 
IF ADIN > 0.99 THEN ADIN = '.'; 
IF Ca > 0.5 THEN Ca = '.'; 
IF P < 0.05 or P > 0.3 THEN P = '.'; 
IF Mg > 0.23 THEN Mg = '.'; 
IF K > 2.74 THEN K = '.'; 
IF Na > 1.13 THEN Na = '.'; 
IF Cl > 2.22 THEN Cl = '.'; 
IF S > 0.2 THEN S = '.'; 
IF Cu > 29.1 THEN Cu = '.'; 
IF Fe > 1393.2 THEN Fe = '.'; 
IF Mn > 193.77 THEN Mn = '.'; 
IF Zn > 60.34 THEN Zn = '.'; 
RUN;

RUN; 
PROC CORR DATA=CLUSTER2_1; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;
PROC CORR DATA=CLUSTER2_1; 
VAR DM Ash CP NDF starch Lignin; 
RUN; 

/*Tempory delete cluster 1 and 2 from the dataset to obtain simple statistic for cluster 3*/

data cluster3;
set out2;
if cluster = 1 or cluster = 2 then delete;
run;

DATA CLUSTER3_1; 
SET cluster3;
IF TDN < 46 or TDN > 72.38 THEN TDN = '.'; 
IF DE < 2.03 or DE > 3.15 THEN DE = '.'; 
IF ME < 1.6 or ME > 2.74 THEN ME = '.'; 
IF NEM < 0.68 or NEM > 1.71 THEN NEM = '.'; 
IF NEG < 0.15 or NEG > 1.1 THEN NEG = '.'; 
IF FAT > 4.87 THEN Fat = '.'; 
IF NDF < 39.96 or NDF > 76.36 THEN NDF = '.'; 
IF ADF < 22.77 or ADF > 51.37 THEN ADF = '.'; 
IF CP > 18.39 THEN CP='.';
if RDP < 42.6 then RDP ='.';
if RUP > 57.37 then RUP ='.';
IF SOL_PROTEIN < 18.56 or SOL_PROTEIN > 63.01 THEN SOL_PROTEIN = '.'; 
IF ADIN > 1.46 THEN ADIN = '.'; 
IF Ca > 0.87 THEN Ca = '.'; 
IF P > 0.43 THEN P = '.'; 
IF Mg > 0.32 THEN Mg = '.'; 
IF K > 3.95 THEN K = '.'; 
IF Na > 1.52 THEN Na = '.'; 
IF Cl > 2.79 THEN Cl = '.'; 
IF S > 0.32 THEN S = '.'; 
IF Cu > 22.52 THEN Cu = '.'; 
IF Fe > 1382.06 THEN Fe = '.'; 
IF Mn > 191.11 THEN Mn = '.'; 
IF Zn > 53.57 THEN Zn = '.'; 
RUN;

RUN; 
PROC CORR DATA=CLUSTER3_1; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;
PROC CORR DATA=CLUSTER3_1; 
VAR DM Ash CP NDF starch Lignin; 
RUN; 
