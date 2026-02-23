%let pgm=utl-altair-slc-thermal-deformation-and-stress-of-rubber-material-under-temperature-extremes;

%stop_submission;

Altair slc thermal deformation and stress of rubber material under temperature extremes

Too long to post on list, see github
https://github.com/rogerjdeangelis/utl-altair-slc-thermal-deformation-and-stress-of-rubber-material-under-temperature-extremes

Original Post
https://community.altair.com/discussion/64949

THERMAL STRESS ANALYSIS FOR RUBBER MATERIAL (fixed edges as in post)

Stress State: Tensile

Stress Magnitude: 0.01 MPa (10 kPa or 1 psi)

Risk Level: Low

Deformation Potential (if unconstrained): -10.00 mm per meter length

Physical Interpretation: MATERIAL ATTEMPTS TO CONTRACT BUT IS CONSTRAINED, INDUCING TENSILE STRESS

SUMMARY

Aspect                                      Value

Stress State                                Tensile
Stress Magnitude                            0.01 MPa (10 kPa or 1 psi)
Risk Level                                  Low
Deformation Potential (if unconstrained)    10.00 mm per meter length
Physical Interpretation                     Material attempts to contract
                                            but is constrained, inducing
                                            tensile stress
       Cross-sectional Area=1 m²
            Fixed Boundary
        +---------------------+
        ¦                     ¦
  Fixed ¦                     ¦ Fixed Boundary
Boundary¦                     ¦
        ¦                     ¦
        ¦                     ¦
        +---------------------+
        ^-- Length = 1.0 m -- ^
            Fixed Boundary

 r
               TEMP_DEG_C
        100        75        50
        -+---------+-----------+
    -10 +               FINAL *+ -10  -10 mm potential shrinkage
        |                    /X|
     -9 +                   /XX+ -9
  D     |                  /XXX|    D
  E  -8 +                 /XXXX+ -8 E
  F     |                /XXXXX|    F
  O  -7 +               /XXXXXX+ -7 O
  R     |              /XXXXXXX|    R
  M  -6 +             /XXXXXXXX+ -6 M
  A     |            /XXXXXXXXX|    A
  T  -5 +           /XXXXXXXXXX+ -5 T
  I     |          /XXXXXXXXXXX|    I
  O  -5 +         /XXXXXXXXXXXX+ -5 O
  N     |        /XXXXXXXXXXXXX|    N
     -3 +       /XXXXXXXXXXXXXX+ -3
  mm    |      /XXXXXXXXXXXXXXX|    mm
     -2 +     /XXXXXXXXXXXXXXXX+ -2
        |    /XXXXXXXXXXXXXXXXX|
     -1 +   /XXXXXXXXXXXXXXXXXX+ -1
        |  /XXXXXXXXXXXXXXXXXXX|
      0 +*  INITIAL XXXXXXXXXXX|  0
        -+---------+-----------+
        100        75        50
                TEMP_DEG_C

options validvarname=v7;;
proc print data=workx.input_data_numeric;
title "Numeric Inputs";
run;quit;

options validvarname=v7;;
proc print data=workx.input_data_text;
title "Boundary Conditions";
run;quit;


/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

libname workx "d:/wpswrkx";

options ls=255 validvarname=v7;;
data workx.input_data_numeric;
infile cards4 delimiter=',';
informat
Parameter $38.
Unit $8.
Symbol $8.
;
input
Parameter  Value  Unit  Symbol ;
format value 9.6;
cards4;
Initial Temperature,100,°C,T1
Final Temperature,50,°C,T2
Temperature Change,-50,°C,?T
Young's Modulus,1,MPa,E
CTE (Coefficient of Thermal Expansion),0.0002,1/°C,a
Reference Length,1,m,L0
Cross-sectional Area,1,m²,A
;;;;
run;quit;

proc print data=workx.input_data_numeric;
run;quit;

data workx.input_data_text;informat
Parameter $18.
Value $10.
Unit $1.
Symbol $1.
;input
Parameter & Value &;
cards4;
Boundary Condition  Fixed Ends
;;;;
run;quit;

/**************************************************************************************************************************/
/* WORKX.INPUT_DATA_TEXT (Boundary Condition)                                                                             */
/*                                                                                                                        */
/* Obs        Parameter           Value                                                                                   */
/*                                                                                                                        */
/*  1     Boundary Condition    Fixed Ends                                                                                */
/*                                                                                                                        */
/* WORKX.INPUT_DATA_NUMERIC                                                                                               */
/*                                                                                                                        */
/*  Parameter                                    Value    Unit    Symbol                                                  */
/*                                                                                                                        */
/*  Initial Temperature                        100.000    °C        T1                                                    */
/*  Final Temperature                           50.000    °C        T2                                                    */
/*  Temperature Change                         -50.000    °C        ?T                                                    */
/*  Young's Modulus                              1.000    MPa       E                                                     */
/*  CTE (Coefficient of Thermal Expansion)       0.000    1/°C      a                                                     */
/*  Reference Length                             1.000    m         L0                                                    */
/*  Cross-sectional Area                         1.000    mÂ²       A                                                     */
/**************************************************************************************************************************/

