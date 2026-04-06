## GMACS Version 2.20.34; ** AEP **; Compiled 2026-01-15

# Block structure
# Number of block groups
2
# Block structure (number of blocks per block group)
3 # block group 1
43 # block group 2
# The blocks
#Block 1: 
2018 2018 # block_group_1_block_1
2019 2019 # block_group_1_block_2
2020 2020 # block_group_1_block_3
#Block 2: 
1983 1983 # block_group_2_block_1
1984 1984 # block_group_2_block_2
1985 1985 # block_group_2_block_3
1986 1986 # block_group_2_block_4
1987 1987 # block_group_2_block_5
1988 1988 # block_group_2_block_6
1989 1989 # block_group_2_block_7
1990 1990 # block_group_2_block_8
1991 1991 # block_group_2_block_9
1992 1992 # block_group_2_block_10
1993 1993 # block_group_2_block_11
1994 1994 # block_group_2_block_12
1995 1995 # block_group_2_block_13
1996 1996 # block_group_2_block_14
1997 1997 # block_group_2_block_15
1998 1998 # block_group_2_block_16
1999 1999 # block_group_2_block_17
2000 2000 # block_group_2_block_18
2001 2001 # block_group_2_block_19
2002 2002 # block_group_2_block_20
2003 2003 # block_group_2_block_21
2004 2004 # block_group_2_block_22
2005 2005 # block_group_2_block_23
2006 2006 # block_group_2_block_24
2007 2007 # block_group_2_block_25
2008 2008 # block_group_2_block_26
2009 2009 # block_group_2_block_27
2010 2010 # block_group_2_block_28
2011 2011 # block_group_2_block_29
2012 2012 # block_group_2_block_30
2013 2013 # block_group_2_block_31
2014 2014 # block_group_2_block_32
2015 2015 # block_group_2_block_33
2016 2016 # block_group_2_block_34
2017 2017 # block_group_2_block_35
2018 2018 # block_group_2_block_36
2019 2019 # block_group_2_block_37
2020 2020 # block_group_2_block_38
2021 2021 # block_group_2_block_39
2022 2022 # block_group_2_block_40
2023 2023 # block_group_2_block_41
2024 2024 # block_group_2_block_42
2025 2025 # block_group_2_block_43
# Number of environmental treatments
0

##  ------------------------------------------------------------------------------------ ##
##  OTHER  CONTROLS
##  ------------------------------------------------------------------------------------ ##
1982 # First year of recruitment estimation
2024 # Last year of recruitment estimation
   1 # Consider terminal molting (0 = off, 1 = on). If on, the calc_stock_recruitment_relationship() isn't called in the procedure
   1 # Phase for recruitment estimation
   2 # Phase for recruitment sex-ratio estimation
0.50 # Initial value for recruitment sex-ratio
   2 # Initial conditions (0 = Unfished, 1 = Steady-state fished, 2 = Free parameters, 3 = Free parameters (revised)), 5 = zero population
   1 # Reference size-class for initial conditons = 3
1.00 # Lambda (proportion of mature male biomass for SPR reference points)
   0 # Stock-Recruit-Relationship (0 = none, 1 = Beverton-Holt)
   0 # Use years specified to computed average sex ratio in the calculation of average recruitment for reference points (0 = off -i.e. Rec based on End year, 1 = on)
 200 # Years to compute equilibria
   5 # Phase for deviation parameters
1940 # First year of bias-correction
1950 # First full bias-correction
2050 # Last full bias-correction
2051 # Last year of bias-correction
   0 # recruitment size distribution option (0: standard way; 1: Tanner crab approach)
   0 # Set to 1 to copy growth from males to females)

# Expecting 98 theta parameters

# MAIN PARS:  Initial  Lower_bound  Upper_bound Prior_type     Prior_1      Prior_2  Phase  Block Blk_fn  Env_L Env_vr     RW RW_Blk RW_Sigma
            16.500000   -10.000000    20.000000          0   -10.000000    20.000000     -2      0      0      0      0      0      0  30.0000 # Log(R0)
            15.000000   -10.000000    30.000000          0    10.000000    20.000000     -1      0      0      0      0      0      0  30.0000 # Log(Rinitial)
            13.260000   -10.000000    30.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Log(Rbar)
            32.500000     7.500000    42.500000          0    32.500000     2.250000     -4      0      0      0      0      0      0  30.0000 # Recruitment_ra-males
             1.000000     0.100000    10.000000          0     0.100000     5.000000     -4      0      0      0      0      0      0  30.0000 # Recruitment_rb-males
             0.000000   -10.000000    10.000000          0     0.000000    20.000000     -4      0      0      0      0      0      0  30.0000 # Recruitment_ra-females (ln-scale offset to males!)
             0.000000   -10.000000    10.000000          0     0.000000    20.000000     -3      0      0      0      0      0      0  30.0000 # Recruitment_rb-females (ln-scale offset to males!)
            -0.900000   -10.000000     0.750000          0   -10.000000     0.750000     -4      0      0      0      0      0      0  30.0000 # log(SigmaR)
             0.750000     0.200000     1.000000          3     3.000000     2.000000     -2      0      0      0      0      0      0  30.0000 # Steepness
             0.010000     0.000100     1.000000          3     1.010000     1.010000     -3      0      0      0      0      0      0  30.0000 # Rho
             0.000000   -10.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_1
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_2
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_3
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_4
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_5
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_6
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_7
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_8
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_9
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_10
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_11
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_12
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_13
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_14
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_15
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_16
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_17
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_18
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_19
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_20
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_21
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_mature_newshell_class_22
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_1
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_2
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_3
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_4
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_5
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_6
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_7
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_8
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_9
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_10
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_11
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_12
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_13
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_14
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_15
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_16
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_17
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_18
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_19
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_20
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_21
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_male_mature_immature_newshell_class_22
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_1
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_2
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_3
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_4
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_5
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_6
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_7
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_8
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_9
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_10
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_11
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_12
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_13
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_14
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_15
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_16
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_17
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_18
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_19
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_20
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_21
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_mature_newshell_class_22
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_1
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_2
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_3
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_4
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_5
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_6
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_7
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_8
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_9
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_10
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_11
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_12
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_13
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_14
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_15
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_16
             0.000000   -20.000000    25.000000          0    10.000000    20.000000      1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_17
           -19.000000   -20.000000    25.000000          0    10.000000    20.000000     -1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_18
           -19.000000   -20.000000    25.000000          0    10.000000    20.000000     -1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_19
           -19.000000   -20.000000    25.000000          0    10.000000    20.000000     -1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_20
           -19.000000   -20.000000    25.000000          0    10.000000    20.000000     -1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_21
           -19.000000   -20.000000    25.000000          0    10.000000    20.000000     -1      0      0      0      0      0      0  30.0000 # Initial_logN_for_sex_female_mature_immature_newshell_class_22
# NO EXTRA PARS: Initial  Lower_bound  Upper_bound Prior_type      Prior_1     Prior_2  Phase    Reltve 

