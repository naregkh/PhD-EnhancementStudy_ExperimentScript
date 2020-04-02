function [acc,H,FA ] = QuickSum( input_args )
%retursn quick summary of the behavioural data 

% where the files are
CD = 'Z:\Nareg_Experiment2\Experimment2_Script_NK_June19\Output\';

d = load([CD input_args]);
Trials = size(d,1);

acc = sum(d(:,2)==d(:,4))/Trials; % overall accuracy 
H   = sum((d(:,2)==2).*d(:,4)==2)/sum(d(:,2)==2); % hit rate
FA  = sum((d(:,2)==1).*d(:,4)==1)/sum(d(:,2)==1); % false alarm rate


disp('. . . . . . . . . . . . . . . . . . . . . . . . ')
disp([num2str(Trials),' trials in the experiment ']); 
disp(['H: ' num2str(H) ' CR: ' num2str(FA)])
disp('. . . . . . . . . . . . . . . . . . . . . . . . ')

end

