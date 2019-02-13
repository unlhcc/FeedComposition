proc import file='C:\Users\Huyen Tran\Documents\NANP\BeefNRC\L1.test\L1_ALFALFA_CUBES.xlsx' out=L1_ALFALFA_CUBES dbms=xlsx replace; run;
ods html close;
ods html;
Title "LAB 1 DAIRYONE RAW DATA WITHIN ALFALFA CUBES."; 
/* set nutrient concentrations to missing. */ 
DATA a01; 
SET L1_ALFALFA_CUBES;
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
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN; 
PROC corr DATA=a01; 
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
IF DM < 86.47 or dm > 95.70 THEN DELETE; 
IF Ash < 2.92 or Ash > 21.19 THEN DELETE; 
IF CP < 8.23 or CP > 27.90 THEN DELETE; 
IF NDF < 23.92 or NDF > 67.42 THEN DELETE; 
run;
proc univariate DATA=a01_a;
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;
proc corr DATA=a01_a;
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
run;
proc corr DATA=a01_a;
VAR DM	Ash	CP NDF  Lignin; 
run;


DATA a01_b; 
SET a01_a; 
zDM = dm; 
zAsh = ash; 
zCP = cp; 
zNDF = ndf; 
zlignin = lignin;
RUN; 
/* Standardize all nutrient concentrations */ 
PROC STANDARD DATA=a01_b MEAN=0 STD=1 OUT=stand_a01; 
VAR zDM zASH zCP zNDF  zlignin; 
RUN;
/* Prin. component analysis using the cov option */ 

PROC PRINCOMP DATA=stand_a01 COV OUT=a01_princomp; 
VAR zDM zASH zCP zNDF zlignin; 
RUN;
PROC UNIVARIATE DATA=a01_princomp; 
VAR Prin1 Prin2 Prin3 Prin4 Prin5; 
RUN;
proc corr DATA=a01_princomp; 
VAR Prin1 Prin2 Prin3 Prin4 Prin5; 
RUN;

/* STEP 2: Remove PCA scores that are 3.5 STD from the mean. */ 
/* ----------------------------------------------------------------------*/ 
/* Values in this step are typed in the code from the output of */ 
/* PROC UNIVARIATE. */ 
/* This step could be programmed from the output to increase automation. */ 
/* This wasn’t done here to improve the clarity of the code. */ 
DATA a01_princomp1; 
SET a01_princomp; 
IF Prin1 < -5.2 or Prin1 > 5.2 THEN DELETE; 
IF Prin2 < -4.12 or Prin2 > 4.12 THEN DELETE; 
IF Prin3 < -2.85 or Prin3 > 2.85 THEN DELETE; 
IF Prin4 < -2.71 or Prin4 > 2.71 THEN DELETE; 
IF Prin5 < -1.44 or Prin5 > 1.44 THEN DELETE; 
RUN; 
proc CORR DATA=a01_princomp1;
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;
proc CORR DATA=a01_princomp1;
VAR DM	Ash	CP NDF Starch Lignin; 
RUN;


/* Two stage cluster analysis, k = n^0.3 */ 
PROC CLUSTER DATA=a01_princomp1 OUTTREE=tree1 METHOD=twostage 
k=6 PRINT=40 PSEUDO PLOTS(MAXPOINTS= 434); 
COPY DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
VAR zDM zAsh zCP zNDF ; 
RUN; 

PROC GPLOT DATA=tree1; 
/* Repeat gplot of tree1 two times, once for PSF and once for PST2. */ 
PLOT _PSF_ *_NCL_; 
RUN; 

PROC TREE DATA=tree1 NOPRINT OUT=out n=1; 
COPY zCP zNDF zDM zAsh DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn _dens_ _freq_; 
RUN; 
PROC SORT DATA=out; 
BY CLUSTER; 
RUN; 
PROC CORR DATA=out; 
BY CLUSTER; 
VAR DM Ash CP NDF lignin; 
RUN;
PROC CORR DATA=out; 
BY CLUSTER; 
var DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;

/* STEP 3: there is only 1 cluster */ 
/*remove 3.5 SD from the means of other nutrients*/
/* ----------------------------------------------------------------------*/

DATA final; 
SET out;
IF DM < 86.88 THEN DM ='.';
if Ash > 20.14 then Ash ='.';
IF TDN < 43.14 THEN TDN = '.'; 
IF DE < 1.98 THEN DE = '.'; 
IF ME < 1.55 THEN ME = '.'; 
IF STARCH > 5.77 THEN Starch = '.'; 
IF FAT > 3.81 THEN Fat = '.'; 
IF NDF > 61.6 THEN NDF = '.'; 
IF CP < 10.82 THEN CP='.';
IF ADIN > 2.33 THEN ADIN = '.'; 
IF Ca > 2.55 THEN Ca = '.'; 
IF P > 0.44 THEN P = '.'; 
IF Mg > 0.59 THEN Mg = '.'; 
IF Na > 0.38 THEN Na = '.'; 
IF Cu > 26.97 THEN Cu = '.'; 
IF Fe > 4665.0 THEN Fe = '.'; 
IF Mn > 144.6 THEN Mn = '.'; 
IF Zn > 57.61 THEN Zn = '.'; 
RUN;

RUN; 
PROC CORR DATA=final; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;
PROC CORR DATA=final; 
VAR DM Ash CP NDF  Lignin; 
RUN; 