##  ------------------------------------------------------------------------------------ ##
## Allometry
##  ------------------------------------------------------------------------------------ ##
# weight-at-length input  method:
## 1 = allometry  [w_l = a*l^b]
## 2 = vector by sex
## 3 = matrix by sex
2  #--selected method
     0.00000766     0.00001290     0.00002000     0.00002950     0.00004170     0.00005680     0.00007530     0.00009745     0.00012369     0.00015433     0.00018974     0.00023028     0.00027631     0.00032821     0.00038633     0.00045106     0.00052275     0.00060180     0.00068856     0.00078342     0.00088677     0.00099897
     0.00000766     0.00001290     0.00002000     0.00002950     0.00004170     0.00005680     0.00007530     0.00009745     0.00012369     0.00015433     0.00018974     0.00023028     0.00027631     0.00032821     0.00038633     0.00045106     0.00052275     0.00060180     0.00068856     0.00078342     0.00088677     0.00099897
     0.00000917     0.00001440     0.00002130     0.00002980     0.00004030     0.00005290     0.00006770     0.00008480     0.00010445     0.00012676     0.00015186     0.00017988     0.00021096     0.00024523     0.00028282     0.00032385     0.00036845     0.00041673     0.00046883     0.00052485     0.00058492     0.00064916
     0.00000917     0.00001440     0.00002130     0.00002980     0.00004030     0.00005290     0.00006770     0.00008480     0.00010445     0.00012676     0.00015186     0.00017988     0.00021096     0.00024523     0.00028282     0.00032385     0.00036845     0.00041673     0.00046883     0.00052485     0.00058492     0.00064916
##  ------------------------------------------------------------------------------------ ##

##  ------------------------------------------------------------------------------------ ##
## Proportion mature by sex and size
 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000
 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000
##  ------------------------------------------------------------------------------------ ##

##  ------------------------------------------------------------------------------------ ##
# Proportion legal by sex and size
 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 1.00000000
 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000
##  ------------------------------------------------------------------------------------ ##


## ==================================================================================== ##
## GROWTH PARAMETER CONTROLS                                                            ##
## ==================================================================================== ##
## 
# Maximum number of size-classes to which recruitment must occur
 3 3
# Use functional maturity for terminally molting animals (0=no; 1=Yes)?
0
# Growth transition
##Type_1: Options for the growth matrix
#  1: Pre-specified growth transition matrix (requires molt probability)
#  2: Pre-specified size transition matrix (molt probability is ignored)
#  3: Growth increment is gamma distributed (requires molt probability)
#  4: Post-molt size is gamma distributed (requires molt probability)
#  5: Von Bert.: kappa varies among individuals (requires molt probability)
#  6: Von Bert.: Linf varies among individuals (requires molt probability)
#  7: Von Bert.: kappa and Linf varies among individuals (requires molt probability)
#  8: Growth increment is normally distributed (requires molt probability)
## Type_2: Options for the growth increment model matrix
#  1: Linear
##     1. intercept 
##     2. slope
##     3. gamma distribution scale parameter (on ln-scale)
#  2: Individual
#  3: Individual (Same as 2)
#  4: Power law for mean post-molt size (3 parameters)
##     1. ln-scale intercept 
##     2. ln-scale slope
##     3. gamma distribution scale parameter (on ln-scale)
#  5: Alternative power law for mean post-molt size (5 parameters)
##     1. reference (small) pre-molt size (constant: must have phase < 0)
##     2. mean post-molt size corresponding to 1.
##     3. reference (large) pre-molt size (constant: must have phase < 0)
##     4. mean post-molt size corresponding to 3.
##     5. gamma distribution scale parameter (on arithmetic scale)
#  Block: Block number for time-varying growth   
## Type_1 Type_2  Block
        4      1      0 
        4      1      0 
# Molt probability
# Type: Options for the molt probability function
#  0: Pre-specified
#  1: Constant at 1
#  2: Logistic
#  3: Individual
#  Block: Block number for time-varying growth   
## Type Block
      1     0 
      1     0 
# Mature probability
# Type: Options for the mature probability function
#  0: Pre-specified
#  1: Constant at 1
#  2: Logistic
#  3: Individual
# Block: Block number for time-varying growth   
## Type Block
      0     2 
      0     2 

## General parameter specificiations 
##  Initial: Initial value for the parameter (must lie between lower and upper)
##  Lower & Upper: Range for the parameter
##  Prior type:
##   0: Uniform   - parameters are the range of the uniform prior
##   1: Normal    - parameters are the mean and sd
##   2: Lognormal - parameters are the mean and sd of the log
##   3: Beta      - parameters are the two beta parameters [see dbeta]
##   4: Gamma     - parameters are the two gamma parameters [see dgamma]
##  Phase: Set equal to a negative number not to estimate
##  Relative: 0: absolute; 1 relative 
##  Block: Block number for time-varying selectivity   
##  Block_fn: 0:absolute values; 1:exponential
##  Env_L: Environmental link - options are 0:none; 1:additive; 2:multiplicative; 3:exponential
##  EnvL_var: Environmental variable
##  RW: 0 for no random walk changes; 1 otherwise
##  RW_blk: Block number for random walks
##  Sigma_RW: Sigma used for the random walk

### Parameter inputs for growth transitions
# Inputs for sex * type 1
# MAIN PARS: Initial  Lower_bound  Upper_bound Prior_type       Prior_1      Prior_2  Phase  Block Blk_fn  Env_L Env_vr     RW RW_Blk RW_Sigma
             2.049000    -5.000000    20.000000          0     2.049000     1.000000      3      0      0      0      0      0      0   0.3000 # Alpha_male
            -0.225800    -1.000000     0.000000          0    -0.225800     0.500000      3      0      0      0      0      0      0   0.3000 # Beta_male
             0.250000     0.001000     5.000000          0     0.000000   999.000000     -3      0      0      0      0      0      0   0.3000 # Gscale_male
# EXTRA PARS: Initial  Lower_bound  Upper_bound Prior_type      Prior_1      Prior_2  Phase     Reltve 

### Parameter inputs for growth transitions
# Inputs for sex * type 2
# MAIN PARS: Initial  Lower_bound  Upper_bound Prior_type       Prior_1      Prior_2  Phase  Block Blk_fn  Env_L Env_vr     RW RW_Blk RW_Sigma
            -1.153900    -5.000000    10.000000          0    -1.153900     1.000000      3      0      0      0      0      0      0   0.3000 # Alpha_female
            -0.338900    -1.000000     0.000000          0    -0.338900     0.500000      3      0      0      0      0      0      0   0.3000 # Beta_female
             0.250000     0.001000     5.000000          0     0.000000   999.000000     -3      0      0      0      0      0      0   0.3000 # Gscale_female
# EXTRA PARS: Initial  Lower_bound  Upper_bound Prior_type      Prior_1      Prior_2  Phase     Reltve 

### Parameter inputs for probability of molting for sex1
# EXTRA PARS: Initial  Lower_bound  Upper_bound Prior_type      Prior_1      Prior_2  Phase     Reltve 

### Parameter inputs for probability of molting for sex2
# EXTRA PARS: Initial  Lower_bound  Upper_bound Prior_type      Prior_1      Prior_2  Phase     Reltve 

### Parameter inputs for probability of maturing for sex 1
# EXTRA PARS: Initial  Lower_bound  Upper_bound Prior_type      Prior_1      Prior_2  Phase     Reltve 

