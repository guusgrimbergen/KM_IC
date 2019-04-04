function ColorPlotO2(SpO2,Time,Alarm,RedAlarmTimeLower,YellowAlarmTimeLower)
    %This function plots and displays the sufficient alarm with corresponding
    %color and text. 
    %Input:         HR - corresponding heart rate value of alarm
    %               Time - corresponding time value of alarm
    %               Alarm - corresponding seriousness of alarm (1: HR is above 
    %               upper limit including margin, 2: HR is above upper limit 
    %               including margin, but within set timespan, 3: HR is above 
    %               upper limit, but between margin, 4: HR is below lower limit)
    %               RedAlarmTimeUpper - time above set limit including margin  
    %               which indicates high risk of danger (in seconds)
    %               YellowAlarmTimeUpper - time above set limit which indicates
    %               moderate risk of danger (in seconds)
    
    
    subplot(2,1,2)
    %Generate marker in corresponding colors
    RA=animatedline('Color','r','Marker','d','LineWidth',10); 
    YA=animatedline('Color','y','Marker','d','LineWidth',10);
    CA=animatedline('Color','y','Marker','d','LineWidth',10);

    %Alarm 1: SpO2 is below lower limit for RedAlarmTimeLower or longer
    if Alarm==1
       %Create warning box
        f=warndlg(['Observation: SpO2 >',num2str(RedAlarmTimeLower),' seconds below lower limit'],'WindowStyle','replace');
        movegui(f,'north');
        set (f,'Color','r');
        

        %Set corresponding marker in figure
        addpoints(RA,Time,SpO2)
        drawnow
        
       
    %Alarm 2: SpO2 is below lower limit, but shorter than RedAlarmTimeLower
    elseif Alarm==2
       %Create warning box
        f=warndlg('Observation: SpO2 below lower limit' ,'WindowStyle','replace');
        movegui(f,'north');
        set (f,'Color','y');
        

        %Set corresponding marker in figure
        addpoints(YA,Time,SpO2)
        drawnow
        
        
    %Alarm 3: SpO2 is below margin, but above lower limit for longer than
    % YellowAlarmTimeLower
    elseif Alarm==3
       %Create warning box
        f=warndlg(['Observation: SpO2 >',num2str(YellowAlarmTimeLower),' seconds below margin but above lower limit and HR outside limit within next 10 seconds '] ,'WindowStyle','replace');
        movegui(f,'north');
        set (f,'Color','y');
        

        %Set corresponding marker in figure
        addpoints(YA,Time,SpO2)
        drawnow
        


    end

end