options validvarname=v7; /*--- important ---*/
options set=PYTHONHOME "D:\py314";
proc python;
submit;
import pyreadstat as ps
import os
from datetime import datetime
import pyarrow
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

def thermal_stress_analysis():
    """
    Analyze thermal deformation and stress in rubber material
    Temperature decreases from 100°C to 50°C
    """


    # input_data_numeric.to_parquet('d:/wpswrkx/input_data_numeric.parquet', engine='pyarrow')

    #--- INPUTS FROM THE SLC ----

    input_data_numeric,meta = ps.read_sas7bdat('d:/wpswrkx/input_data_numeric.sas7bdat')
    input_data_text,meta = ps.read_sas7bdat('d:/wpswrkx/input_data_text.sas7bdat')

    # ==================== CALCULATIONS ====================
    # Extract values from numeric dataframe
    E = input_data_numeric[input_data_numeric['Parameter'] == "Young's Modulus"]['Value'].values[0]
    alpha = input_data_numeric[input_data_numeric['Parameter'] == 'CTE (Coefficient of Thermal Expansion)']['Value'].values[0]
    delta_T = input_data_numeric[input_data_numeric['Parameter'] == 'Temperature Change']['Value'].values[0]
    L0 = input_data_numeric[input_data_numeric['Parameter'] == 'Reference Length']['Value'].values[0]
    A = input_data_numeric[input_data_numeric['Parameter'] == 'Cross-sectional Area']['Value'].values[0]
    T_initial = input_data_numeric[input_data_numeric['Parameter'] == 'Initial Temperature']['Value'].values[0]
    T_final = input_data_numeric[input_data_numeric['Parameter'] == 'Final Temperature']['Value'].values[0]

    # Calculate thermal strain
    thermal_strain = alpha * delta_T

    # Calculate stress (for fixed ends: e = 0, so s = E*(0 - e_thermal) = -E*e_thermal)
    stress_mpa = -E * thermal_strain

    # Calculate free thermal deformation (if unconstrained)
    free_deformation_m = thermal_strain * L0

    # Calculate reaction force
    force_n = stress_mpa * A * 1e6  # Convert MPa to Pa: 1 MPa = 10^6 Pa

    # ==================== OUTPUT DATAFRAME 1: Basic Results ====================
    output_basic = pd.DataFrame({
        'Result': [
            'Thermal Strain',
            'Thermal Stress',
            'Free Thermal Deformation',
            'Reaction Force'
        ],
        'Value': [
            thermal_strain,
            stress_mpa,
            free_deformation_m,
            force_n
        ],
        'Unit': [
            'm/m',
            'MPa',
            'm',
            'N'
        ],
        'Formula': [
            'a × ?T',
            '-E × a × ?T',
            'a × ?T × L0',
            's × A'
        ]
    })

    # ==================== OUTPUT DATAFRAME 2: Converted Units ====================
    output_converted = pd.DataFrame({
        'Result': [
            'Thermal Strain (µstrain)',
            'Thermal Stress (kPa)',
            'Thermal Stress (psi)',
            'Free Deformation (mm)',
            'Reaction Force (kN)'
        ],
        'Value': [
            thermal_strain * 1e6,        # m/m to microstrain
            stress_mpa * 1000,           # MPa to kPa (1 MPa = 1000 kPa)
            stress_mpa * 145.0377,       # MPa to psi (1 MPa = 145.0377 psi)
            free_deformation_m * 1000,   # m to mm
            force_n / 1000               # N to kN
        ],
        'Unit': [
            'µe',
            'kPa',
            'psi',
            'mm',
            'kN'
        ]
    })

    # ==================== OUTPUT DATAFRAME 3: Summary with Interpretation ====================
    stress_magnitude = abs(stress_mpa)
    if stress_magnitude < 1:
        risk_level = "Low"
    elif stress_magnitude < 5:
        risk_level = "Moderate"
    elif stress_magnitude < 10:
        risk_level = "High"
    else:
        risk_level = "Critical - May exceed material limits"

    output_summary = pd.DataFrame({
        'Aspect': [
            'Stress State',
            'Stress Magnitude',
            'Risk Level',
            'Deformation Potential (if unconstrained)',
            'Physical Interpretation'
        ],
        'Value': [
            'Tensile' if stress_mpa > 0 else 'Compressive',
            f'{abs(stress_mpa):.2f} MPa ({abs(stress_mpa*1000):.0f} kPa or {abs(stress_mpa*145):.0f} psi)',
            risk_level,
            f'{abs(free_deformation_m*1000):.2f} mm per meter length',
            'Material attempts to contract but is constrained, inducing tensile stress'
        ]
    })

    print(input_data_numeric)

    # Save to parquet files
    #input_data_text.to_parquet('d:/wpswrkx/input_data_text.parquet', engine='pyarrow')

    output_basic.to_parquet('d:/wpswrkx/output_basic.parquet', engine='pyarrow')
    output_converted.to_parquet('d:/wpswrkx/output_converted.parquet', engine='pyarrow')
    output_summary.to_parquet('d:/wpswrkx/output_summary.parquet', engine='pyarrow')

    # For display purposes, combine them
    input_data_display = pd.concat([input_data_numeric, input_data_text], ignore_index=True)



    return input_data_display, output_basic, output_converted, output_summary, T_initial, T_final, thermal_strain, stress_mpa, free_deformation_m, force_n


