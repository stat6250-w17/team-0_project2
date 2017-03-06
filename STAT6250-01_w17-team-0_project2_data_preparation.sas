*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* 
[Dataset 1 Name] frpm1415

[Dataset Description] Student Poverty Free or Reduced Price Meals (FRPM) Data,
AY2014-15

[Experimental Unit Description] California public K-12 schools in AY2014-15

[Number of Observations] 10,393
                    
[Number of Features] 28

[Data Source] The file http://www.cde.ca.gov/ds/sd/sd/documents/frpm1415.xls
was downloaded and edited to produce file frpm1415-edited.xls by deleting
worksheet "Title Page", deleting row 1 from worksheet "FRPM School-Level Data",
reformatting column headers in "FRPM School-Level Data" to remove characters
disallowed in SAS variable names, and setting all cell values to "Text" format

[Data Dictionary] http://www.cde.ca.gov/ds/sd/sd/fsspfrpm.asp

[Unique ID Schema] The columns "County Code", "District Code", and "School
Code" form a composite key, which together are equivalent to the unique id
column CDS_CODE in dataset gradaf15, and which together are also equivalent to
the unique id column CDS in dataset sat15.

--

[Dataset 2 Name] frpm1516

[Dataset Description] Student Poverty Free or Reduced Price Meals (FRPM) Data,
AY2015-16

[Experimental Unit Description] California public K-12 schools in AY2015-16

[Number of Observations] 10,453
                    
[Number of Features] 28

[Data Source] The file http://www.cde.ca.gov/ds/sd/sd/documents/frpm1516.xls
was downloaded and edited to produce file frpm1516-edited.xls by deleting
worksheet "Title Page", deleting row 1 from worksheet "FRPM School-Level Data",
reformatting column headers in "FRPM School-Level Data" to remove characters
disallowed in SAS variable names, and setting all cell values to "Text" format

[Data Dictionary] http://www.cde.ca.gov/ds/sd/sd/fsspfrpm.asp

[Unique ID Schema] The columns "County Code", "District Code", and "School
Code" form a composite key, which together are equivalent to the unique id
column CDS_CODE in dataset gradaf15, and which together are also equivalent to
the unique id column CDS in dataset sat15.

--

[Dataset 3 Name] gradaf15

[Dataset Description] Graduates Meeting UC/CSU Entrance Requirements, AY2014-15

[Experimental Unit Description] California public K-12 schools in AY2014-15

[Number of Observations] 2,490
                    
[Number of Features] 15

[Data Source] The file
http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2014-15&cCat=UCGradEth&cPage=filesgradaf.asp
was downloaded and edited to produce file gradaf15.xls by importing into Excel
and setting all cell values to "Text" format


[Data Dictionary] http://www.cde.ca.gov/ds/sd/sd/fsgradaf09.asp

[Unique ID Schema] The column CDS_CODE is a unique id.

--

[Dataset 4 Name] sat15

[Dataset Description] SAT Test Results, AY2014-15

[Experimental Unit Description] California public K-12 schools in AY2014-15

[Number of Observations] 2,331
                    
[Number of Features] 12

[Data Source]  The file http://www3.cde.ca.gov/researchfiles/satactap/sat15.xls
was downloaded and edited to produce file sat15-edited.xls by opening in Excel
and setting all cell values to "Text" format

[Data Dictionary] http://www.cde.ca.gov/ds/sp/ai/reclayoutsat.asp

[Unique ID Schema] The column CDS is a unique id.
;

* setup environmental parameters;
%let inputDataset1URL =
https://github.com/stat6250/team-0_project2/blob/master/data/frpm1415-edited.xls?raw=true
;
%let inputDataset1Type = XLS;
%let inputDataset1DSN = frpm1415_raw;

%let inputDataset2URL =
https://github.com/stat6250/team-0_project2/blob/master/data/frpm1516-edited.xls?raw=true
;
%let inputDataset2Type = XLS;
%let inputDataset2DSN = frpm1516_raw;

%let inputDataset3URL =
https://github.com/stat6250/team-0_project2/blob/master/data/gradaf15.xls?raw=true
;
%let inputDataset3Type = XLS;
%let inputDataset3DSN = gradaf15_raw;

%let inputDataset4URL =
https://github.com/stat6250/team-0_project2/blob/master/data/sat15-edited.xls?raw=true
;
%let inputDataset4Type = XLS;
%let inputDataset4DSN = sat15_raw;