### Parameter inputs for probability of maturing for sex 2
# EXTRA PARS: Initial  Lower_bound  Upper_bound Prior_type      Prior_1      Prior_2  Phase     Reltve 

# Using custom mature probability
#Pre-specified mature probability
0.0007 0.0037 0.0148 0.0373 0.0713 0.1181 0.1738 0.2357 0.3022 0.3659 0.4146 0.4508 0.4911 0.5512 0.6445 0.7581 0.8540 0.9177 0.9596 0.9851 0.9960 0.9989 
0.0007 0.0037 0.0148 0.0373 0.0713 0.1181 0.1738 0.2357 0.3022 0.3659 0.4146 0.4508 0.4911 0.5512 0.6445 0.7581 0.8540 0.9177 0.9596 0.9851 0.9960 0.9989 
0.0007 0.0037 0.0148 0.0373 0.0713 0.1181 0.1738 0.2357 0.3022 0.3659 0.4146 0.4508 0.4911 0.5512 0.6445 0.7581 0.8540 0.9177 0.9596 0.9851 0.9960 0.9989 
0.0007 0.0037 0.0148 0.0373 0.0713 0.1181 0.1738 0.2357 0.3022 0.3659 0.4146 0.4508 0.4911 0.5512 0.6445 0.7581 0.8540 0.9177 0.9596 0.9851 0.9960 0.9989 
0.0007 0.0037 0.0148 0.0373 0.0713 0.1181 0.1738 0.2357 0.3022 0.3659 0.4146 0.4508 0.4911 0.5512 0.6445 0.7581 0.8540 0.9177 0.9596 0.9851 0.9960 0.9989 
0.0007 0.0037 0.0148 0.0373 0.0713 0.1181 0.1738 0.2357 0.3022 0.3659 0.4146 0.4508 0.4911 0.5512 0.6445 0.7581 0.8540 0.9177 0.9596 0.9851 0.9960 0.9989 
0.0000 0.0000 0.0010 0.0159 0.0521 0.1024 0.1432 0.1608 0.1536 0.1435 0.1744 0.2581 0.3738 0.5094 0.6622 0.8097 0.9112 0.9598 0.9829 0.9960 1.0000 1.0000 
0.0007 0.0009 0.0000 0.0000 0.0210 0.0592 0.0775 0.0921 0.1677 0.2887 0.3603 0.3588 0.3348 0.3336 0.3909 0.5137 0.6799 0.8471 0.9559 0.9952 1.0000 1.0000 
0.0002 0.0004 0.0000 0.0000 0.0086 0.0324 0.0768 0.1358 0.1931 0.2376 0.2647 0.2685 0.2441 0.2407 0.3562 0.5802 0.7936 0.9329 0.9956 1.0000 0.9982 0.9990 
0.0000 0.0000 0.0042 0.0268 0.0683 0.1242 0.1800 0.2317 0.2853 0.3410 0.3926 0.4414 0.4961 0.5662 0.6608 0.7704 0.8672 0.9370 0.9801 1.0000 1.0000 1.0000 
0.0000 0.0000 0.0014 0.0098 0.0314 0.0683 0.1198 0.2077 0.3735 0.5729 0.6801 0.6789 0.6648 0.6922 0.7679 0.8644 0.9234 0.9389 0.9571 0.9882 1.0000 1.0000 
0.0000 0.0000 0.0076 0.0248 0.0476 0.0793 0.1285 0.1999 0.2929 0.3914 0.4651 0.5010 0.5053 0.5132 0.5848 0.7142 0.8301 0.9043 0.9537 0.9870 1.0000 1.0000 
0.0000 0.0000 0.0044 0.0188 0.0427 0.0768 0.1203 0.1733 0.2370 0.3094 0.3858 0.4642 0.5460 0.6296 0.7112 0.7872 0.8546 0.9107 0.9534 0.9822 0.9988 1.0000 
0.0000 0.0000 0.0047 0.0207 0.0466 0.0815 0.1219 0.1662 0.2150 0.2681 0.3241 0.3848 0.4553 0.5387 0.6361 0.7389 0.8297 0.9000 0.9505 0.9835 1.0000 1.0000 
0.0008 0.0014 0.0000 0.0000 0.0278 0.0799 0.1221 0.1516 0.1954 0.2448 0.2568 0.2389 0.2494 0.3219 0.4617 0.6421 0.8071 0.9237 0.9840 0.9996 0.9999 0.9999 
0.0000 0.0000 0.0006 0.0088 0.0356 0.0769 0.1139 0.1585 0.2512 0.3644 0.4053 0.3696 0.3431 0.3890 0.5398 0.7476 0.8891 0.9369 0.9613 0.9899 1.0000 1.0000 
0.0053 0.0203 0.0430 0.0739 0.1117 0.1554 0.2036 0.2550 0.3085 0.3627 0.4157 0.4706 0.5340 0.6076 0.6869 0.7658 0.8362 0.8941 0.9391 0.9717 0.9931 1.0000 
0.0000 0.0000 0.0015 0.0060 0.0136 0.0398 0.1131 0.2211 0.3113 0.3604 0.3772 0.3867 0.4277 0.5234 0.6784 0.8477 0.9410 0.9515 0.9562 0.9814 1.0000 1.0000 
0.0000 0.0000 0.0038 0.0181 0.0420 0.0738 0.1088 0.1463 0.1901 0.2430 0.3064 0.3816 0.4692 0.5676 0.6723 0.7736 0.8562 0.9155 0.9568 0.9842 0.9998 1.0000 
0.0000 0.0000 0.0010 0.0018 0.0000 0.0050 0.0693 0.1832 0.2915 0.3547 0.3531 0.3124 0.3027 0.3728 0.5456 0.7692 0.9220 0.9739 0.9880 0.9973 1.0000 1.0000 
0.0000 0.0029 0.0171 0.0407 0.0712 0.1055 0.1398 0.1727 0.2050 0.2367 0.2669 0.2978 0.3355 0.3952 0.5004 0.6410 0.7746 0.8779 0.9481 0.9883 1.0000 1.0000 
0.0017 0.0030 0.0000 0.0000 0.0255 0.1051 0.1918 0.2712 0.3511 0.4291 0.4913 0.5269 0.5306 0.5269 0.5691 0.6671 0.7872 0.8966 0.9672 0.9953 1.0000 1.0000 
0.0027 0.0164 0.0361 0.0624 0.0959 0.1366 0.1841 0.2379 0.2968 0.3594 0.4236 0.4885 0.5539 0.6205 0.6893 0.7579 0.8215 0.8765 0.9216 0.9566 0.9820 0.9990 
0.0000 0.0000 0.0155 0.0581 0.0883 0.1188 0.2052 0.3346 0.4254 0.4475 0.4257 0.4053 0.4466 0.5469 0.6422 0.7149 0.7957 0.8855 0.9546 0.9914 1.0000 1.0000 
0.0000 0.0000 0.0000 0.0000 0.0268 0.0949 0.2000 0.3231 0.4273 0.4898 0.5038 0.4821 0.4571 0.4684 0.5599 0.7088 0.8284 0.8926 0.9376 0.9770 0.9996 1.0000 
0.0007 0.0037 0.0148 0.0373 0.0713 0.1181 0.1738 0.2357 0.3022 0.3659 0.4146 0.4508 0.4911 0.5512 0.6445 0.7581 0.8540 0.9177 0.9596 0.9851 0.9960 0.9989 
0.0000 0.0000 0.0041 0.0500 0.1402 0.2512 0.3233 0.3399 0.3289 0.3046 0.2662 0.2208 0.1853 0.1930 0.2908 0.4691 0.6621 0.8244 0.9348 0.9920 1.0000 1.0000 
0.0000 0.0000 0.0110 0.0413 0.0865 0.1475 0.2232 0.3096 0.3997 0.4881 0.5713 0.6488 0.7234 0.7939 0.8548 0.9033 0.9394 0.9648 0.9823 0.9942 1.0000 1.0000 
0.0000 0.0000 0.0130 0.0323 0.0589 0.0932 0.1350 0.1839 0.2391 0.2992 0.3619 0.4274 0.4986 0.5761 0.6579 0.7396 0.8142 0.8775 0.9279 0.9655 0.9917 1.0000 
0.0007 0.0037 0.0148 0.0373 0.0713 0.1181 0.1738 0.2357 0.3022 0.3659 0.4146 0.4508 0.4911 0.5512 0.6445 0.7581 0.8540 0.9177 0.9596 0.9851 0.9960 0.9989 
0.0000 0.0000 0.0084 0.0328 0.0687 0.1171 0.1777 0.2482 0.3242 0.4017 0.4768 0.5476 0.6145 0.6770 0.7340 0.7842 0.8268 0.8630 0.8964 0.9277 0.9542 0.9747 
0.0007 0.0037 0.0148 0.0373 0.0713 0.1181 0.1738 0.2357 0.3022 0.3659 0.4146 0.4508 0.4911 0.5512 0.6445 0.7581 0.8540 0.9177 0.9596 0.9851 0.9960 0.9989 
0.0008 0.0002 0.0000 0.0000 0.0180 0.0806 0.1836 0.3098 0.4233 0.4994 0.5259 0.5133 0.4948 0.5231 0.6644 0.8744 1.0000 1.0000 1.0000 0.9984 0.9998 1.0000 
0.0007 0.0037 0.0148 0.0373 0.0713 0.1181 0.1738 0.2357 0.3022 0.3659 0.4146 0.4508 0.4911 0.5512 0.6445 0.7581 0.8540 0.9177 0.9596 0.9851 0.9960 0.9989 
0.0000 0.0000 0.0158 0.0556 0.1202 0.1981 0.2624 0.3082 0.3531 0.4082 0.4777 0.5619 0.6574 0.7552 0.8408 0.9065 0.9516 0.9788 0.9936 1.0000 1.0000 1.0000 
0.0000 0.0000 0.0083 0.0354 0.0800 0.1430 0.2214 0.3091 0.3972 0.4830 0.5703 0.6583 0.7418 0.8160 0.8771 0.9229 0.9534 0.9716 0.9836 0.9924 0.9980 1.0000 
0.0071 0.0266 0.0582 0.0965 0.1286 0.1517 0.1724 0.1957 0.2243 0.2644 0.3257 0.4139 0.5300 0.6589 0.7704 0.8520 0.9097 0.9494 0.9759 0.9925 1.0000 1.0000 
0.0007 0.0037 0.0148 0.0373 0.0713 0.1181 0.1738 0.2357 0.3022 0.3659 0.4146 0.4508 0.4911 0.5512 0.6445 0.7581 0.8540 0.9177 0.9596 0.9851 0.9960 0.9989 
0.0000 0.0225 0.1386 0.3110 0.4557 0.5365 0.5678 0.5663 0.5493 0.5312 0.5237 0.5365 0.5773 0.6502 0.7546 0.8686 0.9497 0.9867 0.9998 1.0000 1.0000 1.0000 
0.0000 0.0005 0.0196 0.0487 0.0897 0.1429 0.2073 0.2803 0.3574 0.4336 0.5028 0.5640 0.6212 0.6773 0.7341 0.7907 0.8431 0.8889 0.9273 0.9578 0.9802 0.9953 
0.0000 0.0044 0.0177 0.0386 0.0655 0.0987 0.1399 0.1870 0.2341 0.2851 0.3534 0.4423 0.5444 0.6511 0.7534 0.8427 0.9116 0.9582 0.9864 1.0000 1.0000 1.0000 
0.0028 0.0164 0.0364 0.0636 0.0983 0.1406 0.1902 0.2461 0.3068 0.3713 0.4395 0.5099 0.5793 0.6458 0.7086 0.7677 0.8236 0.8748 0.9184 0.9529 0.9782 0.9953 
0.0006 0.0012 0.0000 0.0000 0.0155 0.0621 0.1365 0.2372 0.3613 0.4924 0.6007 0.6653 0.6764 0.6582 0.6677 0.7216 0.7956 0.8715 0.9384 0.9863 1.0000 1.0000 
0.0007 0.0037 0.0148 0.0373 0.0713 0.1181 0.1738 0.2357 0.3022 0.3659 0.4146 0.4508 0.4911 0.5512 0.6445 0.7581 0.8540 0.9177 0.9596 0.9851 0.9960 0.9989 

