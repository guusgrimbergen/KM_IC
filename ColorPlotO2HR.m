function ColorPlotO2HR(Alarm,Time,SpO2)
    %This function plots and displays the sufficient alarm with corresponding
    %color and text. 
    %Input:         SpO2 - corresponding oxygen saturation value of alarm
    %               Time - corresponding time value of alarm    

    %Generate marker in corresponding color in SpO2 signal
    BA=animatedline('Color','b','Marker','d','LineWidth',10);     
    
    
    %Alarm 1: Both SpO2 and HR exceed outer limits
    if Alarm==1
       %Create warning box
        f=warndlg(['Observation: both SpO2 and HR exceed limits within timespan'],'WindowStyle','replace');
        movegui(f,'north');
        set (f,'Color','b');

       
        addpoints(BA,Time,SpO2)
        drawnow
       
    end
end