def verify_calculations():
    """Verify the calculations manually"""
    print("\n?? MANUAL VERIFICATION:")
    print("-" * 40)

    E = 1.0  # MPa
    alpha = 200e-6  # 1/°C
    delta_T = -50  # °C

    thermal_strain = alpha * delta_T
    stress = -E * thermal_strain
    stress_kpa = stress * 1000
    stress_psi = stress * 145.0377

    print(f"Thermal strain (e) = a × ?T = {alpha:.2e} × ({delta_T}) = {thermal_strain:.4f}")
    print(f"Stress (s) = -E × e = -({E}) × ({thermal_strain:.4f}) = {stress:.2f} MPa")
    print(f"  ? {stress_kpa:.0f} kPa")
    print(f"  ? {stress_psi:.0f} psi")
    print(f"Free deformation (per meter) = e × L = {thermal_strain:.4f} × 1 m = {thermal_strain*1000:.1f} mm")

    return stress, stress_kpa, stress_psi


# ==================== MAIN EXECUTION ====================
if __name__ == "__main__":
    print("=" * 70)
    print("THERMAL STRESS ANALYSIS FOR RUBBER MATERIAL")
    print("Temperature Change: 100°C ? 50°C (?T = -50°C)")
    print("=" * 70)

    # Run the analysis
    input_df, output_basic_df, output_converted_df, output_summary_df, T_initial, T_final, thermal_strain, stress_mpa, free_deformation_m, force_n = thermal_stress_analysis()

    print("\n?? INPUT PARAMETERS:")
    print("-" * 50)
    print(input_df[['Parameter', 'Value', 'Unit']].to_string(index=False))

    print("\n?? BASIC RESULTS:")
    print("-" * 50)
    print(output_basic_df.to_string(index=False))

    print("\n?? CONVERTED UNITS:")
    print("-" * 50)
    pd.set_option('display.float_format', '{:.2f}'.format)
    print(output_converted_df.to_string(index=False))

    print("\n?? ANALYSIS SUMMARY:")
    print("-" * 50)
    for _, row in output_summary_df.iterrows():
        print(f"{row['Aspect']}: {row['Value']}")

    # Run verification
    stress, stress_kpa, stress_psi = verify_calculations()
endsubmit;
run;

/*--- use python 310 just for coverting parquet files to sas datasets ---*/

options validvarname=v7;
options set=PYTHONHOME "D:\py310";
proc python;
submit;
import pyarrow
import pandas as pd
input_data_numeric = pd.read_parquet('d:/wpswrkx/input_data_numeric.parquet', engine='pyarrow')
print(input_data_numeric)
input_data_text = pd.read_parquet('d:/wpswrkx/input_data_text.parquet', engine='pyarrow')
output_basic = pd.read_parquet('d:/wpswrkx/output_basic.parquet', engine='pyarrow')
output_converted = pd.read_parquet('d:/wpswrkx/output_converted.parquet', engine='pyarrow')
output_summary = pd.read_parquet('d:/wpswrkx/output_summary.parquet', engine='pyarrow')
endsubmit;
import python=input_data_numeric data=workx.input_data_numeric;
import python=input_data_text    data=workx.input_data_text   ;
import python=output_basic       data=workx.output_basic      ;
import python=output_converted   data=workx.output_converted  ;
import python=output_summary     data=workx.output_summary    ;
run;quit;

proc print data=workx.output_basic;
title "Basic Units";
run;quit;

proc print data=workx.output_converted;
title "Convential Units";
run;quit;

proc print data=workx.output_summary;
title "Summary";
run;quit;

/**************************************************************************************************************************/
/* BASIC UNITS                                                                                                            */
/*                                                                                                                        */
/* WORKX.OUTPUT_BASIC total obs=4                                                                                         */
/*                                                                                                                        */
/* Obs  Result                          Value    Unit    Formula                                                          */
/*                                                                                                                        */
/*  1   Thermal Strain                  -0.01    m/m     a Ã— ?T                                                          */
/*  2   Thermal Stress                   0.01    MPa     -E Ã— a Ã— ?T                                                    */
/*  3   Free Thermal Deformation        -0.01    m       a Ã— ?T Ã— L0                                                    */
/*  4   Reaction Force               10000.00    N       s Ã— A                                                           */
/*                                                                                                                        */
/*------------------------------------------------------------------------------------------------------------------------*/
/*                                                                                                                        */
/* CONVENTIAL UNITS                                                                                                       */
/*                                                                                                                        */
/* WORKX.OUTPUT_CONVERTED total obs=5                                                                                     */
/*                                                                                                                        */
/* Obs           Result                  Value    Unit                                                                    */
/*                                                                                                                        */
/*  1   Thermal Strain (Âµstrain)    -10000.00    Âµe                                                                     */
/*  2   Thermal Stress (kPa)             10.00    kPa                                                                     */
/*  3   Thermal Stress (psi)              1.45    psi                                                                     */
/*  4   Free Deformation (mm)           -10.00    mm                                                                      */
/*  5   Reaction Force (kN)              10.00    kN                                                                      */
/*                                                                                                                        */
/*------------------------------------------------------------------------------------------------------------------------*/
/*                                                                                                                        */
/* WORKX.OUTPUT_SUMMARY total obs=5 23FEB2026:09:26:57                                                                    */
/*                                                                                                                        */
/* Obs  Aspect                                    Value                                                                   */
/*                                                                                                                        */
/*  1   Stress State                              Tensile                                                                 */
/*  2   Stress Magnitude                          0.01 MPa (10 kPa or 1 psi)                                              */
/*  3   Risk Level                                Low                                                                     */
/*  4   Deformation Potential(if unconstrained)  10.00 mm per meter length                                                */
/*  5   Physical Interpretation                   Material attempts to contract but is constrained,inducing tensile stress*/
/**************************************************************************************************************************/