# Using custom mature probability
#Pre-specified mature probability
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 
0.0061 0.0189 0.0584 0.1775 0.4667 0.7761 0.8119 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 0.9999 


## ==================================================================================== ##
## NATURAL MORTALITY PARAMETER CONTROLS                                                 ##
## ==================================================================================== ##
## 
# Relative: 0 - absolute values; 1+ - based on another M-at-size vector (indexed by ig)
# Type: 0 for standard; 1: Spline
#  For spline: set extra to the number of knots, the parameters are the knots (phase -1) and the log-differences from base M
# Extra: control the number of knots for splines
# Brkpts: number of changes in M by size
# Mirror: Mirror M-at-size over to that for another partition (indexed by ig)
# Block: Block number for time-varying M-at-size
# Block_fn: 0:absolute values; 1:exponential
# Env_L: Environmental link - options are 0: none; 1:additive; 2:multiplicative; 3:exponential
# EnvL_var: Environmental variable
# RW: 0 for no random walk changes; 1 otherwise
# RW_blk: Block number for random walks
# Sigma_RW: Sigma for the random walk parameters
# Mirror_RW: Should time-varying aspects be mirrored (Indexed by ig)
## Relative?   Type   Extra  Brkpts  Mirror   Block  Blk_fn Env_L   EnvL_Vr      RW  RW_blk Sigma_RW Mirr_RW
          0       0       0       0       0       1       1       0       0       0       0   0.3000       0
          1       0       0       0       0       1       1       0       0       0       0   0.3000       0
          0       0       0       0       0       1       1       0       0       0       0   0.3000       0
          3       0       0       0       0       1       1       0       0       0       0   0.3000       0
 # sex*maturity state: male & 1
 # sex*maturity state: male & 2
 # sex*maturity state: female & 1
 # sex*maturity state: female & 2