* create output formats;
proc format;
    value Percent_Eligible_FRPM_K12_bins
        low-<.39="Q1 FRPM"
        .39-<.69="Q2 FRPM"
        .69-<.86="Q3 FRPM"
        .86-high="Q4 FRPM"
    ;
    value PCTGE1500_bins
        low-20="Q1 SAT_Scores_GE_1500"
        20-<37="Q2 SAT_Scores_GE_1500"
        37-<56.3="Q3 SAT_Scores_GE_1500"
        56.3-high="Q4 SAT_Scores_GE_1500"
    ;
run;


* load raw datasets over the wire, if they doesn't already exist;
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
    %put &=dsn;
    %put &=url;
    %put &=filetype;
    %if
        %sysfunc(exist(&dsn.)) = 0
    %then
        %do;
            %put Loading dataset &dsn. over the wire now...;
            filename tempfile TEMP;
            proc http
                method="get"
                url="&url."
                out=tempfile
                ;
            run;
            proc import
                file=tempfile
                out=&dsn.
                dbms=&filetype.;
            run;
            filename tempfile clear;
        %end;
    %else
        %do;
            %put Dataset &dsn. already exists. Please delete and try again.;
        %end;
%mend;
%loadDataIfNotAlreadyAvailable(
    &inputDataset1DSN.,
    &inputDataset1URL.,
    &inputDataset1Type.
)
%loadDataIfNotAlreadyAvailable(
    &inputDataset2DSN.,
    &inputDataset2URL.,
    &inputDataset2Type.
)
%loadDataIfNotAlreadyAvailable(
    &inputDataset3DSN.,
    &inputDataset3URL.,
    &inputDataset3Type.
)
%loadDataIfNotAlreadyAvailable(
    &inputDataset4DSN.,
    &inputDataset4URL.,
    &inputDataset4Type.
)


* sort and check raw datasets for duplicates with respect to their unique ids,
  removing blank rows, if needed;
proc sort
        nodupkey
        data=frpm1415_raw
        dupout=frpm1415_raw_dups
        out=frpm1415_raw_sorted(where=(not(missing(School_Code))))
    ;
    by
        County_Code
        District_Code
        School_Code
    ;
run;
proc sort
        nodupkey
        data=frpm1516_raw
        dupout=frpm1516_raw_dups
        out=frpm1516_raw_sorted
    ;
    by
        County_Code
        District_Code
        School_Code
    ;
run;
proc sort
        nodupkey
        data=gradaf15_raw
        dupout=gradaf15_raw_dups
        out=gradaf15_raw_sorted
    ;
    by
        CDS_CODE
    ;
run;
proc sort
        nodupkey
        data=sat15_raw
        dupout=sat15_raw_dups
        out=sat15_raw_sorted
    ;
    by
        CDS
    ;
run;


* build analytic dataset from raw datasets with the least number of columns and
minimal cleaning/transformation needed to address research questions in
corresponding data-analysis files;
proc sql;
    create table cde_2014_analytic_file as
        select
             cats(A.County_Code,A.District_Code,A.School_Code)
             AS
             CDS_Code
            ,A.School_Name
            ,A.Percent_Eligible_FRPM_K12
            ,A.Percent_Eligible_FRPM_K12 - B.Percent_Eligible_FRPM_K12
             AS
             frpm_rate_change_2014_to_2015
            ,input(D.PCTGE1500,best12.2)
             AS
             PCTGE1500
            ,input(D.NUMTSTTAKR,best12.) - input(C.TOTAL,best12.)
             AS
             excess_sat_takers
        from
            frpm1415_raw_sorted as A
            inner join
            frpm1516_raw_sorted as B
            on
                cats(A.County_Code,A.District_Code,A.School_Code)
                =
                cats(B.County_Code,B.District_Code,B.School_Code)
            inner join
            gradaf15_raw_sorted as C
            on
                cats(A.County_Code,A.District_Code,A.School_Code)
                =
                strip(CDS_Code)
            inner join
            sat15_raw_sorted as D
            on
                cats(A.County_Code,A.District_Code,A.School_Code)
                =
                strip(CDS)
        having
            Percent_Eligible_FRPM_K12 > 0
            and
            substr(CDS_Code,8,6) ne "000000"
            and
            not(missing(CDS_Code))
            and
            not(missing(School_Name))
        order by
            CDS_Code
    ;
quit;

* create copy of analytic file sorted by frpm_rate_change_2014_to_2015 for use
in data analysis;
proc sort
        data=cde_2014_analytic_file
        out=cde_2014_analytic_file_frpm_sort
    ;
    by descending frpm_rate_change_2014_to_2015;
run;


* create copy of analytic file sorted by excess_sat_takers for use in data
analysis;
proc sort
        data=cde_2014_analytic_file
        out=cde_2014_analytic_sat_sort
    ;
    by descending excess_sat_takers;
run;
