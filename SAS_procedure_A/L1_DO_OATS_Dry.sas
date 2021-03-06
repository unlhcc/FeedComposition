/*L1_OATS_Dry. */
proc import file='C:\Users\Huyen Tran\Documents\NANP\BeefNRC\L1.test\L1_OATS_Dry.XLSX' out=L1_OATS_Dry dbms=xlsx replace; run;
ods html close;
ods html;
Title "LAB 1 DAIRYONE REMOVE 3.5 SD WITHIN L1_OATS_Dry"; 
/* set nutrient concentrations to missing. */ 
DATA a01; 
SET L1_OATS_Dry;
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
if DM > 96.59 then DM ='.';
IF Ash > 6.29 THEN Ash = '.'; 
IF TDN < 65.55 THEN TDN = '.'; 
IF DE < 2.89 THEN DE = '.'; 
IF ME < 2.47 or ME > 4.02 THEN ME = '.'; 
IF NEM < 1.43 THEN NEM = '.'; 
IF NEG < 0.85 THEN NEG = '.'; 
IF Starch < 12.66 THEN Starch = '.'; 
IF NDF > 61.91 THEN NDF = '.';
IF ADF > 33.04 THEN ADF = '.'; 
IF LIGNIN > 6.04 THEN LIGNIN = '.'; 
IF CP < 5.53 or CP > 19.44 THEN CP = '.'; 
IF RDP < 18.26 THEN RDP = '.'; 
IF RUP < 30.57 THEN RUP = '.'; 
IF SOL_PROTEIN < 3.75 or SOL_PROTEIN > 81.52 THEN SOL_PROTEIN = '.'; 
IF ADIN > 1.84 THEN ADIN = '.'; 
IF Ca > 0.51 THEN Ca = '.'; 
IF  P > 0.72 THEN P = '.'; 
IF Mg > 0.26  THEN Mg = '.'; 
IF K > 1.08 THEN K = '.'; 
IF NA > 0.24 THEN NA = '.'; 
IF Cl > 0.57 THEN Cl = '.'; 
IF S > 0.35 THEN S = '.'; 
IF Cu > 26.71 THEN Cu = '.'; 
IF Fe > 314.33 THEN Fe = '.'; 
IF Mn > 119.52 THEN Mn = '.'; 
IF Zn > 81.77 THEN Zn = '.'; 
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
IF Ash > 6.0 THEN Ash = '.'; 
IF TDN < 67.35 or TDN > 98.81 THEN TDN = '.'; 
IF DE < 2.99 or DE > 4.32 THEN DE = '.'; 
IF ME < 2.58 or ME > 3.94 THEN ME = '.'; 
IF NEM < 1.51 or NEM > 2.5 THEN NEM = '.'; 
IF NEG < 0.93 or NEG > 1.78 THEN NEG = '.'; 
IF Starch < 14.94 THEN Starch = '.'; 
IF NDF < 5.9 or NDF > 57.55 THEN NDF = '.';
IF ADF > 30.36 THEN ADF = '.'; 
IF LIGNIN > 5.73 THEN LIGNIN = '.'; 
IF CP < 5.92 or CP > 19.08 THEN CP = '.'; 
IF RDP > 69.06 THEN RDP = '.'; 
IF RUP < 34.28 or RUP > 78.46 THEN RUP = '.'; 
IF SOL_PROTEIN > 50.7 THEN SOL_PROTEIN = '.'; 
IF ADIN > 1.79 THEN ADIN = '.'; 
IF Ca > 0.3 THEN Ca = '.'; 
IF  P < 0.05 THEN P = '.'; 
IF Mg < 0.03  THEN Mg = '.'; 
IF K > 0.91 THEN K = '.'; 
IF NA > 0.07 THEN NA = '.'; 
IF Cl > 0.34 THEN Cl = '.'; 
IF S > 0.34 THEN S = '.'; 
IF Cu > 16.18 THEN Cu = '.'; 
IF Mn > 105.692 THEN Mn = '.'; 
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

