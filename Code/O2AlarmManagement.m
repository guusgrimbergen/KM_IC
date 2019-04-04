function O2AlarmManagement(Time, SpO2, StartLowLimit, margin, RedAlarmTimeLower, YellowAlarmTimeLower)


%TO TEST: O2AlarmManagement(dataOrigineelV2(1:100:end,1), dataOrigineelV2(1:100:end,2), 85, 90, 25, 0)

%% Initialisation
    
LowerPercAmount=0;
MarginPercAmount=0;
RedAlarmGiven=false;
YellowAlarmGiven=false;
StartLowerlimit=StartLowLimit;
PT=0;


 %% Display HR signal
    figure('units','normalized','outerposition',[0 0 1 1]);

    xlabel('Time (s)')
    ylabel('SpO2 (%)')

    %HR line
    h=animatedline('Color','k','LineStyle','-','LineWidth',2);

    %Lower limit line
    LowLim=animatedline('Color','m','LineStyle','-','LineWidth',2);

    %Lower limit inclusive margin line
    LowMargin=animatedline('Color','m','LineStyle',':','LineWidth',2);

%% Alarm generation
for i=1:length(SpO2)   
 
        %Draw point with corresponding limits
        addpoints(h,Time(i),SpO2(i))
        drawnow
        addpoints(LowLim,Time(i),StartLowLimit)
        drawnow
        addpoints(LowMargin,Time(i),margin)
        drawnow
        
        if SpO2(i)<=StartLowerlimit %if SpO2 falls below lower limit
            LowerPercAmount=LowerPercAmount+1; %Count how many times in a row this has occured
            if LowerPercAmount==1
                BeginTime=Time(i); %If SpO2 is below lower limit for first time (first crossing), start timing
            else 
                DifferenceTime=Time(i)-BeginTime; %Keep track of how long SpO2 is below limit
                if ~YellowAlarmGiven %Give yellow alarm once
                    Sound(200)
                    ColorPlotO2(PT,SpO2(i),Time(i),2,RedAlarmTimeLower,YellowAlarmTimeLower);
                    YellowAlarmGiven=true;
                end 
                
                if DifferenceTime>=RedAlarmTimeLower && ~RedAlarmGiven %If SpO2 is below limit for RedAlarm time or longer, give Red alarm once
                    Sound(300)
                    ColorPlotO2(PT,SpO2(i),Time(i),1,RedAlarmTimeLower,YellowAlarmTimeLower);
                    RedAlarmGiven=true;
                
                end
            end
        elseif SpO2(i)>=StartLowerlimit && LowerPercAmount>1 %If SpO2 reaches lower limit from below (second crossing), reset all alarms
            LowerPercAmount=0;
            YellowAlarmGiven=false;
            RedAlarmGiven=false;
        
            
            
        elseif SpO2(i)<=margin %if SpO2 falls below margin
            MarginPercAmount=MarginPercAmount+1;
            if MarginPercAmount==1
                BeginTime=Time(i);
            else 
                DifferenceTime=Time(i)-BeginTime;
                if DifferenceTime>=YellowAlarmTimeLower && ~YellowAlarmGiven
                    Sound(200)
                    ColorPlotO2(PT,SpO2(i),Time(i),3,RedAlarmTimeLower,YellowAlarmTimeLower);
                    YellowAlarmGiven=true;
                end
            end
        elseif SpO2(i)>=margin && MarginPercAmount>1 %If SpO2 reaches margin from below (second crossing), reset all alarms
            MarginPercAmount=0;
            YellowAlarmGiven=false;
            RedAlarmGiven=false;
        
            
            
                
        end
        
        
      
end 



end

