function test = AlarmManagement(Time,HR, SpO2, HR_StartUpLimit, HR_StartLowLimit, HR_PercMargin,...
HR_RedAlarmTimeUpper, HR_YellowAlarmTimeUpper, O2_LowerLimit, O2_AbsMargin, O2_RedAlarmTimeLower, ...
O2_YellowAlarmTimeLower, ResetTime, UpperFreq)

 %% Display HR signal
    figure('units','normalized','outerposition',[0 0 1 1]);
    
    %HR figure
    HR_axes=subplot(2,1,1);
    axis([0 Time(end) 40 160]);
    
    HR_h=animatedline('Color','k','LineStyle','-','LineWidth',2, 'Parent', HR_axes);
    HR_UpLim=animatedline('Color','m','LineStyle','-','LineWidth',2, 'Parent', HR_axes);
    HR_LowLim=animatedline('Color','m','LineStyle','-','LineWidth',2, 'Parent', HR_axes);
    HR_ExLim=animatedline('Color','m','LineStyle',':','LineWidth',2, 'Parent', HR_axes);

    xlabel('Time (s)')
    ylabel('HR (bpm)')

    %O2 figure
    O2_axes=subplot(2,1,2);
    axis([0 Time(end) 70 100]);
    
    O2_h=animatedline('Color','k','LineStyle','-', 'LineWidth',2, 'Parent', O2_axes);
    O2_LowLim=animatedline('Color','m','LineStyle','-','LineWidth',2, 'Parent', O2_axes);
    O2_ExLim=animatedline('Color','m','LineStyle',':','LineWidth',2, 'Parent', O2_axes);

    xlabel('Time (s)')
    ylabel('SpO2 (%)')

    %% Remember default upper limit
    DefaultStartUpLimit=HR_StartUpLimit;

    %% Alarm generation
    %HR and O2 combined initialization
    BlueAlarmGiven=false;
    HRO2Set=0;
    
    %HR initialization
    
    %Start with empty alarm period
    HR_HigherPercAmount=0;
    HR_BetwPercAmount=0;
    HR_RedAlarmGiven=false;
    HR_YellowAlarmGiven=false;

    %Start time savings of values above margin
    HR_HigherPercTime=[];
    HR_NormalPercTime=[];

    %Start HR savings
    HR_BetwValues=[];
    UpperHR=[];

    %Start with zero counted crossing values
    HR_HigherPercSet=0;
    HR_LowerPercSet=0;
    HR_BetwPercSet=0;
    HR_UpperSet=0;
    HR_BetwValuesSet=0;
    HR_BetwValuesSetTime=0;
    HR_UpperCount=0;
    HR_BetwValuesCount=0;
    HR_NormalPercSet=0;
    HR_NormalSet=0;

    %Start time of period determining upper limit adjustment
    HR_BeginPeriodT=Time(1);

    %Start array to save all upper and lower limits
    HR_StartUpLimits=zeros(1,length(HR));
    HR_StartLowLimits=HR_StartLowLimit.*ones(1,length(HR));
    
    
    %O2 initialization
    
    O2_LowerPercAmount=0;
    O2_MarginPercAmount=0;
    O2_RedAlarmGiven=false;
    O2_YellowAlarmGiven=false;
    O2_StartLowerlimit=O2_LowerLimit;
   
    
    for i=1:length(Time)   
        

        HR_NormalPercSet = HR_NormalPercSet + 1;
        HR_NormalSet = HR_NormalSet + 1;    
        HR_NormalHR(HR_NormalSet)=80;
        HR_StartUpLimits(i) = HR_StartUpLimit;

        %Draw point with corresponding limits for HR
        addpoints(HR_h,Time(i),HR(i))
        addpoints(HR_UpLim,Time(i),HR_StartUpLimit)
        addpoints(HR_LowLim,Time(i),HR_StartLowLimit)
        addpoints(HR_ExLim,Time(i),HR_StartUpLimit.*(1+(HR_PercMargin/100)))

        %Draw point with corresponding limits for O2
        addpoints(O2_h,Time(i),SpO2(i))
        addpoints(O2_LowLim,Time(i),O2_StartLowerlimit)
        addpoints(O2_ExLim,Time(i),O2_AbsMargin)
        drawnow
        
        
        %% ALARM CHECK
                   

      
        % HR ALARM CHECK
        
        %Determine if start upper limit is different from current upper limit
        %and if HR is between these two values
        if DefaultStartUpLimit~=HR_StartUpLimit&&HR(i)>=DefaultStartUpLimit&&HR(i)<=HR_StartUpLimit
            %Count number of times value is between start upper limit and
            %current upper limit
            HR_BetwValuesSetTime=HR_BetwValuesSetTime+1;
            HR_BetwValuesSet=HR_BetwValuesSet+1;
            if HR_BetwValuesSet==1
                HR_BetwValuesCount=HR_BetwValuesCount+1;
            end

 
            %Save time and HR values between start upper limit and current
            %upper limit
            HR_BetwValues(HR_BetwValuesSet)=HR(i);
            HR_BetwValuesTime(HR_BetwValuesSetTime)=Time(i);

            %Determine if it is same period as previous
            if HR_BetwValuesSet>1&&HR_BetwValuesTime(length(HR_BetwValuesTime)-1)~=Time(i-1)
                %Amount of periods between start upper limit and current limit
                HR_BetwValuesCount=HR_BetwValuesCount+1;
            end

            %Determine if counted periods are more than set frequency
            %or if time is more than set reset time
            if HR_BetwValuesCount>UpperFreq&&(Time(i)-HR_BeginPeriodT)<ResetTime*3600&&DefaultStartUpLimit~=HR_StartUpLimit                
                %Suggest new upper limit, react on chosen answer and reset
                %counted values
                [HR_StartUpLimit,HR_BeginPeriodT]=ChangeLimit(Time(i),HR_BetwValues,HR_StartUpLimit,DefaultStartUpLimit);
                ResetValues;

            elseif (Time(i)-HR_BeginPeriodT)>=ResetTime*3600
                %Reset counted values
                ResetValues;
                HR_BeginPeriodT=Time(i);  
            end
      
      
          
        elseif HR(i)>=HR_StartUpLimit*(1+(HR_PercMargin/100)) %if HR falls above upper limit including margin
            if Time(i)>10 %if at minimum ten seconds have passed
                idx=find(Time==(Time(i)-10));%Get the O2 index for ten seconds in the past
                O2_PastTenSeconds=SpO2(idx:i);

                if all(O2_PastTenSeconds<=O2_StartLowerlimit) && ~BlueAlarmGiven %If O2 is outside lower limit, give blue alarm once
                    Sound(500)
                    ColorPlotO2HR(1,Time(i),SpO2(i));  
                    BlueAlarmGiven=true;
                end
            end
            
            
            HR_HigherPercSet=HR_HigherPercSet+1; %Count how many times in a row this has occured
            if HR_HigherPercSet==1
                HR_UpperCount=HR_UpperCount+1;
                HR_BeginTime=Time(i); %If HR is above upper limit for first time (first crossing), start timing
            else 
                HR_DifferenceTime=Time(i)-HR_BeginTime; %Keep track of how long HR is above limit
                if ~HR_YellowAlarmGiven && ~BlueAlarmGiven %Give yellow alarm once
                    %Sound(200) %make a sound (frequency 200) for 1 second if yellow alarm given
                    ColorPlotHR(HR(i),Time(i),2,HR_RedAlarmTimeUpper,HR_YellowAlarmTimeUpper);
                    HR_YellowAlarmGiven=true;
                end 
                
                if HR_DifferenceTime>=HR_RedAlarmTimeUpper && ~HR_RedAlarmGiven && ~BlueAlarmGiven %If HR is above limit for RedAlarm time or longer, give Red alarm once
                    Sound(300) %make a sound (frequency 300) for 1 second if red alarm given
                    ColorPlotHR(HR(i),Time(i),1,HR_RedAlarmTimeUpper,HR_YellowAlarmTimeUpper);
                    HR_RedAlarmGiven=true;
                
                end
            end
            
            %Count number of times value crosses given upper limit
            HR_UpperSet=HR_UpperSet+1;

            %Save time values crossing given margin
            HR_HigherPercTime(HR_HigherPercSet)=Time(i);

            %Save HR values crossing given upper limit
            UpperHR(HR_UpperSet)=HR(i);

            %Determine if it is same period as previous        
            if HR_HigherPercSet>1&&HR_HigherPercTime(length(HR_HigherPercTime)-1)~=Time(i-1)
                %Count amount of upper limit crossing periods
                HR_UpperCount=HR_UpperCount+1;
            end

            %Determine if upper limit crossings is more than set frequency
            %or if time is more than set reset time
            if HR_UpperCount>UpperFreq&&(Time(i)-HR_BeginPeriodT)<ResetTime*3600
                %Suggest new upper limit, react on chosen answer and reset
                %counted values
                [HR_StartUpLimit,HR_BeginPeriodT]=ChangeLimit(Time(i),UpperHR,HR_StartUpLimit,DefaultStartUpLimit);
                ResetValues;

            elseif (Time(i)-HR_BeginPeriodT)>=ResetTime*3600
                %Reset counted values
                ResetValues;
                HR_BeginPeriodT=Time(i);     
            end
            
            
        elseif HR(i)<HR_StartUpLimit && HR_HigherPercSet>1 %If HR reaches upper limit from above (second crossing), reset all alarms
                HR_HigherPercSet=0;
                HR_YellowAlarmGiven=false;
                HR_RedAlarmGiven=false;
           
            
            
        elseif HR(i)>=HR_StartUpLimit %if HR falls above upper limit, but within margin
            HR_BetwPercSet=HR_BetwPercSet+1;
            if HR_BetwPercSet==1
                HR_BeginTime=Time(i);
                HR_UpperCount=HR_UpperCount+1;
            else 
                HR_DifferenceTime=Time(i)-HR_BeginTime;
                if HR_DifferenceTime>=HR_YellowAlarmTimeUpper && ~HR_YellowAlarmGiven && ~BlueAlarmGiven %give yellow alarm
                    %Sound(200) %make a sound (frequency 200) for 1 second if yellow alarm given
                    ColorPlotHR(HR(i),Time(i),3,HR_RedAlarmTimeUpper,HR_YellowAlarmTimeUpper);
                    HR_YellowAlarmGiven=true;
                end
         
            end
            
            %Count number of times value crosses given upper limit
            HR_UpperSet=HR_UpperSet+1;

            %Save time values that crosses upper limit, but stays between given
            %margin
            HR_BetwPercTime(HR_BetwPercSet)=Time(i);

            %Save HR values crossing given upper limit
            UpperHR(HR_UpperSet)=HR(i);

            %Determine if it is same period as previous
            if HR_BetwPercSet>1&&HR_BetwPercTime(length(HR_BetwPercTime)-1)~=Time(i-1)
                %Count amount of upper limit crossing periods
                HR_UpperCount=HR_UpperCount+1;
            end

            %Determine if upper limit crossings is more than set frequency
            %or if time is more than set reset time       
            if HR_UpperCount>UpperFreq&&(Time(i)-HR_BeginPeriodT)<ResetTime*360
                %Suggest new upper limit, react on chosen answer and reset
                %counted values
                [HR_StartUpLimit,HR_BeginPeriodT]=ChangeLimit(Time(i),UpperHR,HR_StartUpLimit,DefaultStartUpLimit);
                ResetValues;

            elseif (Time(i)-HR_BeginPeriodT)>=ResetTime*3600
                %Reset counted values
                ResetValues;
                HR_BeginPeriodT=Time(i);           
            end
            
           
         elseif HR(i)<HR_StartUpLimit && HR_BetwPercSet>1 && ~HR_RedAlarmGiven && ~HR_YellowAlarmGiven && ~BlueAlarmGiven %If HR reaches margin from above (second crossing), reset all alarms
                HR_BetwPercSet=0;
                HR_YellowAlarmGiven=false;
         end
            
                    
        
        %Determine if HR is below lower limit, if so: give red alarm
        if HR(i)<HR_StartLowLimit 
            if Time(i)>10 %if at minimum ten seconds have passed
                idx=find(Time==(Time(i)-10));%Get the O2 index for ten seconds in the past
                O2_PastTenSeconds=SpO2(idx:i);

                if all(O2_PastTenSeconds<=O2_StartLowerlimit) && ~BlueAlarmGiven %If O2 is outside lower limit, give blue alarm once
                    Sound(500)
                    ColorPlotO2HR(1,Time(i),SpO2(i));  
                    BlueAlarmGiven=true;
                end
            end
            
            HR_LowerPercSet=HR_LowerPercSet+1;
            if ~HR_RedAlarmGiven && ~BlueAlarmGiven
                Sound(300) %make a sound (frequency 300) for 1 second if red alarm given
                ColorPlotHR(HR(i),Time(i),4,HR_RedAlarmTimeUpper,HR_YellowAlarmTimeUpper);
                HR_RedAlarmGiven=true;    
            end
        elseif HR(i)>=HR_StartLowLimit && HR_LowerPercSet>1 %If HR reaches upper limit from above (second crossing), reset all alarms
            HR_LowerPercSet=0;
            HR_RedAlarmGiven=false;
            if SpO2(i)>=O2_StartLowerlimit
                BlueAlarmGiven=false;
            end
        end
        
        
        
        %O2 ALARM CHECK
        
        if SpO2(i)<=O2_StartLowerlimit %if SpO2 falls below lower limit
            O2_LowerPercAmount=O2_LowerPercAmount+1; %Count how many times in a row this has occured
            if Time(i)>10 %if at minimum ten seconds have passed
                idx=find(Time==(Time(i)-10));%Get the HR index for ten seconds in the past
                HR_PastTenSeconds=HR(idx:i);

                if (all((HR_PastTenSeconds>=HR_StartUpLimit*(1+(HR_PercMargin/100)))) || all(HR_PastTenSeconds<=HR_StartLowLimit)) && ~BlueAlarmGiven %If HR is outside any limit, give blue alarm once
                    Sound(500)
                    ColorPlotO2HR(1,Time(i),SpO2(i));  
                    BlueAlarmGiven=true;
                end
            end
            if O2_LowerPercAmount==1
                O2_BeginTime=Time(i); %If SpO2 is below lower limit for first time (first crossing), start timing
            else 
                O2_DifferenceTime=Time(i)-O2_BeginTime; %Keep track of how long SpO2 is below limit
                
                if ~O2_YellowAlarmGiven && ~BlueAlarmGiven %Give yellow alarm once
                    %Sound(200)
                    ColorPlotO2(SpO2(i),Time(i),2,O2_RedAlarmTimeLower,O2_YellowAlarmTimeLower);
                    O2_YellowAlarmGiven=true;
                end 
                
                if O2_DifferenceTime>=O2_RedAlarmTimeLower && ~O2_RedAlarmGiven && ~BlueAlarmGiven %If SpO2 is below limit for RedAlarm time or longer, give Red alarm once
                    Sound(300)
                    ColorPlotO2(SpO2(i),Time(i),1,O2_RedAlarmTimeLower,O2_YellowAlarmTimeLower);
                    O2_RedAlarmGiven=true;
                
                end
            end
        elseif SpO2(i)>=O2_StartLowerlimit && O2_LowerPercAmount>1 %If SpO2 reaches lower limit from below (second crossing), reset all alarms
            O2_LowerPercAmount=0;
            O2_YellowAlarmGiven=false;
            O2_RedAlarmGiven=false;
            if HR(i)>=HR_StartLowLimit
                BlueAlarmGiven=false;
            end
        
            
            
        elseif SpO2(i)<=O2_AbsMargin %if SpO2 falls below margin
            O2_MarginPercAmount=O2_MarginPercAmount+1;
            if O2_MarginPercAmount==1
                O2_BeginTime=Time(i);
            else 
                O2_DifferenceTime=Time(i)-O2_BeginTime;
                if O2_DifferenceTime>=O2_YellowAlarmTimeLower && ~O2_YellowAlarmGiven && ~BlueAlarmGiven
                    for z=i:i+10
                        if (HR(z)>HR_StartUpLimit*(1+(HR_PercMargin/100)) || HR(z)<HR_StartLowLimit) && ~O2_YellowAlarmGiven
                            %Sound(200)
                            ColorPlotO2(SpO2(i),Time(i),3,O2_RedAlarmTimeLower,O2_YellowAlarmTimeLower);
                            O2_YellowAlarmGiven=true;
                        end
                    end
                end
            end
        elseif SpO2(i)>=O2_AbsMargin && O2_MarginPercAmount>1 %If SpO2 reaches margin from below (second crossing), reset all alarms
            O2_MarginPercAmount=0;
            O2_YellowAlarmGiven=false;
            O2_RedAlarmGiven=false;
       
        
        end
     end
        
        
        
    %% Set background color of the image to white, to make colors more visible
    set(gcf,'color','w');

end



