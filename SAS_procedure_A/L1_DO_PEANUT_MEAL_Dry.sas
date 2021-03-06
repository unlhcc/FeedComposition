/*L1_PEANUT_MEAL_Dry. */
proc import file='C:\Users\Huyen Tran\Documents\NANP\BeefNRC\L1.test\L1_PEANUT_MEAL_Dry.XLSX' out=L1_PEANUT_MEAL_Dry dbms=xlsx replace; run;
ods html close;
ods html;
Title "LAB 1 DAIRYONE REMOVE 3.5 SD WITHIN L1_PEANUT_MEAL_Dry"; 
/* set nutrient concentrations to missing. */ 
DATA a01; 
SET L1_PEANUT_MEAL_Dry;
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
if DM < 88.76 then DM ='.';
IF TDN > 100 THEN TDN = '.'; 
IF NEM > 4.1 THEN NEM = '.'; 
IF FAT > 35.05 THEN FAT = '.'; 
IF NDF > 55.8 THEN NDF = '.';
IF ADF > 43.86 THEN ADF = '.'; 
IF LIGNIN >= 12 THEN LIGNIN = '.'; 
IF CP < 26.18 THEN CP = '.'; 
IF NA > 0.39 THEN NA = '.'; 
IF Cu > 38.18 THEN Cu = '.'; 
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
if DM < 90.52 then DM ='.';
IF NEM > 3.84 THEN NEM = '.'; 
IF FAT > 17.36 THEN FAT = '.'; 
IF NDF > 39.91 THEN NDF = '.';
IF ADF > 31.72 THEN ADF = '.'; 
IF CP < 30.4 or CP > 59.3 THEN CP = '.'; 
IF NA > 0.25 THEN NA = '.'; 
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