/* _     _                 _               _
| (_)___| |_    ___  _   _| |_ _ __  _   _| |_
| | / __| __|  / _ \| | | | __| `_ \| | | | __|
| | \__ \ |_  | (_) | |_| | |_| |_) | |_| | |_
|_|_|___/\__|  \___/ \__,_|\__| .__/ \__,_|\__|
                              |_|
*/

Altair SLC
LIST: 9:31:23

Altair SLC

Obs                  Parameter                   Unit     Symbol        Value

 1     Initial Temperature                       Â°C        T1      100.00000
 2     Final Temperature                         Â°C        T2      50.000000
 3     Temperature Change                        Â°C        ?T      -50.00000
 4     Young's Modulus                           MPa        E        1.000000
 5     CTE (Coefficient of Thermal Expansion)    1/Â°C      a        0.000200
 6     Reference Length                          m          L0       1.000000
 7     Cross-sectional Area                      mÂ²        A        1.000000

Altair SLC

The PYTHON Procedure

======================================================================

THERMAL STRESS ANALYSIS FOR RUBBER MATERIAL

Temperature Change: 100Â°C ? 50Â°C (?T = -50Â°C)

======================================================================

                                Parameter   Unit Symbol     Value
0                     Initial Temperature    Â°C     T1  100.0000
1                       Final Temperature    Â°C     T2   50.0000
2                      Temperature Change    Â°C     ?T  -50.0000
3                         Young's Modulus    MPa      E    1.0000
4  CTE (Coefficient of Thermal Expansion)  1/Â°C      a    0.0002
5                        Reference Length      m     L0    1.0000
6                    Cross-sectional Area    mÂ²      A    1.0000


?? INPUT PARAMETERS:

--------------------------------------------------

                             Parameter      Value  Unit
                   Initial Temperature      100.0   Â°C
                     Final Temperature       50.0   Â°C
                    Temperature Change      -50.0   Â°C
                       Young's Modulus        1.0   MPa
CTE (Coefficient of Thermal Expansion)     0.0002 1/Â°C
                      Reference Length        1.0     m
                  Cross-sectional Area        1.0   mÂ²
                    Boundary Condition Fixed Ends


?? BASIC RESULTS:

--------------------------------------------------

                  Result    Value Unit       Formula
          Thermal Strain    -0.01  m/m       a Ã— ?T
          Thermal Stress     0.01  MPa -E Ã— a Ã— ?T
Free Thermal Deformation    -0.01    m a Ã— ?T Ã— L0
          Reaction Force 10000.00    N        s Ã— A


?? CONVERTED UNITS:

--------------------------------------------------

                   Result     Value Unit
Thermal Strain (Âµstrain) -10000.00  Âµe
     Thermal Stress (kPa)     10.00  kPa
     Thermal Stress (psi)      1.45  psi
    Free Deformation (mm)    -10.00   mm
      Reaction Force (kN)     10.00   kN


?? ANALYSIS SUMMARY:

--------------------------------------------------

Stress State: Tensile

Stress Magnitude: 0.01 MPa (10 kPa or 1 psi)

Risk Level: Low

Deformation Potential (if unconstrained): 10.00 mm per meter length

Physical Interpretation: Material attempts to contract but is constrained, inducing tensile stress


?? MANUAL VERIFICATION:

----------------------------------------

Thermal strain (e) = a Ã— ?T = 2.00e-04 Ã— (-50) = -0.0100

Stress (s) = -E Ã— e = -(1.0) Ã— (-0.0100) = 0.01 MPa

  ? 10 kPa

  ? 1 psi

Free deformation (per meter) = e Ã— L = -0.0100 Ã— 1 m = -10.0 mm


Altair SLC

The PYTHON Procedure

                                Parameter     Value   Unit Symbol
0                     Initial Temperature  100.0000    Â°C     T1
1                       Final Temperature   50.0000    Â°C     T2
2                      Temperature Change  -50.0000    Â°C     ?T
3                         Young's Modulus    1.0000    MPa      E
4  CTE (Coefficient of Thermal Expansion)    0.0002  1/Â°C      a
5                        Reference Length    1.0000      m     L0
6                    Cross-sectional Area    1.0000    mÂ²      A


