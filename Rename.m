% a ='C:\Documents and Settings\EEGLAB\My Documents\MATLAB\Nareg\Rename'; %take images from this directory

CD = [ cd '\Rename'];

TheImages = dir( fullfile(CD, '*.jpg') );
fileNames = { TheImages.name };

% condition 1-control, 2-experimental (city tour/museum tour)
Condition = 2;  % important! use correct condition

No_Images = numel( TheImages ); %total number of image 320 usually (always multiple of 4)


% loop should run for 80 times, the loop inside 4 times

for Exhibits = 1:No_Images
    
    % find and get the old file
    target = (Exhibits);
    OldFile = fullfile(CD, fileNames{ target });
    
    %make the new name
    %condition, exhibit
    newName = fullfile(CD,(['Picture' int2str(Condition) int2str(Exhibits) '.jpg']));
    
    %rename old file with new file
    movefile( OldFile , newName );
    
end

disp(['Files renamed ', num2str(No_Images)])

clearvars No_Images newName TheImages CD
