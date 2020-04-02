function [Name, Age, No_Exhibits, Handedness, LastEducation, Condition] = GetParticipantInfo()


prompt = {'Enter participant code:','Age:','Handedness:','Last Education:','N Exhibits:','Condition'};
title = 'Participant Information';
dims = [1 40];
definput = {'R_x','Years','L or R','A leves, BA, BSc, ...','Number','0 or 1'};
Output = inputdlg(prompt,title,dims,definput);


Name          = char(Output(1));
Age           = str2double(Output(2));
Handedness    = char(Output(3));
LastEducation = char(Output(4));
No_Exhibits   = str2double(Output(5));
Condition     = str2double(Output(6));    % Zero - Reactivation One - Recall/Retreival


end