#      Initial    Lower_bound    Upper_bound  Prior_type        Prior_1        Prior_2  Phase 
    0.27100000     0.15000000     0.70000000           1     0.27100000     0.00454000      4 # M_base_male_mature
    0.00000000    -1.00000000    10.00000000           0     0.00000000     0.25000000      4 # M_male_mature_block_group_1_block_1
    0.00000000    -1.00000000    10.00000000           0     0.00000000     0.25000000      4 # M_male_mature_block_group_1_block_2
    0.00000000    -1.00000000    10.00000000           0     0.00000000     0.25000000     -4 # M_male_mature_block_group_1_block_3
    0.00000000    -1.00000000     1.00000000           0     0.00000000     0.00000000      4 # M_base_male_immature
    0.00000000    -1.00000000    10.00000000           0     0.00000000     0.25000000     -4 # M_male_immature_block_group_1_block_1
    0.00000000    -1.00000000    10.00000000           0     0.00000000     0.25000000      4 # M_male_immature_block_group_1_block_2
    0.00000000    -1.00000000    10.00000000           0     0.00000000     0.25000000     -4 # M_male_immature_block_group_1_block_3
    0.27100000     0.15000000     0.70000000           1     0.27100000     0.00454000      4 # M_base_female_mature
    0.00000000    -1.00000000    10.00000000           0     0.00000000     0.25000000      4 # M_female_mature_block_group_1_block_1
    0.00000000    -1.00000000    10.00000000           0     0.00000000     0.25000000      4 # M_female_mature_block_group_1_block_2
    0.00000000    -1.00000000    10.00000000           0     0.00000000     0.25000000     -4 # M_female_mature_block_group_1_block_3
    0.00000000    -1.00000000     1.00000000           0     0.00000000     0.00000000      4 # M_base_female_immature
    0.00000000    -1.00000000    10.00000000           0     0.00000000     0.25000000      4 # M_female_immature_block_group_1_block_1
    0.00000000    -1.00000000    10.00000000           0     0.00000000     0.25000000      4 # M_female_immature_block_group_1_block_2
    0.00000000    -1.00000000    10.00000000           0     0.00000000     0.25000000     -4 # M_female_immature_block_group_1_block_3

## ==================================================================================== ##
## SELECTIVITY PARAMETERS CONTROLS                                                      ##
## ==================================================================================== ##
## 
# ## Selectivity parameter controls
# ## Selectivity (and retention) types
# ##  <0: Mirror selectivity
# ##   0: Nonparametric selectivity (one parameter per class)
# ##   1: Nonparametric selectivity (one parameter per class, constant from last specified class)
# ##   2: Logistic selectivity (inflection point and width (i.e. 1/slope))
# ##   3: Logistic selectivity (50% and 95% selection)
# ##   4: Double normal selectivity (3 parameters)
# ##   5: Flat equal to zero (1 parameter; phase must be negative)
# ##   6: Flat equal to one (1 parameter; phase must be negative)
# ##   7: Flat-topped double normal selectivity (4 parameters)
# ##   8: Declining logistic selectivity with initial values (50% and 95% selection plus extra)
# ##   9: Cubic-spline (specified with knots and values at knots)
# ##      Inputs: knots (in length units); values at knots (0-1) - at least one should have phase -1
# ##  10: One parameter logistic selectivity (inflection point and slope)
# ##  11: Pre-specified selectivity (matrix by year and class)
# ##  12: Spline with 0 until one size-class and 1 after another
# ##      Inputs: knots (in length units); values at knots (0-1) - at least one should have phase -1
# ##  13: Stacked logistic
# ##  14: Ascending normal (2 parameters: ascending width; size at mode)
## Selectivity specifications --
# ## Extra (type 1): number of selectivity parameters to estimated
# #  Pot_Fishery Trawl_Bycatch NMFS_Trawl_1982 NMFS_Trawl_1989
 1 0 1 1 # is selectivity sex=specific? (1=Yes; 0=No)
 2 2 0 0 # male selectivity type
 2 2 0 0 # female selectivity type
 0 0 0 0 # selectivity within another gear
 0 0 0 0 # male extra parameters for each pattern
 0 0 0 0 # female extra parameters for each pattern
 1 1 0 0 # male: is maximum selectivity at size forced to equal 1 (1) or not (0)
 1 1 0 0 # female: is maximum selectivity at size forced to equal 1 (1) or not (0)
 0 0 0 0 # size-class at which selectivity is forced to equal 1 (ignored if the previous input is 1)
 0 0 0 0 # size-class at which selectivity is forced to equal 1 (ignored if the previous input is 1)
## Retention specifications --
 1 0 0 0 # is retention sex=specific? (1=Yes; 0=No)
 2 5 5 5 # male retention type
 5 5 5 5 # female retention type
 1 0 0 0 # male retention flag (0 = no, 1 = yes)
 0 0 0 0 # female retention flag (0 = no, 1 = yes)
 0 0 0 0 # male extra parameters for each pattern
 0 0 0 0 # female extra parameters for each pattern
 0 0 0 0 # male - should maximum retention be estimated for males (1=Yes; 0=No)
 0 0 0 0 # female - should maximum retention be estimated for females (1=Yes; 0=No)

## General parameter specificiations 
##  Initial: Initial value for the parameter (must lie between lower and upper)
##  Lower & Upper: Range for the parameter
##  Prior type:
##   0: Uniform   - parameters are the range of the uniform prior
##   1: Normal    - parameters are the mean and sd
##   2: Lognormal - parameters are the mean and sd of the log
##   3: Beta      - parameters are the two beta parameters [see dbeta]
##   4: Gamma     - parameters are the two gamma parameters [see dgamma]
##  Phase: Set equal to a negative number not to estimate
##  Relative: 0: absolute; 1 relative 
##  Block: Block number for time-varying selectivity   
##  Block_fn: 0:absolute values; 1:exponential
##  Env_L: Environmental link - options are 0:none; 1:additive; 2:multiplicative; 3:exponential
##  EnvL_var: Environmental variable
##  RW: 0: no random walk changes; 1: devs are exponentiated and multiplied; 2: devs are additive (sel params only)
##  RW_blk: Block number for random walks
##  Sigma_RW: Sigma used for the random walk

# Inputs for type*sex*fleet: selectivity male Pot_Fishery
# MAIN PARS:  Initial  Lower_bound  Upper_bound Prior_type     Prior_1      Prior_2  Phase  Block Blk_fn  Env_L Env_vr     RW RW_Blk RW_Sigma
           105.711400     5.000000   186.000000          0     1.000000   999.000000      4      0      0      0      0      0      0   0.3000 # Sel_Pot_Fishery_male_base_Logistic_mean
             4.997241     0.010000    20.000000          0     1.000000   999.000000      4      0      0      0      0      0      0   0.3000 # Sel_Pot_Fishery_male_base_Logistic_cv
# NO EXTRA PARS: Initial  Lower_bound  Upper_bound Prior_type      Prior_1     Prior_2  Phase    Reltve 

