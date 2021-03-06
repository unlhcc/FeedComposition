/*L1_OAT_HULLS_Dry. */
proc import file='C:\Users\Huyen Tran\Documents\NANP\BeefNRC\L1.test\L1_OAT_HULLS_Dry.XLSX' out=L1_OAT_HULLS_Dry dbms=xlsx replace; run;
ods html close;
ods html;
Title "LAB 1 DAIRYONE REMOVE 3.5 SD WITHIN L1_OAT_HULLS_Dry"; 
/* set nutrient concentrations to missing. */ 
DATA a01; 
SET L1_OAT_HULLS_Dry;
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
if DM < 84.62 then DM ='.';
IF TDN > 78.78 THEN TDN = '.'; 
IF DE > 3.49 THEN DE = '.'; 
IF ME > 3.09 THEN ME = '.'; 
IF NEM > 1.91 THEN NEM = '.'; 
IF NEG > 1.28 THEN NEG = '.'; 
IF NDF < 18.13 THEN NDF = '.';
IF ADF < 8.75  THEN ADF = '.'; 
IF CP > 17.68 THEN CP = '.'; 
IF Ca > 0.9 THEN Ca = '.'; 
IF  P > 0.71 THEN P = '.'; 
IF K > 1.35 THEN K = '.'; 
IF NA > 0.26 THEN NA = '.'; 
IF S > 0.23 THEN S = '.'; 
IF Zn > 100.51 THEN Zn = '.'; 
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
IF TDN > 75.8 THEN TDN = '.'; 
IF DE > 3.43 THEN DE = '.'; 
IF ME > 3.02 THEN ME = '.'; 
IF NEM > 1.85 THEN NEM = '.'; 
IF NEG > 1.23 THEN NEG = '.'; 
IF CP < 1 THEN CP = '.'; 
IF Ca >= 0.7 THEN Ca = '.'; 
if P < 0.1 then P ='.';
IF NA > 0.26 THEN NA = '.'; 
IF Fe < 68 or Fe > 600 THEN Fe ='.';
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
