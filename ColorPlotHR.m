function ColorPlotHR(HR,Time,Alarm,RedAlarmTimeUpper,YellowAlarmTimeUpper)
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

    %Generate marker in corresponding colors
    subplot(2,1,1)
    RA=animatedline('Color','r','Marker','d','LineWidth',10); 
    YA=animatedline('Color','y','Marker','d','LineWidth',10);
    CA=animatedline('Color','y','Marker','d','LineWidth',10);

    %Alarm 1: HR is above upper limit including margin
    if Alarm==1
        %Create warning box
        f=warndlg(['Observation: HR >',num2str(RedAlarmTimeUpper),' seconds above 10% margin of upper limit'],'WindowStyle','replace');
        movegui(f,'north');
        set (f,'Color','r');
        

        %Set corresponding marker in figure
        addpoints(RA,Time,HR)
        drawnow
        
    %Alarm 2: HR is above upper limit including margin, but within set timespan
    elseif Alarm==2
        %Create warning box
        f=warndlg(['Observation: HR <',num2str(RedAlarmTimeUpper),' seconds above 10% margin of upper limit'],'WindowStyle','replace');
        movegui(f,'north');
        set (f,'Color','y');
        

        %Set corresponding marker in figure
        addpoints(CA,Time,HR)
        drawnow
        

    %Alarm 3: HR is above upper limit, but between margin
    elseif Alarm==3
        %Create warning box
        f=warndlg(['Observation: HR >',num2str(YellowAlarmTimeUpper),' seconds above upper limit'],'WindowStyle','replace');
        movegui(f,'north');
        set (f,'Color','y');
        

        %Set corresponding marker in figure
        addpoints(YA,Time,HR)
        drawnow
        

    %Alarm 4: HR is below lower limit
    elseif Alarm==4
        %Create warning box
        f=warndlg('Observation: HR below lower limit','WindowStyle','replace');
        movegui(f,'north');
        set (f,'Color','r');
        

        %Set corresponding marker in figure
        addpoints(RA,Time,HR)
        drawnow
        

    end

end