function [StartUpLimit,BeginPeriodT]=ChangeLimit(Time,HR,StartUpLimit,FirstUpLimit)
    %This function suggests a new upper limit and gives the user the option to
    %change the upper limit into the suggested upper limit, to change it into  
    %an own given upper limit or to remain the current upper limit.
    %Input:         Time - current time point
    %               HR - HR values within specific area
    %               StartUpLimit - current upper limit (in bpm)
    %               FirstUpLimit - default upper limit (in bpm)
    %Output:        StartUpLimit - determined upper limit (in bpm)
    %               BeginPeriodT - new start time of period determining upper 
    %               limit adjustment
    
    Sound(100) %make a sound (frequency 100) for 1 second if a pop up shows that suggests a new upper limit
    
    BeginPeriodT=Time;
    NewUpperLim=round(mean(HR));
    if NewUpperLim>FirstUpLimit
        Change=questdlg(['Do you want to change the upper limit from ', num2str(StartUpLimit),' bpm to ',num2str(NewUpperLim),' bpm ?'],'Suggestion: change upper limit','Yes','No','Other limit','Yes');
        switch Change
            case 'Yes'
                disp(['The upper limit is changed from ', num2str(StartUpLimit),' bpm to ',num2str(NewUpperLim),' bpm.']);
                StartUpLimit=NewUpperLim;
            case 'No'
                disp(['The upper limit remains at ', num2str(StartUpLimit),' bpm.']);
            case 'Other limit'
                OtherLimit=inputdlg('Choose another upper limit in bpm:','Other limit',[1 50]);
                OtherLimit=cellfun(@str2num,OtherLimit);
                StartUpLimit=OtherLimit;                      
        end

    %Suggested upper limit cannot be lower than default upper limit    
    else
        NewUpperLim=FirstUpLimit;
        Change=questdlg(['Do you want to change the upper limit from ', num2str(StartUpLimit),' bpm to ',num2str(NewUpperLim),' bpm ?'],'Suggestion: change upper limit','Yes','No','Other limit','Yes');
        switch Change
            case 'Yes'
                disp(['The upper limit is changed from ', num2str(StartUpLimit),' bpm to ',num2str(NewUpperLim),' bpm.']);
                StartUpLimit=NewUpperLim;
            case 'No'
                disp(['The upper limit remains at ', num2str(StartUpLimit),' bpm.']);
            case 'Other limit'
                OtherLimit=inputdlg('Choose another upper limit in bpm:','Other limit',[1 50]);
                OtherLimit=cellfun(@str2num,OtherLimit);
                StartUpLimit=OtherLimit;
        end
    end
end