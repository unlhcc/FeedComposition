/*L1_OAT_SILAGE. */
proc import file='C:\Users\Huyen Tran\Documents\NANP\BeefNRC\L1.test\L1_OAT_SILAGE.XLSX' out=L1_OAT_SILAGE dbms=xlsx replace; run;
ods html close;
ods html;
Title "LAB 1 DAIRYONE Remove 3.5 SD WITHIN L1_OAT_SILAGE"; 
/* set nutrient concentrations to missing. */ 
DATA a01; 
SET L1_OAT_SILAGE;
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
if DM >= 70 then DM ='.';
IF Ash > 20.79 THEN Ash = '.'; 
IF TDN < 42.31 or TDN > 73.89 THEN TDN = '.'; 
IF DE < 1.89 or DE > 3.31 THEN DE = '.'; 
IF ME < 1.46 or ME > 2.9 THEN ME = '.'; 
IF NEM < 0.63 THEN NEM = '.'; 
IF NEG < 0.12 THEN NEG = '.'; 
IF STARCH > 15.56 THEN Starch = '.'; 
IF FAT > 6.38 THEN FAT = '.'; 
IF NDF > 79.6 THEN NDF = '.';
IF ADF > 53.54 THEN ADF = '.'; 
IF LIGNIN < 0.71 or LIGNIN > 10 THEN LIGNIN = '.'; 
IF CP > 25 THEN CP = '.'; 
IF RDP < 49.51 THEN RDP = '.'; 
IF RUP > 50.41 THEN RUP = '.'; 
IF SOL_PROTEIN < 26.83 THEN SOL_PROTEIN = '.'; 
IF ADIN > 2.12 THEN ADIN = '.'; 
IF Ca > 1.2 THEN Ca = '.'; 
IF P < 0.08 or P > 0.57 THEN P = '.'; 
IF Mg > 0.37  THEN Mg = '.'; 
IF K > 5.38 THEN K = '.'; 
IF NA > 1.57 THEN NA = '.'; 
IF Cl > 2.52 THEN Cl = '.'; 
IF S < 0.03 or S > 0.34 THEN S = '.'; 
IF Cu > 32.57 THEN Cu = '.'; 
IF Fe > 5766.39 THEN Fe = '.'; 
IF Mn > 286.24 THEN Mn = '.'; 
IF Zn > 198.23 THEN Zn = '.'; 
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
if DM > 67 then DM ='.';
IF Ash > 18.56 THEN Ash = '.'; 
IF TDN < 43.15 THEN TDN = '.'; 
IF DE < 1.92 or DE > 3.28 THEN DE = '.'; 
IF ME < 1.49 or ME > 2.87 THEN ME = '.'; 
IF NEM < 0.65 THEN NEM = '.'; 
IF STARCH > 11 THEN Starch = '.'; 
IF FAT < 1 THEN FAT = '.'; 
IF NDF < 38.02 THEN NDF = '.';
IF ADF < 23.54 THEN ADF = '.'; 
IF LIGNIN < 0.87 or LIGNIN > 9.8 THEN LIGNIN = '.'; 
IF CP > 24.42 THEN CP = '.'; 
IF RDP < 50.54 THEN RDP = '.'; 
IF RUP > 49.38 THEN RUP = '.'; 
IF SOL_PROTEIN < 28.67 THEN SOL_PROTEIN = '.'; 
IF ADIN > 1.93 THEN ADIN = '.'; 
IF Ca > 1.13 THEN Ca = '.'; 
IF  P > 0.56 THEN P = '.'; 
IF Mg < 0.02 or Mg > 0.35  THEN Mg = '.'; 
IF K > 5.26 THEN K = '.'; 
IF NA > 1.19 THEN NA = '.'; 
IF Cl > 2.39 THEN Cl = '.'; 
IF S > 0.33 THEN S = '.'; 
IF Cu > 22.09 THEN Cu = '.'; 
IF Mn > 223.41 THEN Mn = '.'; 
IF Fe > 3257.64 THEN Fe = '.'; 
IF Zn > 76.81 THEN Zn = '.'; 
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

