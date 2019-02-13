/*L1_PEANUT_HULLS_Dry. */
proc import file='C:\Users\Huyen Tran\Documents\NANP\BeefNRC\L1.test\L1_PEANUT_HULLS_Dry.XLSX' out=L1_PEANUT_HULLS_Dry dbms=xlsx replace; run;
ods html close;
ods html;
Title "LAB 1 DAIRYONE REMOVE 3.5 SD WITHIN L1_PEANUT_HULLS_Dry"; 
/* set nutrient concentrations to missing. */ 
DATA a01; 
SET L1_PEANUT_HULLS_Dry;
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
PROC CORR DATA=a01; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN; 
PROC CORR DATA=a01; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P;
RUN; 
proc sgplot data=a01;
  histogram  DM;
  density DM ;
  density DM / type=kernel;
  keylegend / location = inside position = topright; 
run;
proc sgplot data=a01;
  histogram  CP;
  density CP ;
  density CP / type=kernel;
  keylegend / location = inside position = topright; 
run;

DATA a01a; 
SET a01; 
IF Ash > 12.43 THEN Ash = '.'; 
IF TDN < 22.2 or TDN > 63.5 THEN TDN = '.'; 
IF DE < 1.01 or DE > 2.83 THEN DE = '.'; 
IF ME <0.55 or ME > 2.45 THEN ME = '.'; 
IF NEM > 1.32  THEN NEM = '.'; 
IF NEG > 1.31 THEN NEG = '.'; 
IF STARCH > 8 THEN Starch = '.'; 
IF FAT > 13.74 THEN FAT = '.'; 
IF NDF < 48.47  THEN NDF = '.';
IF ADF < 37.08 THEN ADF = '.'; 
IF CP > 16.48 THEN CP = '.'; 
IF SOL_PROTEIN < 6 THEN SOL_PROTEIN = '.'; 
IF Ca > 0.86 THEN Ca = '.'; 
IF P > 0.24 THEN P = '.'; 
IF Mg > 0.4  THEN Mg = '.'; 
IF  K > 1.48 THEN K = '.'; 
IF NA > 4.11 THEN NA = '.'; 
IF S > 0.2 THEN S = '.'; 
IF Fe > 1964.45 THEN Fe = '.'; 
IF Zn > 33.01 THEN Zn = '.'; 
RUN;



PROC univariate DATA=a01a; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;
PROC corr DATA=a01a; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;
PROC corr DATA=a01A; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P;
RUN;
proc sgplot data=a01a;
  histogram  DM;
  density DM ;
  density DM/ type=kernel;
  keylegend / location = inside position = topright; 
run;

DATA a01b; 
SET a01a;
IF Ash > 9.78 THEN Ash = '.'; 
IF TDN < 29.36 THEN TDN = '.'; 
IF FAT > 9.79 THEN FAT = '.'; 
IF CP > 16.02 THEN CP = '.'; 
IF SOL_PROTEIN < 6 THEN SOL_PROTEIN = '.'; 
IF Ca > 0.62 THEN Ca = '.'; 
IF Mg > 0.38  THEN Mg = '.'; 
IF Fe > 1725.10 THEN Fe = '.'; 

RUN;
PROC univariate DATA=a01B; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;
PROC corr DATA=a01B; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P	Mg 	K	NA	Cl 	S 	Co 	Cu 	Fe 	Mn 	Se 	Zn; 
RUN;
PROC corr DATA=a01B; 
VAR DM	Ash	TDN	DE	ME	NEM	NEG	Starch	Fat	NDF	ADF	Lignin	CP	RDP	RUP	Sol_Protein	ADIN Ca	P;
RUN;
proc sgplot data=a01B;
  histogram  DM;
  density DM ;
  density DM/ type=kernel;
  keylegend / location = inside position = topright; 
run;
proc sgplot data=a01B;
  histogram  ASH;
  density ASH ;
  density ASH/ type=kernel;
  keylegend / location = inside position = topright; 
run;
proc sgplot data=a01B;
  histogram  ADF;
  density ADF ;
  density ADF/ type=kernel;
  keylegend / location = inside position = topright; 
run;
proc sgplot data=a01B;
  histogram  NDF;
  density NDF ;
  density NDF/ type=kernel;
  keylegend / location = inside position = topright; 
run;
proc sgplot data=a01B;
  histogram  cp;
  density cp ;
  density cp/ type=kernel;
  keylegend / location = inside position = topright; 
run;
proc sgplot data=a01B;
  histogram  starch;
  density starch ;
  density starch/ type=kernel;
  keylegend / location = inside position = topright; 
run;