# Inputs for type*sex*fleet: selectivity male Trawl_Bycatch
# MAIN PARS:  Initial  Lower_bound  Upper_bound Prior_type     Prior_1      Prior_2  Phase  Block Blk_fn  Env_L Env_vr     RW RW_Blk RW_Sigma
           109.931000     5.000000   185.000000          0     1.000000   999.000000      4      0      0      0      0      0      0   0.3000 # Sel_Trawl_Bycatch_male_base_Logistic_mean
            11.868260     0.010000    20.000000          0     1.000000   999.000000      4      0      0      0      0      0      0   0.3000 # Sel_Trawl_Bycatch_male_base_Logistic_cv
# NO EXTRA PARS: Initial  Lower_bound  Upper_bound Prior_type      Prior_1     Prior_2  Phase    Reltve 

# Inputs for type*sex*fleet: selectivity male NMFS_Trawl_1982
# MAIN PARS:  Initial  Lower_bound  Upper_bound Prior_type     Prior_1      Prior_2  Phase  Block Blk_fn  Env_L Env_vr     RW RW_Blk RW_Sigma
             0.136100     0.000010     1.000000          1     0.136100     0.117800      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_1
             0.248600     0.000010     1.000000          1     0.248600     0.084700      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_2
             0.350400     0.000010     1.000000          1     0.350400     0.073800      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_3
             0.428600     0.000010     1.000000          1     0.428600     0.072100      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_4
             0.474000     0.000010     1.000000          1     0.474000     0.072200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_5
             0.486100     0.000010     1.000000          1     0.486100     0.071200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_6
             0.474000     0.000010     1.000000          1     0.474000     0.069200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_7
             0.452000     0.000010     1.000000          1     0.452000     0.068200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_8
             0.432900     0.000010     1.000000          1     0.432900     0.067200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_9
             0.423100     0.000010     1.000000          1     0.423100     0.067200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_10
             0.422300     0.000010     1.000000          1     0.422300     0.067100      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_11
             0.427800     0.000010     1.000000          1     0.427800     0.067000      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_12
             0.438900     0.000010     1.000000          1     0.438900     0.067200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_13
             0.458600     0.000010     1.000000          1     0.458600     0.067000      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_14
             0.490600     0.000010     1.000000          1     0.490600     0.067500      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_15
             0.535700     0.000010     1.000000          1     0.535700     0.067700      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_16
             0.591800     0.000010     1.000000          1     0.591800     0.068200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_17
             0.656900     0.000010     1.000000          1     0.656900     0.068700      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_18
             0.732300     0.000010     1.000000          1     0.732300     0.068300      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_19
             0.820900     0.000010     1.000000          1     0.820900     0.070200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_20
             0.923300     0.000010     1.000000          1     0.923300     0.079200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_21
             0.999900     0.000010     1.000000          1     0.999900     0.108700      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_male_base_class_22
# NO EXTRA PARS: Initial  Lower_bound  Upper_bound Prior_type      Prior_1     Prior_2  Phase    Reltve 

# Inputs for type*sex*fleet: selectivity male NMFS_Trawl_1989
# MAIN PARS:  Initial  Lower_bound  Upper_bound Prior_type     Prior_1      Prior_2  Phase  Block Blk_fn  Env_L Env_vr     RW RW_Blk RW_Sigma
             0.136100     0.000010     1.000000          1     0.136100     0.117800      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_1
             0.248600     0.000010     1.000000          1     0.248600     0.084700      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_2
             0.350400     0.000010     1.000000          1     0.350400     0.073800      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_3
             0.428600     0.000010     1.000000          1     0.428600     0.072100      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_4
             0.474000     0.000010     1.000000          1     0.474000     0.072200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_5
             0.486100     0.000010     1.000000          1     0.486100     0.071200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_6
             0.474000     0.000010     1.000000          1     0.474000     0.069200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_7
             0.452000     0.000010     1.000000          1     0.452000     0.068200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_8
             0.432900     0.000010     1.000000          1     0.432900     0.067200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_9
             0.423100     0.000010     1.000000          1     0.423100     0.067200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_10
             0.422300     0.000010     1.000000          1     0.422300     0.067100      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_11
             0.427800     0.000010     1.000000          1     0.427800     0.067000      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_12
             0.438900     0.000010     1.000000          1     0.438900     0.067200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_13
             0.458600     0.000010     1.000000          1     0.458600     0.067000      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_14
             0.490600     0.000010     1.000000          1     0.490600     0.067500      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_15
             0.535700     0.000010     1.000000          1     0.535700     0.067700      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_16
             0.591800     0.000010     1.000000          1     0.591800     0.068200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_17
             0.656900     0.000010     1.000000          1     0.656900     0.068700      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_18
             0.732300     0.000010     1.000000          1     0.732300     0.068300      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_19
             0.820900     0.000010     1.000000          1     0.820900     0.070200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_20
             0.923300     0.000010     1.000000          1     0.923300     0.079200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_21
             0.999900     0.000010     1.000000          1     0.999900     0.108700      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_male_base_class_22
# NO EXTRA PARS: Initial  Lower_bound  Upper_bound Prior_type      Prior_1     Prior_2  Phase    Reltve 

# Inputs for type*sex*fleet: selectivity female Pot_Fishery
# MAIN PARS:  Initial  Lower_bound  Upper_bound Prior_type     Prior_1      Prior_2  Phase  Block Blk_fn  Env_L Env_vr     RW RW_Blk RW_Sigma
            74.856720     5.000000   150.000000          0     1.000000   999.000000      4      0      0      0      0      0      0   0.3000 # Sel_Pot_Fishery_female_base_Logistic_mean
             4.187324     0.010000    20.000000          0     1.000000   999.000000      4      0      0      0      0      0      0   0.3000 # Sel_Pot_Fishery_female_base_Logistic_cv
# NO EXTRA PARS: Initial  Lower_bound  Upper_bound Prior_type      Prior_1     Prior_2  Phase    Reltve 

# Inputs for type*sex*fleet: selectivity female NMFS_Trawl_1982
# MAIN PARS:  Initial  Lower_bound  Upper_bound Prior_type     Prior_1      Prior_2  Phase  Block Blk_fn  Env_L Env_vr     RW RW_Blk RW_Sigma
             0.136100     0.000010     1.000000          1     0.136100     0.117800      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_1
             0.248600     0.000010     1.000000          1     0.248600     0.084700      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_2
             0.350400     0.000010     1.000000          1     0.350400     0.073800      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_3
             0.428600     0.000010     1.000000          1     0.428600     0.072100      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_4
             0.474000     0.000010     1.000000          1     0.474000     0.072200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_5
             0.486100     0.000010     1.000000          1     0.486100     0.071200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_6
             0.474000     0.000010     1.000000          1     0.474000     0.069200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_7
             0.452000     0.000010     1.000000          1     0.452000     0.068200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_8
             0.432900     0.000010     1.000000          1     0.432900     0.067200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_9
             0.423100     0.000010     1.000000          1     0.423100     0.067200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_10
             0.422300     0.000010     1.000000          1     0.422300     0.067100      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_11
             0.427800     0.000010     1.000000          1     0.427800     0.067000      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_12
             0.438900     0.000010     1.000000          1     0.438900     0.067200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_13
             0.458600     0.000010     1.000000          1     0.458600     0.067000      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_14
             0.490600     0.000010     1.000000          1     0.490600     0.067500      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_15
             0.535700     0.000010     1.000000          1     0.535700     0.067700      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_16
             0.591800     0.000010     1.000000          1     0.591800     0.068200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_17
             0.656900     0.000010     1.000000          1     0.656900     0.068700      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_18
             0.732300     0.000010     1.000000          1     0.732300     0.068300      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_19
             0.820900     0.000010     1.000000          1     0.820900     0.070200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_20
             0.923300     0.000010     1.000000          1     0.923300     0.079200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_21
             0.999900     0.000010     1.000000          1     0.999900     0.108700     -3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1982_female_base_class_22