Basic Units

Obs             Result              Value      Unit       Formula

 1     Thermal Strain                 -0.01    m/m     a Ã— ?T
 2     Thermal Stress                  0.01    MPa     -E Ã— a Ã— ?T
 3     Free Thermal Deformation       -0.01    m       a Ã— ?T Ã— L0
 4     Reaction Force              10000.00    N       s Ã— A

Convential Units

Obs             Result                Value      Unit

 1     Thermal Strain (Âµstrain)    -10000.00    Âµe
 2     Thermal Stress (kPa)             10.00    kPa
 3     Thermal Stress (psi)              1.45    psi
 4     Free Deformation (mm)           -10.00    mm
 5     Reaction Force (kN)              10.00    kN

Summary

Obs                     Aspect                                                       Value

 1     Stress State                                Tensile
 2     Stress Magnitude                            0.01 MPa (10 kPa or 1 psi)
 3     Risk Level                                  Low
 4     Deformation Potential (if unconstrained)    10.00 mm per meter length
 5     Physical Interpretation                     Material attempts to contract but is constrained, inducing tensile stress

/*
| | ___   __ _
| |/ _ \ / _` |
| | (_) | (_| |
|_|\___/ \__, |
         |___/
*/

1                                          Altair SLC       09:31 Monday, February 23, 2026

NOTE: Copyright 2002-2025 World Programming, an Altair Company
NOTE: Altair SLC 2026 (05.26.01.00.000758)
      Licensed to Roger DeAngelis
NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
NOTE: AUTOEXEC source line
1       +  ï»¿ods _all_ close;
           ^
ERROR: Expected a statement keyword : found "?"
NOTE: Library workx assigned as follows:
      Engine:        SAS7BDAT
      Physical Name: d:\wpswrkx

NOTE: Library slchelp assigned as follows:
      Engine:        WPD
      Physical Name: C:\Progra~1\Altair\SLC\2026\sashelp

NOTE: Library worksas assigned as follows:
      Engine:        SAS7BDAT
      Physical Name: d:\worksas

NOTE: Library workwpd assigned as follows:
      Engine:        WPD
      Physical Name: d:\workwpd


LOG:  9:31:23
NOTE: 1 record was written to file PRINT

NOTE: The data step took :
      real time : 0.094
      cpu time  : 0.000


NOTE: AUTOEXEC processing completed

1          libname workx "d:/wpswrkx";
NOTE: Library workx assigned as follows:
      Engine:        SAS7BDAT
      Physical Name: d:\wpswrkx

2
3         options ls=255 validvarname=v7;;
4         data workx.input_data_numeric;
5         infile cards4 delimiter=',';
6         informat
7         Parameter $38.
8         Unit $8.
9         Symbol $8.
10        ;
11        input
12        Parameter  Value  Unit  Symbol ;
13        format value 9.6;
14        cards4;

NOTE: Data set "WORKX.input_data_numeric" has 7 observation(s) and 4 variable(s)
NOTE: The data step took :
      real time : 0.015
      cpu time  : 0.000


15        Initial Temperature,100,Â°C,T1
16        Final Temperature,50,Â°C,T2
17        Temperature Change,-50,Â°C,?T
18        Young's Modulus,1,MPa,E
19        CTE (Coefficient of Thermal Expansion),0.0002,1/Â°C,a
20        Reference Length,1,m,L0
21        Cross-sectional Area,1,mÂ²,A
22        ;;;;
23        run;quit;
24
25        proc print data=workx.input_data_numeric;
26        run;quit;
NOTE: 7 observations were read from "WORKX.input_data_numeric"
NOTE: Procedure print step took :
      real time : 0.012
      cpu time  : 0.000


27
28        data workx.input_data_text;informat
29        Parameter $18.
30        Value $10.
31        Unit $1.
32        Symbol $1.
33        ;input
34        Parameter & Value &;
35        cards4;
NOTE: Variable "Unit" may not be initialized
NOTE: Variable "Symbol" may not be initialized

NOTE: Data set "WORKX.input_data_text" has 1 observation(s) and 4 variable(s)
NOTE: The data step took :
      real time : 0.015
      cpu time  : 0.015


