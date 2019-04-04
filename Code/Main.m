% Program to simulate alarm management, so alarm fatigue may be reduced.

%% Initialisation
clc;close all;

load('dataOrigineelV2.mat')

%% Parameters input

HR_StartUpLimit=100;
HR_StartLowLimit=50;
HR_PercMargin=10;
HR_RedAlarmTime=1;
HR_YellowAlarmTime=3;

O2_LowerLimit=85;
O2_AbsMargin=90;%O2_LowerLimit+5
O2_RedAlarmTime=5;
O2_YellowAlarmTime=0;

ResetTime=8;
UpperFreq=10;

%switch between different cases in order to combine the SpO2 and HR
%signals.
val = 3;
switch val
    case 1 %complete simulations
        Time=dataOrigineelV2(1:100:end,1);
        HR=dataOrigineelV2(1:100:end,3);
        SpO2=dataOrigineelV2(1:100:end,2);
    case 2 %simulations of both HR and SpO2 seperately
        Time=dataOrigineelV2(1:50:39000,1);
        HR=dataOrigineelV2(1:50:39000,3);
        SpO2=dataOrigineelV2(28335:50:end,2);
    case 3 %significant drop in both HR and SpO2 signals
        load('case3a.mat')
        load('case6.mat')
        Time=dataOrigineelV2(1:25:min(length(case3a),length(case6)),1);
        HR=case3a(1:25:min(length(case3a),length(case6)),3);
        SpO2=case6(1:25:min(length(case3a),length(case6)),2);    
    case 4 %HR outside limit and SpO2 below margin, but above lower limit: yellow alarm SpO2
        load('case8.mat')
        load('case1.mat')
        Time=case1(1:10:min(length(case1),length(case8)),1);
        HR=case1(1:10:min(length(case1),length(case8)),3);
        SpO2=case8(1:15:min(length(case1),length(case8)),2); 
    case 5 %HR above upper margin and SpO2 below margin: blue alarm
        load('case2.mat')
        load('case6.mat')
        Time=dataOrigineelV2(1:25:5428,1);
        HR=dataOrigineelV2(4663:25:10091,3);
        SpO2=case6(1:25:5428,2);  
    case 6 %HR between limits
        load('case7.mat')
        load('case5.mat')
        Time=case7(1:10:min(length(case5),length(case7)),1);
        HR=case5(1:10:min(length(case5),length(case7)),3);
        SpO2=case6(1:10:min(length(case5),length(case7)),2); 
    case 7 %significant drop in SpO2 signals
        load('case6.mat')
        Time=dataOrigineelV2(1:25:min(length(case3a),length(case6)),1);
        HR=case6(1:25:min(length(case3a),length(case6)),3);
        SpO2=case6(1:25:min(length(case3a),length(case6)),2);  
    case 8
        load('case1b.mat')
        load('case6.mat')
        Time=dataOrigineelV2(1:25:min(length(case1b),length(case6)),1);
        HR=case1b(1:25:min(length(case1b),length(case6)),3);
        SpO2=case6(1:25:min(length(case1b),length(case6)),2);      
end

%% Simulation of heartbeat with new alarm management
AlarmManagement(Time,HR, SpO2, HR_StartUpLimit, HR_StartLowLimit, HR_PercMargin,...
HR_RedAlarmTime, HR_YellowAlarmTime, O2_LowerLimit, O2_AbsMargin, O2_RedAlarmTime, ...
O2_YellowAlarmTime, ResetTime, UpperFreq)