# NO EXTRA PARS: Initial  Lower_bound  Upper_bound Prior_type      Prior_1     Prior_2  Phase    Reltve 

# Inputs for type*sex*fleet: selectivity female NMFS_Trawl_1989
# MAIN PARS:  Initial  Lower_bound  Upper_bound Prior_type     Prior_1      Prior_2  Phase  Block Blk_fn  Env_L Env_vr     RW RW_Blk RW_Sigma
             0.136100     0.000010     1.000000          1     0.136100     0.117800      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_1
             0.248600     0.000010     1.000000          1     0.248600     0.084700      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_2
             0.350400     0.000010     1.000000          1     0.350400     0.073800      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_3
             0.428600     0.000010     1.000000          1     0.428600     0.072100      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_4
             0.474000     0.000010     1.000000          1     0.474000     0.072200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_5
             0.486100     0.000010     1.000000          1     0.486100     0.071200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_6
             0.474000     0.000010     1.000000          1     0.474000     0.069200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_7
             0.452000     0.000010     1.000000          1     0.452000     0.068200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_8
             0.432900     0.000010     1.000000          1     0.432900     0.067200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_9
             0.423100     0.000010     1.000000          1     0.423100     0.067200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_10
             0.422300     0.000010     1.000000          1     0.422300     0.067100      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_11
             0.427800     0.000010     1.000000          1     0.427800     0.067000      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_12
             0.438900     0.000010     1.000000          1     0.438900     0.067200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_13
             0.458600     0.000010     1.000000          1     0.458600     0.067000      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_14
             0.490600     0.000010     1.000000          1     0.490600     0.067500      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_15
             0.535700     0.000010     1.000000          1     0.535700     0.067700      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_16
             0.591800     0.000010     1.000000          1     0.591800     0.068200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_17
             0.656900     0.000010     1.000000          1     0.656900     0.068700      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_18
             0.732300     0.000010     1.000000          1     0.732300     0.068300      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_19
             0.820900     0.000010     1.000000          1     0.820900     0.070200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_20
             0.923300     0.000010     1.000000          1     0.923300     0.079200      3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_21
             0.999900     0.000010     1.000000          1     0.999900     0.108700     -3      0      0      0      0      0      0   0.3000 # Sel_NMFS_Trawl_1989_female_base_class_22
# NO EXTRA PARS: Initial  Lower_bound  Upper_bound Prior_type      Prior_1     Prior_2  Phase    Reltve 

# Inputs for type*sex*fleet: retention male Pot_Fishery
# MAIN PARS:  Initial  Lower_bound  Upper_bound Prior_type     Prior_1      Prior_2  Phase  Block Blk_fn  Env_L Env_vr     RW RW_Blk RW_Sigma
            98.039190     1.000000   190.000000          1    98.000000    10.000000      4      0      0      0      0      0      0   0.3000 # Ret_Pot_Fishery_male_base_Logistic_mean
             2.197131     0.001000    20.000000          0     1.000000   999.000000      4      0      0      0      0      0      0   0.3000 # Ret_Pot_Fishery_male_base_Logistic_cv
# NO EXTRA PARS: Initial  Lower_bound  Upper_bound Prior_type      Prior_1     Prior_2  Phase    Reltve 

# pre-specified selectivity/retention (ordered by type, sex, fleet and year)

## ==================================================================================== ##
## CATCHABILITY PARAMETER CONTROLS                                                      ##
## ==================================================================================== ##
## 
# Catchability (specifications)
# Analytic: should q be estimated analytically (1) or not (0)
# Lambda: the weight lambda
# Emphasis: the weighting emphasis
# Block: Block number for time-varying q
# Env_L: Environmental link - options are 0: none; 1:additive; 2:multiplicative; 3:exponential
# EnvL_var: Environmental variable
# RW: 0 for no random walk changes; 1 otherwise
# RW_blk: Block number for random walks
# Sigma_RW: Sigma for the random walk parameters
## Analytic  Lambda Emphasis  Mirror   Block   Env_L EnvL_Vr      RW  RW_blk Sigma_RW
          0       1       1       0       0       0       0       0       0   0.3000 #--Survey 1
          0       1       1       0       0       0       0       0       0   0.3000 #--Survey 2
          0       1       1       0       0       0       0       0       0   0.3000 #--Survey 3
          0       1       1       0       0       0       0       0       0   0.3000 #--Survey 4
# Catchability (parameters)
#      Initial    Lower_bound    Upper_bound  Prior_type        Prior_1        Prior_2  Phase 
    1.00000000     0.01000000     1.01000000           0     0.84313600     0.03000000     -5 # Survey_q_parameter_1_for_Survey_1_in_block_group_0
    1.00000000     0.01000000     1.01000000           0     0.84313600     0.03000000     -5 # Survey_q_parameter_2_for_Survey_2_in_block_group_0
    1.00000000     0.01000000     1.01000000           0     0.45136000     0.50000000     -5 # Survey_q_parameter_3_for_Survey_3_in_block_group_0
    1.00000000     0.01000000     1.01000000           0     0.45313600     0.50000000     -5 # Survey_q_parameter_4_for_Survey_4_in_block_group_0

## ==================================================================================== ##
## ADDITIONAL CV PARAMETER CONTROLS                                                     ##
## ==================================================================================== ##
## 
# Additiional CV controls (specifications)
# Mirror: should additional variance be mirrored (value > 1) or not (0)?
# Block: Block number for time-varying additional variance
# Block_fn: 0:absolute values; 1:exponential
# Env_L: Environmental link - options are 0: none; 1:additive; 2:multiplicative; 3:exponential
# EnvL_var: Environmental variable
# RW: 0 for no random walk changes; 1 otherwise
# RW_blk: Block number for random walks
# Sigma_RW: Sigma for the random walk parameters
##   Mirror   Block   Env_L EnvL_Vr     RW   RW_blk Sigma_RW
          0       0       0       0       0       0   0.3000 
          0       0       0       0       0       0   0.3000 
          0       0       0       0       0       0   0.3000 
          0       0       0       0       0       0   0.3000 
## Mirror Block Env_L EnvL_Var  RW RW_blk Sigma_RW
# Additional variance (parameters)
#      Initial    Lower_bound    Upper_bound  Prior_type        Prior_1        Prior_2  Phase 
    0.00010000     0.00001000    10.00000000           0     1.00000000   100.00000000     -4 # Add_cv_parameter_1
    0.00010000     0.00001000    10.00000000           0     1.00000000   100.00000000     -4 # Add_cv_parameter_2
    0.00010000     0.00001000    10.00000000           0     1.00000000   100.00000000     -4 # Add_cv_parameter_3
    0.00010000     0.00001000    10.00000000           0     1.00000000   100.00000000     -4 # Add_cv_parameter_4

