function HRAlarmManagement2(Time,HR,StartUpLimit,StartLowLimit,margin,RedAlarmTimeUpper,YellowAlarmTimeUpper,ResetTime,UpperFreq,PT)
   %Input om te testen:
   %HRAlarmManagement2(dataOrigineelV2(1:250:end,1),dataOrigineelV2(1:250:end,3),60,50,10,1,3,8,5,0)
   

    %This function preforms the new alarm management on given parameters and 
    %suggests alarm limit adjustments. The nurse can choose to accept, decline
    %or enter an own limit. Besides, trend tracking is performed to notify the
    %nurse when the trend of the heart rate (HR) changes.
    %Input:         Time - array of time points corresponding to HR signal 
    %               (in seconds)
    %               HR - array of HR points corresponding to time points
    %               (in bpm)
    %               StartUpLimit - default upper limit (in bpm)
    %               StartLowLimit - default lower limit (in bpm)
    %               margin - maximum percentage above set limit which indicates 
    %               high risk of danger (in percentage)
    %               RedAlarmTimeUpper - time above set limit including margin  
    %               which indicates high risk of danger (in seconds)
    %               YellowAlarmTimeUpper - time above set limit which indicates
    %               moderate risk of danger (in seconds)
    %               ResetTime - time after which the counted alarm periods
    %               needs to be resetted (in hours)
    %               UpperFreq - amount of upper limit crossings after which a
    %               new upper limit needs to be suggested
    %               PT - pausetime between alarms to examine changes

    %% Display HR signal
    figure('units','normalized','outerposition',[0 0 1 1]);

    xlabel('Time (s)')
    ylabel('HR (bpm)')

    %HR line
    h=animatedline('Color','k','LineStyle','-','LineWidth',2);

    %Upper limit line
    UpLim=animatedline('Color','m','LineStyle','-','LineWidth',2);

    %Lower limit line
    LowLim=animatedline('Color','m','LineStyle','-','LineWidth',2);

    %Upper limit inclusive margin line
    ExLim=animatedline('Color','m','LineStyle',':','LineWidth',2);

    %% Remember default upper limit
    DefaultStartUpLimit=StartUpLimit;

    %% Alarm generation
    %Start with empty alarm period
    HigherPercAmount=0;
    BetwPercAmount=0;
    RedAlarmGiven=false;
    YellowAlarmGiven=false;

    %Start time savings of values above margin
    HigherPercTime=[];
    NormalPercTime=[];

    %Start HR savings
    BetwValues=[];
    UpperHR=[];

    %Start with zero counted crossing values
    HigherPercSet=0;
    LowerPercSet=0;
    BetwPercSet=0;
    UpperSet=0;
    BetwValuesSet=0;
    BetwValuesSetTime=0;
    UpperCount=0;
    BetwValuesCount=0;
    NormalPercSet=0;
    NormalSet=0;

    %Start time of period determining upper limit adjustment
    BeginPeriodT=Time(1);

    %Start array to save all upper and lower limits
    StartUpLimits=zeros(1,length(HR));
    StartLowLimits=StartLowLimit.*ones(1,length(HR));

    for i=1:length(HR)   

        NormalPercSet = NormalPercSet + 1;
        NormalSet = NormalSet + 1;    
        NormalHR(NormalSet)=80;
        StartUpLimits(i) = StartUpLimit;

        %Draw point with corresponding limits
        addpoints(h,Time(i),HR(i));
        drawnow
        addpoints(UpLim,Time(i),StartUpLimit)
        drawnow
        addpoints(LowLim,Time(i),StartLowLimit)
        drawnow
        addpoints(ExLim,Time(i),StartUpLimit.*(1+(margin/100)))
        drawnow

      %% Determine if alarm is sufficient
      
        %Determine if start upper limit is different from current upper limit
        %and if HR is between these two values
        if DefaultStartUpLimit~=StartUpLimit&&HR(i)>=DefaultStartUpLimit&&HR(i)<=StartUpLimit
            %Count number of times value is between start upper limit and
            %current upper limit
            BetwValuesSetTime=BetwValuesSetTime+1;
            BetwValuesSet=BetwValuesSet+1;
            if BetwValuesSet==1
                BetwValuesCount=BetwValuesCount+1;
            end

