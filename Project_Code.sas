/*============================================================*/
/* CCDS620 - COMPLETE SAS PROJECT CODE                        */
/* Student Performance Statistical Analysis                   */
/*============================================================*/


/*============================================================*/
/* STEP 1: IMPORT DATA                                        */
/*============================================================*/

proc import 
    datafile="/home/u64501793/CCDS620_Project/Student_Data_Original_SAS_Ready_final.csv"
    out=WORK.STUDENT_RAW
    dbms=csv
    replace;
    
    guessingrows=max;
run;


/*============================================================*/
/* STEP 2: DATA PREPARATION                                   */
/*============================================================*/

data WORK.STUDENT_ANALYSIS;

    set WORK.STUDENT_RAW;

    /* Create Average Score */
    Average_Score = mean(Math_Score, Science_Score);

    /* Create Pass/Fail Binary Variable */
    if Final_Result='Pass' then Pass_Flag=1;
    else if Final_Result='Fail' then Pass_Flag=0;

    /* Create Attendance Categories */
    if Attendance < 70 then Attendance_Level='Low';
    else if Attendance < 85 then Attendance_Level='Medium';
    else Attendance_Level='High';

run;


/*============================================================*/
/* STEP 3: CHECK DATA                                         */
/*============================================================*/

proc contents data=WORK.STUDENT_ANALYSIS;
run;


proc freq data=WORK.STUDENT_ANALYSIS;

    tables 
        Gender
        Final_Result
        Attendance_Level
        Pass_Flag;

run;


/*============================================================*/
/* RQ1                                                        */
/* Distribution of Average Academic Scores                    */
/* Method: Descriptive Statistics + Histogram                 */
/*============================================================*/

proc means 
    data=WORK.STUDENT_ANALYSIS
    n mean median std min max q1 q3;

    var Average_Score;

run;


/* Histogram */

proc univariate data=WORK.STUDENT_ANALYSIS;

    var Average_Score;

    histogram Average_Score / normal;

run;


/* Boxplot */

proc sgplot data=WORK.STUDENT_ANALYSIS;

    vbox Average_Score;

run;


/*============================================================*/
/* RQ2                                                        */
/* Relationship Between Math and Science Scores               */
/* Method: Pearson Correlation                                */
/*============================================================*/

proc corr 
    data=WORK.STUDENT_ANALYSIS
    pearson;

    var Math_Score Science_Score;

run;


/* Scatter Plot */

proc sgplot data=WORK.STUDENT_ANALYSIS;

    scatter x=Math_Score y=Science_Score;

    reg x=Math_Score y=Science_Score;

run;


/*============================================================*/
/* RQ3                                                        */
/* Difference in Sleep Hours Between Pass/Fail Students       */
/* Method: Independent Two-Sample T-Test                      */
/*============================================================*/

proc ttest data=WORK.STUDENT_ANALYSIS;

    class Final_Result;

    var Sleep_Hours;

run;


/*============================================================*/
/* RQ4                                                        */
/* Association Between Gender and Final_Result                */
/* Method: Chi-Square Test                                    */
/*============================================================*/

proc freq data=WORK.STUDENT_ANALYSIS;

    tables Gender*Final_Result / chisq measures;

run;


/*============================================================*/
/* RQ5                                                        */
/* Differences in Average Scores Across Attendance Levels     */
/* Method: One-Way ANOVA + Tukey HSD                          */
/*============================================================*/

proc anova data=WORK.STUDENT_ANALYSIS;

    class Attendance_Level;

    model Average_Score = Attendance_Level;

    means Attendance_Level / tukey;

run;
quit;


/*============================================================*/
/* RQ6                                                        */
/* Predicting Pass/Fail Outcomes                              */
/* Method: Binary Logistic Regression                         */
/*============================================================*/

proc logistic data=WORK.STUDENT_ANALYSIS;

    model Pass_Flag(event='1') =
        Study_Hours
        Attendance
        Sleep_Hours
        Internet_Usage_Hours;

    title "Logistic Regression Predicting Pass/Fail Outcomes";

run;


/*============================================================*/
/* OPTIONAL: EXPORT HTML OUTPUT                               */
/*============================================================*/

ods html close;
ods listing;