36        Boundary Condition  Fixed Ends
37        ;;;;
38        run;quit;
39
40        /**************************************************************************************************************************/
41        /* WORKX.INPUT_DATA_TEXT (Boundary Condition)                                                                             */
42        /*                                                                                                                        */
43        /* Obs        Parameter           Value                                                                                   */
44        /*                                                                                                                        */
45        /*  1     Boundary Condition    Fixed Ends                                                                                */
46        /*                                                                                                                        */
47        /* WORKX.INPUT_DATA_NUMERIC                                                                                               */
48        /*                                                                                                                        */
49        /*  Parameter                                    Value    Unit    Symbol                                                  */
50        /*                                                                                                                        */
51        /*  Initial Temperature                        100.000    Â°C        T1                                                    */
52        /*  Final Temperature                           50.000    Â°C        T2                                                    */
53        /*  Temperature Change                         -50.000    Â°C        ?T                                                    */
54        /*  Young's Modulus                              1.000    MPa       E                                                     */
55        /*  CTE (Coefficient of Thermal Expansion)       0.000    1/Â°C      a                                                     */
56        /*  Reference Length                             1.000    m         L0                                                    */
57        /*  Cross-sectional Area                         1.000    mÃ‚Â²       A                                                     */
58        /**************************************************************************************************************************/
59
60        options validvarname=v7; /*--- important ---*/
61        options set=PYTHONHOME "D:\py314";
62        proc python;
63        submit;
64        import pyreadstat as ps
65        import os
66        from datetime import datetime
67        import pyarrow
68        import pandas as pd
69        import numpy as np
70        import matplotlib.pyplot as plt
71        from matplotlib.backends.backend_pdf import PdfPages
72
73        def thermal_stress_analysis():
74            """
75            Analyze thermal deformation and stress in rubber material
76            Temperature decreases from 100Â°C to 50Â°C
77            """
78
79
80            # input_data_numeric.to_parquet('d:/wpswrkx/input_data_numeric.parquet', engine='pyarrow')
81
82            #--- INPUTS FROM THE SLC ----
83
84            input_data_numeric,meta = ps.read_sas7bdat('d:/wpswrkx/input_data_numeric.sas7bdat')
85            input_data_text,meta = ps.read_sas7bdat('d:/wpswrkx/input_data_text.sas7bdat')
86
87            # ==================== CALCULATIONS ====================
88            # Extract values from numeric dataframe
89            E = input_data_numeric[input_data_numeric['Parameter'] == "Young's Modulus"]['Value'].values[0]
90            alpha = input_data_numeric[input_data_numeric['Parameter'] == 'CTE (Coefficient of Thermal Expansion)']['Value'].values[0]
91            delta_T = input_data_numeric[input_data_numeric['Parameter'] == 'Temperature Change']['Value'].values[0]
92            L0 = input_data_numeric[input_data_numeric['Parameter'] == 'Reference Length']['Value'].values[0]
93            A = input_data_numeric[input_data_numeric['Parameter'] == 'Cross-sectional Area']['Value'].values[0]
94            T_initial = input_data_numeric[input_data_numeric['Parameter'] == 'Initial Temperature']['Value'].values[0]
95            T_final = input_data_numeric[input_data_numeric['Parameter'] == 'Final Temperature']['Value'].values[0]
96
97            # Calculate thermal strain
98            thermal_strain = alpha * delta_T
99
100           # Calculate stress (for fixed ends: e = 0, so s = E*(0 - e_thermal) = -E*e_thermal)
101           stress_mpa = -E * thermal_strain
102
103           # Calculate free thermal deformation (if unconstrained)
104           free_deformation_m = thermal_strain * L0
105
106           # Calculate reaction force
107           force_n = stress_mpa * A * 1e6  # Convert MPa to Pa: 1 MPa = 10^6 Pa
108
109           # ==================== OUTPUT DATAFRAME 1: Basic Results ====================
110           output_basic = pd.DataFrame({
111               'Result': [
112                   'Thermal Strain',
113                   'Thermal Stress',
114                   'Free Thermal Deformation',
115                   'Reaction Force'
116               ],
117               'Value': [
118                   thermal_strain,
119                   stress_mpa,
120                   free_deformation_m,
121                   force_n
122               ],
123               'Unit': [
124                   'm/m',
125                   'MPa',
126                   'm',
127                   'N'
128               ],
129               'Formula': [
130                   'a Ã— ?T',
131                   '-E Ã— a Ã— ?T',
132                   'a Ã— ?T Ã— L0',
133                   's Ã— A'
134               ]
135           })
136
137           # ==================== OUTPUT DATAFRAME 2: Converted Units ====================
138           output_converted = pd.DataFrame({
139               'Result': [
140                   'Thermal Strain (Âµstrain)',
141                   'Thermal Stress (kPa)',
142                   'Thermal Stress (psi)',
143                   'Free Deformation (mm)',
144                   'Reaction Force (kN)'
145               ],
146               'Value': [
147                   thermal_strain * 1e6,        # m/m to microstrain
148                   stress_mpa * 1000,           # MPa to kPa (1 MPa = 1000 kPa)
149                   stress_mpa * 145.0377,       # MPa to psi (1 MPa = 145.0377 psi)
150                   free_deformation_m * 1000,   # m to mm
151                   force_n / 1000               # N to kN
152               ],
153               'Unit': [
154                   'Âµe',
155                   'kPa',
156                   'psi',
157                   'mm',
158                   'kN'
159               ]
160           })
161
162           # ==================== OUTPUT DATAFRAME 3: Summary with Interpretation ====================
163           stress_magnitude = abs(stress_mpa)
164           if stress_magnitude < 1:
165               risk_level = "Low"
166           elif stress_magnitude < 5:
167               risk_level = "Moderate"
168           elif stress_magnitude < 10:
169               risk_level = "High"
170           else:
171               risk_level = "Critical - May exceed material limits"
172
173           output_summary = pd.DataFrame({
174               'Aspect': [
175                   'Stress State',
176                   'Stress Magnitude',
177                   'Risk Level',
178                   'Deformation Potential (if unconstrained)',
179                   'Physical Interpretation'
180               ],
181               'Value': [
182                   'Tensile' if stress_mpa > 0 else 'Compressive',
183                   f'{abs(stress_mpa):.2f} MPa ({abs(stress_mpa*1000):.0f} kPa or {abs(stress_mpa*145):.0f} psi)',
184                   risk_level,
185                   f'{abs(free_deformation_m*1000):.2f} mm per meter length',
186                   'Material attempts to contract but is constrained, inducing tensile stress'
187               ]
188           })
189
190           print(input_data_numeric)
191
192           # Save to parquet files
193           #input_data_text.to_parquet('d:/wpswrkx/input_data_text.parquet', engine='pyarrow')
194
195           output_basic.to_parquet('d:/wpswrkx/output_basic.parquet', engine='pyarrow')
196           output_converted.to_parquet('d:/wpswrkx/output_converted.parquet', engine='pyarrow')
197           output_summary.to_parquet('d:/wpswrkx/output_summary.parquet', engine='pyarrow')
198
199           # For display purposes, combine them
200           input_data_display = pd.concat([input_data_numeric, input_data_text], ignore_index=True)
201
202
203
204           return input_data_display, output_basic, output_converted, output_summary, T_initial, T_final, thermal_strain, stress_mpa, free_deformation_m, force_n
205
206
207       def verify_calculations():
208           """Verify the calculations manually"""
209           print("\n?? MANUAL VERIFICATION:")
210           print("-" * 40)
211
212           E = 1.0  # MPa
213           alpha = 200e-6  # 1/Â°C
214           delta_T = -50  # Â°C
215
216           thermal_strain = alpha * delta_T
217           stress = -E * thermal_strain
218           stress_kpa = stress * 1000
219           stress_psi = stress * 145.0377
220
221           print(f"Thermal strain (e) = a Ã— ?T = {alpha:.2e} Ã— ({delta_T}) = {thermal_strain:.4f}")
222           print(f"Stress (s) = -E Ã— e = -({E}) Ã— ({thermal_strain:.4f}) = {stress:.2f} MPa")
223           print(f"  ? {stress_kpa:.0f} kPa")
224           print(f"  ? {stress_psi:.0f} psi")
225           print(f"Free deformation (per meter) = e Ã— L = {thermal_strain:.4f} Ã— 1 m = {thermal_strain*1000:.1f} mm")
226
227           return stress, stress_kpa, stress_psi
228
229
230       # ==================== MAIN EXECUTION ====================
231       if __name__ == "__main__":
232           print("=" * 70)
233           print("THERMAL STRESS ANALYSIS FOR RUBBER MATERIAL")
234           print("Temperature Change: 100Â°C ? 50Â°C (?T = -50Â°C)")
235           print("=" * 70)
236
237           # Run the analysis
238           input_df, output_basic_df, output_converted_df, output_summary_df, T_initial, T_final, thermal_strain, stress_mpa, free_deformation_m, force_n = thermal_stress_analysis()
239
240           print("\n?? INPUT PARAMETERS:")
241           print("-" * 50)
242           print(input_df[['Parameter', 'Value', 'Unit']].to_string(index=False))
243
244           print("\n?? BASIC RESULTS:")
245           print("-" * 50)
246           print(output_basic_df.to_string(index=False))
247
248           print("\n?? CONVERTED UNITS:")
249           print("-" * 50)
250           pd.set_option('display.float_format', '{:.2f}'.format)
251           print(output_converted_df.to_string(index=False))
252
253           print("\n?? ANALYSIS SUMMARY:")
254           print("-" * 50)
255           for _, row in output_summary_df.iterrows():
256               print(f"{row['Aspect']}: {row['Value']}")
257
258           # Run verification
259           stress, stress_kpa, stress_psi = verify_calculations()
260       endsubmit;