%             % Save HR values that do not trigger an alarm, for trend tracking
%             NormalPercTime(NormalPercSet)=Time(i);
%             NormalHR(NormalSet)=HR(i); 
% 
            %Save time and HR values between start upper limit and current
            %upper limit
            BetwValues(BetwValuesSet)=HR(i);
            BetwValuesTime(BetwValuesSetTime)=Time(i);

            %Determine if it is same period as previous
            if BetwValuesSet>1&&BetwValuesTime(length(BetwValuesTime)-1)~=Time(i-1)
                %Amount of periods between start upper limit and current limit
                BetwValuesCount=BetwValuesCount+1;
            end

            %Determine if counted periods are more than set frequency
            %or if time is more than set reset time
            if BetwValuesCount>UpperFreq&&(Time(i)-BeginPeriodT)<ResetTime*3600&&DefaultStartUpLimit~=StartUpLimit                
                %Suggest new upper limit, react on chosen answer and reset
                %counted values
                [StartUpLimit,BeginPeriodT]=ChangeLimit(Time(i),BetwValues,StartUpLimit,DefaultStartUpLimit);
                ResetValues;

            elseif (Time(i)-BeginPeriodT)>=ResetTime*3600
                %Reset counted values
                ResetValues;
                BeginPeriodT=Time(i);  
            end
      
      
          
        elseif HR(i)>=StartUpLimit*(1+(margin/100)) %if HR falls above upper limit including margin
            HigherPercSet=HigherPercSet+1; %Count how many times in a row this has occured
            if HigherPercSet==1
                UpperCount=UpperCount+1;
                BeginTime=Time(i); %If HR is above upper limit for first time (first crossing), start timing
            else 
                DifferenceTime=Time(i)-BeginTime; %Keep track of how long HR is above limit
                if ~YellowAlarmGiven %Give yellow alarm once
                    Sound(200) %make a sound (frequency 200) for 1 second if yellow alarm given
                    ColorPlotHR(PT,HR(i),Time(i),2,RedAlarmTimeUpper,YellowAlarmTimeUpper);
                    YellowAlarmGiven=true;
                end 
                
                if DifferenceTime>=RedAlarmTimeUpper && ~RedAlarmGiven %If HR is above limit for RedAlarm time or longer, give Red alarm once
                    Sound(300) %make a sound (frequency 300) for 1 second if red alarm given
                    ColorPlotHR(PT,HR(i),Time(i),1,RedAlarmTimeUpper,YellowAlarmTimeUpper);
                    RedAlarmGiven=true;
                
                end
            end
            
            %Count number of times value crosses given upper limit
            UpperSet=UpperSet+1;

            %Save time values crossing given margin
            HigherPercTime(HigherPercSet)=Time(i);

            %Save HR values crossing given upper limit
            UpperHR(UpperSet)=HR(i);

            %Determine if it is same period as previous        
            if HigherPercSet>1&&HigherPercTime(length(HigherPercTime)-1)~=Time(i-1)
                %Count amount of upper limit crossing periods
                UpperCount=UpperCount+1;
            end

            %Determine if upper limit crossings is more than set frequency
            %or if time is more than set reset time
            % Miss nog toevoegen dat upper limit ook weer verlaagd kan
            % worden als signaal dit aangeeft. Ik vraag me ook af of we dit
            % niet ook moeten doen voor lowerLimit (of is dit gewoon 1
            % harde waarde)
            if UpperCount>UpperFreq&&(Time(i)-BeginPeriodT)<ResetTime*3600
                %Suggest new upper limit, react on chosen answer and reset
                %counted values
                [StartUpLimit,BeginPeriodT]=ChangeLimit(Time(i),UpperHR,StartUpLimit,DefaultStartUpLimit);
                ResetValues;

            elseif (Time(i)-BeginPeriodT)>=ResetTime*3600
                %Reset counted values
                ResetValues;
                BeginPeriodT=Time(i);     
            end
            
            
        elseif HR(i)<StartUpLimit && HigherPercSet>1 %If HR reaches upper limit from above (second crossing), reset all alarms
                HigherPercSet=0;
                YellowAlarmGiven=false;
                RedAlarmGiven=false;
           
            
            
        elseif HR(i)>=StartUpLimit %if HR falls above upper limit, but within margin
            BetwPercSet=BetwPercSet+1;
            if BetwPercSet==1
                BeginTime=Time(i);
                UpperCount=UpperCount+1;
            else 
                DifferenceTime=Time(i)-BeginTime;
                if DifferenceTime>=YellowAlarmTimeUpper && ~YellowAlarmGiven %give yellow alarm
                    Sound(200) %make a sound (frequency 200) for 1 second if yellow alarm given
                    ColorPlotHR(PT,HR(i),Time(i),3,RedAlarmTimeUpper,YellowAlarmTimeUpper);
                    YellowAlarmGiven=true;
                end
         
            end
            
            %Count number of times value crosses given upper limit
            UpperSet=UpperSet+1;

            %Save time values that crosses upper limit, but stays between given
            %margin
            BetwPercTime(BetwPercSet)=Time(i);

            %Save HR values crossing given upper limit
            UpperHR(UpperSet)=HR(i);

            %Determine if it is same period as previous
            if BetwPercSet>1&&BetwPercTime(length(BetwPercTime)-1)~=Time(i-1)
                %Count amount of upper limit crossing periods
                UpperCount=UpperCount+1;
            end

            %Determine if upper limit crossings is more than set frequency
            %or if time is more than set reset time
            % Miss nog toevoegen dat upper limit ook weer verlaagd kan
            % worden als signaal dit aangeeft. Ik vraag me ook af of we dit
            % niet ook moeten doen voor lowerLimit (of is dit gewoon 1
            % harde waarde)        
            if UpperCount>UpperFreq&&(Time(i)-BeginPeriodT)<ResetTime*360
                %Suggest new upper limit, react on chosen answer and reset
                %counted values
                [StartUpLimit,BeginPeriodT]=ChangeLimit(Time(i),UpperHR,StartUpLimit,DefaultStartUpLimit);
                ResetValues;

            elseif (Time(i)-BeginPeriodT)>=ResetTime*3600
                %Reset counted values
                ResetValues;
                BeginPeriodT=Time(i);           
            end
            
           
         elseif HR(i)<StartUpLimit && BetwPercSet>1 && ~RedAlarmGiven && ~YellowAlarmGiven %If HR reaches margin from above (second crossing), reset all alarms
                BetwPercSet=0;
                YellowAlarmGiven=false;
         end
            
                    
        
        %Determine if HR is below lower limit, if so: give red alarm
        if HR(i)<StartLowLimit    
            LowerPercSet=LowerPercSet+1;
            if ~RedAlarmGiven
                Sound(300) %make a sound (frequency 300) for 1 second if red alarm given
                ColorPlotHR(PT,HR(i),Time(i),4,RedAlarmTimeUpper,YellowAlarmTimeUpper);
                RedAlarmGiven=true;    
            end
        elseif HR(i)>=StartLowLimit && LowerPercSet>1 %If HR reaches upper limit from above (second crossing), reset all alarms
            LowerPercSet=0;
            RedAlarmGiven=false;
        end
    end
    %% Set background color of the image to white, to make colors more visible
    set(gcf,'color','w');

    % Find all trend-changing points in the HR
    hold on;
    [q,~] = findchangepts(NormalHR,'Statistic','rms','MinThreshold',0.005);

    % Plot all trend-changing points as dashed lines
    for i = 1:length(q)
        p = plot([Time(q(i)) Time(q(i))], [StartLowLimit StartUpLimits(q(i))]);
        hold on;
        p.LineStyle = '--';
        p.Color = 'b';
        p.Color(4) = 0.5;
    end

end