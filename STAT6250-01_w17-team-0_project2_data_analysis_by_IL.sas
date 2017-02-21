*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
This file uses the following analytic dataset to address several research
questions regarding college-preparation trends at CA public K-12 schools

Dataset Name: cde_2014_analytic_file created in external file
STAT6250-01_w17-team-0_project2_data_preparation.sas, which is assumed to be
in the same directory as this file

See included file for dataset properties
;

* environmental setup;
%let dataPrepFileName = STAT6250-01_w17-team-0_project2_data_preparation.sas;
%let sasUEFilePrefix = team-0_project2;

* load external file that generates analytic dataset cde_2014_analytic_file
using a system path dependent on the host operating system, after setting the
relative file import path to the current directory, if using Windows;
%macro setup;
    %if
        &SYSSCP. = WIN
    %then
        %do;
            X
            "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))"""
            ;           
            %include ".\&dataPrepFileName.";
        %end;
    %else
        %do;
            %include "~/&sasUEFilePrefix./&dataPrepFileName.";
        %end;
%mend;
%setup


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
"Research Question: What are the top five schools experiencing the biggest increase in percent eligible for free/reduced-price meals between AY2014-15 and AY2015-16?"
;

title2
"Rationale: This should help identify schoos to consider for new outreach based upon increasing child-poverty levels."
;

footnote1
"All five schools listed appear to have experienced extremely large increases percent eligible for free/reduced-price meals between AY2014-15 and AY2015-16."
;

footnote2
"Given the magnitude of these changes, further investigation should be performed to ensure no data errors are involved, especially for the school apparently exhibiting an increase of 100%."
;

footnote3
"However, assuming there are no data issues underlying this analysis, possible explanations for such large increases include changing CA demographics and recent loosening of the rules under which students qualify for free/reduced-price meals."
;

*
Note: This compares the column "Percent (%) Eligible Free (K-12)" from frpm1415
to the column of the same name from frpm1516.

Methodology: Proc print is used to display the first five rows of a dataset
that was sorted by frpm_rate_change_2014_to_2015 in descending order in the
data-prep file.
;

proc print data=cde_2014_analytic_file_frpm_sort(obs=5);
    id School_Name;
    var frpm_rate_change_2014_to_2015;
run;

title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
"Research Question: Can free/reduced-price meals (FRPM) eligibility rate be used to predict the proportion of high school graduates earning a combined score of at least 1500 on the SAT?"
;

title2
"Rationale: This would help inform whether child-poverty levels are associated with college-preparedness rates, providing a strong indicator for the types of schools most in need of college-preparation outreach."
;

footnote1
"As can be seen, there was an extremely high correlation between student poverty and SAT scores in AY2014-15, with lower-poverty schools much more likely to have high proportions of students with combined SAT scores exceeding 1500."
;

footnote2
"Possible explanations for this correlation include child-poverty rates tending to be higher at schools with lower overall academic performance and quality of instruction. In addition, students in non-poverish conditions are more likely to have parents able to pay for SAT preparation."
;

*
Note: This compares the column "Percent (%) Eligible Free (K-12)" from frpm1415
to the column PCTGE1500 from sat15.

Methodology: Use proc freq to create a cross-tab of the two variables with
respect to formats created in the data-prep file.
;

proc freq data=cde_2014_analytic_file;
    table
             Percent_Eligible_FRPM_K12
            *PCTGE1500
            / missing nocol nopercent
    ;
    where
        not(missing(PCTGE1500))
    ;
    format
        Percent_Eligible_FRPM_K12 Percent_Eligible_FRPM_K12_bins.
        PCTGE1500 PCTGE1500_bins.
    ;
    label
        Percent_Eligible_FRPM_K12="Percent Eligible for free/reduced-price meals"
        PCTGE1500="Percent with combined SAT scores exceeding 1500"
    ;
run;

title;
footnote;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
"Research Question: What are the top ten schools were the number of high school graduates taking the SAT exceeds the number of high school graduates completing UC/CSU entrance requirements?"
;

title2
"Rationale: This would help identify schools with significant gaps in preparation specific for California's two public university systems, suggesting where focused outreach on UC/CSU college-preparation might have the greatest impact."
;

footnote1
"All ten schools listed appear to have extremely large numbers of 12th-graders graduating who have completed the SAT but not the coursework needed to apply for the UC/CSU system"
;

footnote2
"Given the magnitude of these numbers, further investigation should be performed to ensure no data errors are involved."
;

footnote3
"However, assuming there are no data issues underlying this analysis, possible explanations for such large numbers of 12th-graders completing only the SAT include lack of access to UC/CSU-preparatory coursework, as well as lack of proper counseling for students early enough in high school to complete all necessary coursework."
;

*
Note: This compares the column NUMTSTTAKR from sat15 to the column TOTAL from
gradaf15.

Methodology: Use proc print to display the first ten rows of of a dataset that
was sorted by excess_sat_takers in descending order in the data-prep file.
;

proc print data=cde_2014_analytic_sat_sort(obs=10);
    id School_Name;
    var excess_sat_takers;
run;

title;
footnote;