NOTE: Submitting statements to Python:


261       run;
NOTE: Procedure python step took :
      real time : 12.648
      cpu time  : 0.000


262
263       /*--- use python 310 just for coverting parquet files to sas datasets ---*/
264
265       options validvarname=v7;
266       options set=PYTHONHOME "D:\py310";
267       proc python;
268       submit;
269       import pyarrow
270       import pandas as pd
271       input_data_numeric = pd.read_parquet('d:/wpswrkx/input_data_numeric.parquet', engine='pyarrow')
272       print(input_data_numeric)
273       input_data_text = pd.read_parquet('d:/wpswrkx/input_data_text.parquet', engine='pyarrow')
274       output_basic = pd.read_parquet('d:/wpswrkx/output_basic.parquet', engine='pyarrow')
275       output_converted = pd.read_parquet('d:/wpswrkx/output_converted.parquet', engine='pyarrow')
276       output_summary = pd.read_parquet('d:/wpswrkx/output_summary.parquet', engine='pyarrow')
277       endsubmit;

NOTE: Submitting statements to Python:


278       import python=input_data_numeric data=workx.input_data_numeric;
NOTE: Creating data set 'WORKX.input_data_numeric' from Python data frame 'input_data_numeric'
NOTE: Data set "WORKX.input_data_numeric" has 7 observation(s) and 4 variable(s)