## ==================================================================================== ##
## CONTROLS ON F                                                                        ##
## ==================================================================================== ##
## 
# Controls on F
#   Initial_male_F  Initial_fem_F   Pen_SD (mal)   Pen_SD (fem) Phz_mean_F_mal Phz_mean_F_fem   Lower_mean_F   Upper_mean_F Low_ann_male_F  Up_ann_male_F    Low_ann_f_F     Up_ann_f_F
          1.000000       0.050500       0.500000      45.500000       1.000000       1.000000     -12.000000       4.000000     -10.000000      10.000000     -10.000000      10.000000  # Pot_Fishery
          0.018000       1.000000       0.500000      45.500000       1.000000      -1.000000     -12.000000       4.000000     -10.000000      10.000000     -10.000000      10.000000  # Trawl_Bycatch
          0.000000       0.000000       2.000000      20.000000      -1.000000      -1.000000     -12.000000       4.000000     -10.000000      10.000000     -10.000000      10.000000  # NMFS_Trawl_1982
          0.000000       0.000000       2.000000      20.000000      -1.000000      -1.000000     -12.000000       4.000000     -10.000000      10.000000     -10.000000      10.000000  # NMFS_Trawl_1989

## ==================================================================================== ##
## SIZE COMPOSITIONS OPTIONS                                                            ##
## ==================================================================================== ##
## 
# Options when fitting size-composition data
## Likelihood types: 
##  1:Multinomial with estimated/fixed sample size
##  2:Robust approximation to multinomial
##  3:logistic normal
##  4:multivariate-t
##  5:Dirichlet
##  6:Dirichlet-Alt (Thorson et al 2016 rec'd)

#  Pot_Fishery Pot_Fishery Pot_Fishery Trawl_Bycatch Trawl_Bycatch NMFS_Trawl_1982 NMFS_Trawl_1989 NMFS_Trawl_1982 NMFS_Trawl_1989 NMFS_Trawl_1982 NMFS_Trawl_1989 NMFS_Trawl_1982 NMFS_Trawl_1989
#   M    M    F    F    M    F    F    M    M    F    F    M    M  
#  ret  tot  dsc  dsc  dsc  dsc  dsc  dsc  dsc  dsc  dsc  dsc  dsc 
#  N+S  N+S  N+S  N+S  N+S  N+S  N+S  N+S  N+S  N+S  N+S  N+S  N+S 
#  I+M  I+M  I+M  I+M  I+M  imm  imm  imm  imm  mat  mat  mat  mat 
      2      2      2      2      2      2      2      2      2      2      2      2      2 # Type of likelihood
      0      0      0      0      0      0      0      0      0      0      0      0      0 # Auto tail compression
 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 0.0000 # Auto tail compression (pmin)
      1      2      3      4      5      6      7      8      9     10     11     12     13 # Composition aggregator codes
      1      1      1      1      1      2      2      2      2      2      2      2      2 # Set to 1 for catch-based predictions; 2 for survey or total catch predictions
 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 # Lambda for effective sample size
 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 # Lambda for overall likelihood
      0      0      0      0      0      0      0      0      0      0      0      0      0 # Survey to set Q for this comp

# Effective sample size parameters (number matches max(Composition Aggregator code)) 
#      Initial    Lower_bound    Upper_bound  Prior_type        Prior_1        Prior_2  Phase 
    1.00000000     0.10000000     5.00000000           0     0.00000000   999.00000000     -4 # Overdispersion_parameter_for_size_comp_1(possibly extended)
    1.00000000     0.10000000     5.00000000           0     0.00000000   999.00000000     -4 # Overdispersion_parameter_for_size_comp_2(possibly extended)
    1.00000000     0.10000000     5.00000000           0     0.00000000   999.00000000     -4 # Overdispersion_parameter_for_size_comp_3(possibly extended)
    1.00000000     0.10000000     5.00000000           0     0.00000000   999.00000000     -4 # Overdispersion_parameter_for_size_comp_4(possibly extended)
    1.00000000     0.10000000     5.00000000           0     0.00000000   999.00000000     -4 # Overdispersion_parameter_for_size_comp_5(possibly extended)
    1.00000000     0.10000000     5.00000000           0     0.00000000   999.00000000     -4 # Overdispersion_parameter_for_size_comp_6(possibly extended)
    1.00000000     0.10000000     5.00000000           0     0.00000000   999.00000000     -4 # Overdispersion_parameter_for_size_comp_7(possibly extended)
    1.00000000     0.10000000     5.00000000           0     0.00000000   999.00000000     -4 # Overdispersion_parameter_for_size_comp_8(possibly extended)
    1.00000000     0.10000000     5.00000000           0     0.00000000   999.00000000     -4 # Overdispersion_parameter_for_size_comp_9(possibly extended)
    1.00000000     0.10000000     5.00000000           0     0.00000000   999.00000000     -4 # Overdispersion_parameter_for_size_comp_10(possibly extended)
    1.00000000     0.10000000     5.00000000           0     0.00000000   999.00000000     -4 # Overdispersion_parameter_for_size_comp_11(possibly extended)
    1.00000000     0.10000000     5.00000000           0     0.00000000   999.00000000     -4 # Overdispersion_parameter_for_size_comp_12(possibly extended)
    1.00000000     0.10000000     5.00000000           0     0.00000000   999.00000000     -4 # Overdispersion_parameter_for_size_comp_13(possibly extended)

## ==================================================================================== ##
## EMPHASIS FACTORS                                                                     ##
## ==================================================================================== ##

1.0000 # Emphasis on tagging data

 1.0000 1.0000 1.0000 1.0000 # Emphasis on Catch: (by catch dataframes)

# Weights for penalties 1, 11, and 12
#   Mean_M_fdevs | Mean_F_fdevs |  Ann_M_fdevs |  Ann_F_fdevs
          1.0000         1.0000         0.0000         0.0000 # Pot_Fishery
          1.0000         0.0000         0.0000         0.0000 # Trawl_Bycatch
          0.0000         0.0000         0.0000         0.0000 # NMFS_Trawl_1982
          0.0000         0.0000         0.0000         0.0000 # NMFS_Trawl_1989

## Emphasis Factors (Priors/Penalties: 13 values) ##
 10000.0000	#--Penalty on log_fdev (male+combined; female) to ensure they sum to zero
     0.0000	#--Penalty on mean F by fleet to regularize the solution
     1.0000	#--Not used
     1.0000	#--Not used
    15.0000	#--Not used
     1.0000	#--Smoothness penalty on the recruitment devs
     3.0000	#--Penalty on the difference of the mean_sex_ratio from 0.5
    60.0000	#--Smoothness penalty on molting probability
     3.0000	#--Smoothness penalty on selectivity patterns with class-specific coefficients
     5.0000	#--Smoothness penalty on initial numbers at length
     0.0000	#--Penalty on annual F-devs for males by fleet
     0.0000	#--Penalty on annual F-devs for females by fleet
     0.0000	#--Penalty on deviation parameters

# eof_ctl
9999
