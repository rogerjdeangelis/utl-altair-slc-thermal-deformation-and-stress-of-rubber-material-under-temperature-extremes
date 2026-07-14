/*
  Thermal deformation / stress inputs for rubber under temperature extremes.
  Ingests the analysis parameters and boundary conditions, then prints them.
  Adapted from the repo's utl-altair-slc-thermal-... program: the libname was
  a Windows path (d:/wpswrkx) so datasets are built in WORK, and the cards4
  reader is written as the equivalent single-terminator CARDS form. The input
  data, informats, FORMAT, and PROC PRINT titles are the author's.
*/

data work.input_data_numeric;
infile cards delimiter=',';
informat
Parameter $38.
Unit $8.
Symbol $8.
;
input
Parameter  Value  Unit  Symbol ;
format value 9.6;
cards;
Initial Temperature,100,C,T1
Final Temperature,50,C,T2
Temperature Change,-50,C,dT
Young's Modulus,1,MPa,E
CTE (Coefficient of Thermal Expansion),0.0002,1/C,a
Reference Length,1,m,L0
Cross-sectional Area,1,m2,A
;
run;quit;

proc print data=work.input_data_numeric;
title "Numeric Inputs";
run;quit;

data work.input_data_text;informat
Parameter $18.
Value $10.
Unit $1.
Symbol $1.
;input
Parameter & Value &;
cards;
Boundary Condition  Fixed Ends
;
run;quit;

proc print data=work.input_data_text;
title "Boundary Conditions";
run;quit;