279       import python=input_data_text    data=workx.input_data_text   ;
NOTE: Creating data set 'WORKX.input_data_text' from Python data frame 'input_data_text'
NOTE: Data set "WORKX.input_data_text" has 1 observation(s) and 4 variable(s)

280       import python=output_basic       data=workx.output_basic      ;
NOTE: Creating data set 'WORKX.output_basic' from Python data frame 'output_basic'
NOTE: Data set "WORKX.output_basic" has 4 observation(s) and 4 variable(s)

281       import python=output_converted   data=workx.output_converted  ;
NOTE: Creating data set 'WORKX.output_converted' from Python data frame 'output_converted'
NOTE: Data set "WORKX.output_converted" has 5 observation(s) and 3 variable(s)

282       import python=output_summary     data=workx.output_summary    ;
NOTE: Creating data set 'WORKX.output_summary' from Python data frame 'output_summary'
NOTE: Data set "WORKX.output_summary" has 5 observation(s) and 2 variable(s)

283       run;quit;
NOTE: Procedure python step took :
      real time : 8.646
      cpu time  : 0.046


284
285       proc print data=workx.output_basic;
286       title "Basic Units";
287       run;quit;
NOTE: 4 observations were read from "WORKX.output_basic"
NOTE: Procedure print step took :
      real time : 0.025
      cpu time  : 0.000


288
289       proc print data=workx.output_converted;
290       title "Convential Units";
291       run;quit;
NOTE: 5 observations were read from "WORKX.output_converted"
NOTE: Procedure print step took :
      real time : 0.013
      cpu time  : 0.015


292
293       proc print data=workx.output_summary;
294       title "Summary";
295       run;quit;
NOTE: 5 observations were read from "WORKX.output_summary"
NOTE: Procedure print step took :
      real time : 0.019
      cpu time  : 0.000


296
297       /**************************************************************************************************************************/
298       /* BASIC UNITS                                                                                                            */
299       /*                                                                                                                        */
300       /* WORKX.OUTPUT_BASIC total obs=4                                                                                         */
301       /*                                                                                                                        */
302       /* Obs  Result                          Value    Unit    Formula                                                          */
303       /*                                                                                                                        */
304       /*  1   Thermal Strain                  -0.01    m/m     a Ãƒâ€” ?T                                                          */
305       /*  2   Thermal Stress                   0.01    MPa     -E Ãƒâ€” a Ãƒâ€” ?T                                                    */
306       /*  3   Free Thermal Deformation        -0.01    m       a Ãƒâ€” ?T Ãƒâ€” L0                                                    */
307       /*  4   Reaction Force               10000.00    N       s Ãƒâ€” A                                                           */
308       /*                                                                                                                        */
309       /*------------------------------------------------------------------------------------------------------------------------*/
310       /*                                                                                                                        */
311       /* CONVENTIAL UNITS                                                                                                       */
312       /*                                                                                                                        */
313       /* WORKX.OUTPUT_CONVERTED total obs=5                                                                                     */
314       /*                                                                                                                        */
315       /* Obs           Result                  Value    Unit                                                                    */
316       /*                                                                                                                        */
317       /*  1   Thermal Strain (Ã‚Âµstrain)    -10000.00    Ã‚Âµe                                                                     */
318       /*  2   Thermal Stress (kPa)             10.00    kPa                                                                     */
319       /*  3   Thermal Stress (psi)              1.45    psi                                                                     */
320       /*  4   Free Deformation (mm)           -10.00    mm                                                                      */
321       /*  5   Reaction Force (kN)              10.00    kN                                                                      */
322       /*                                                                                                                        */
323       /*------------------------------------------------------------------------------------------------------------------------*/
324       /*                                                                                                                        */
325       /* WORKX.OUTPUT_SUMMARY total obs=5 23FEB2026:09:26:57                                                                    */
326       /*                                                                                                                        */
327       /* Obs  Aspect                                    Value                                                                   */
328       /*                                                                                                                        */
329       /*  1   Stress State                              Tensile                                                                 */
330       /*  2   Stress Magnitude                          0.01 MPa (10 kPa or 1 psi)                                              */
331       /*  3   Risk Level                                Low                                                                     */
332       /*  4   Deformation Potential(if unconstrained)  10.00 mm per meter length                                                */
333       /*  5   Physical Interpretation                   Material attempts to contract but is constrained,inducing tensile stress*/
334       /**************************************************************************************************************************/
335
336       /*              _
337         ___ _ __   __| |
338        / _ \ `_ \ / _` |
339       |  __/ | | | (_| |
340        \___|_| |_|\__,_|
341
342       */
343
344
ERROR: Error printed on page 1

NOTE: Submitted statements took :
      real time : 22.332
      cpu time  : 0.156



/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
