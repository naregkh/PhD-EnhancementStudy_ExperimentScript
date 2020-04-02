%% Reminder
% remember to check the trigger setting on the EEG, in digital port
% setting, both on high active
cd 'Z:\Nareg_Experiment2\Experimment2_Script_NK_June19';

%% Clear the workspace
close, clear all; %#ok<CLALL>
sca;

%% Participant information

[Name, Age, No_Exhibits, Handedness, LastEducation, Cond] = GetParticipantInfo();

BreakTrial  = 10; % Every How many trials do you want a break

% Name = [num2str(rand()*10) '-' date]; Age = 1; No_Exhibits = 33; % for debugging
% Name = 'P_4'; 
% Age = 23; 
% No_Exhibits = 76; % for debugging

% Name = [num2str(rand()*10) '-' date]; Age = 1; No_Exhibits = 33; % for debugging
% Name = 'R_00'; 
% Handedness = 'R';
% LastEducation = 'MSc';
% Cond = '1';
% Age = 29; 
% No_Exhibits = 83; % for debugging


%% set up the triggers
config_io;
ioObj       = io64;
status      = io64(ioObj);
address     = hex2dec('3FF8'); % on this pc get this from device manager, PCI Express ECP Parallel Port (LPT3)
% address     = hex2dec('E010'); % on this pc get this from device manager, PCI Express ECP Parallel Port (LPT3)
% address     = hex2dec('D010'); % on this pc get this from device manager, PCI Express ECP Parallel Port (LPT3)


%% Initialise response box
dev.link = CedrusResponseBox('Open', 'COM4'); % on this pc get this from device manager, USB serial Port (COM_)
% dev.link = CedrusResponseBox('Open', 'COM7'); % on this pc get this from device manager, USB serial Port (COM_)
% dev.link = CedrusResponseBox('Open', 'COM5'); % on this pc get this from device manager, USB serial Port (COM_)


%% setting up trials
% each exhibit/block contains 4 picutres/trials, which are presented sequentially,
% so here we don't care about that.
% 80 for the experiment %number of exhibits in each condition (should be 80) IMPORTANT!!
No_Conditions   = 2; % museum  tour (walk) and Control
No_Blocks       = (No_Exhibits.* No_Conditions); % 160, each block contains 4 pictures thus a for loop within main while loop

rng('shuffle')
Block_Order     = randperm(No_Blocks);

Condition_Order = ceil(Block_Order./No_Exhibits);
Exhibit_Order   = mod(Block_Order,No_Exhibits) + 1;

Stim_Dur         = .5; % presentation time in seconds IF not untill response pressed
InterPicture_Dur = .5; % Inter trial duration

disp('Setting Up Trials')
%% 
try % try catch for not having to stop the matlab from task manager when something goes wrong!!

    %% Here we call some default settings for setting up Psychtoolbox

    HideCursor;
    
    PsychDefaultSetup(2); % starts psychtoolbox
    
    % Get the screen numbers
    screens = Screen('Screens');
    
    % Draw to the external screen if avaliable
    screenNumber = max(screens);
    
    % Define black and white
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    grey = white / 2;
    inc = white - grey;
    
    disp('Calling Defult settings')
    
    %% Creat output file
    string1 = cd; %sets string1 to hold the current working directory
    string2 = strcat(string1,'\','Output','\',Name,'_details.txt'); %concatenates string1 with some other strings to create a full file path
    
    File1_id = fopen(string2,'a'); %opens it for "appending", saving the "handle" in the variable File1_id
    fprintf(File1_id, '\n'); %prints a carriage return
    
    string3 = strcat(string1,'\','Output','\',Name,'_results.txt'); %prepares a second file path & name
    File2_id = fopen(string3,'a'); %opens the second file with a different handle
    
    Time = datestr(now); %gets details about time and date
    fprintf(File1_id, '%s \n', Time); % The %s tells matlab to print a string in that position, which is specified next
    fprintf(File1_id, 'Participant: %s \n', Name);
    fprintf(File1_id, 'Age: %4.0f \n', Age);
    fprintf(File1_id, 'Handedness: %s \n', Handedness);
    fprintf(File1_id, 'LastEducation: %s \n', LastEducation);
    fprintf(File1_id, 'Condition: %4.0f \n', Cond);
    fprintf(File1_id, 'N exhibit: %4.0f \n', No_Exhibits);
    
    disp('Creat OutPut File')
    
    %% Open an on screen window - not sure if this is needed 
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
    % Get the size of the on screen window
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    % Query the frame duration
    ifi = Screen('GetFlipInterval', window);
    % Get the centre coordinate of the window
    [xCenter, yCenter] = RectCenter(windowRect);
    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    disp('Open an on screen window')
    
    %% Welcome Screen
    % [nx, ny, bbox] = DrawFormattedText(w, mytext, 'center', 'center', 0);
    Screen('FillRect', window, [57 57 57]);
    Screen('TextFont',window, 'Calibri');
    Screen('TextSize',window, 23);
    WelcomeText = 'Welcome to the recongition task of the experiment. \n \n Press the right button if you remember the the picture \n and the left button if you dont. \n \n Hit any button to start the experiment';
    [xp, yp] = DrawFormattedText(window, WelcomeText, 'center', 'center', 0);
    % Not recognise, left button, familiar, middle
    %  remember, right button
    Screen('Flip', window);
    
    evt = CedrusResponseBox('WaitButtonPress', dev.link);
    %     [secs, keyCode] = KbWait;
    
    disp('Display Welcome Screen')
    
    %Flush button box presses
    CedrusResponseBox('FlushEvents', dev.link);
    
    %% the main loop
    
    %Set keyboard to listen for any entry
    ListenChar();
    FlushEvents();
    
    avail = 0;
    Block = 0;
    Trial = 0;
    
    pause(0.05); %50 miliseconds, seems to reduce errors
    
    while avail == 0 && Block < No_Blocks % loop through exhibits
        
        Block       = Block + 1;
        Condition   = Condition_Order(Block);
        Exhibit     = Exhibit_Order(Block);
        
        Trial = Trial + 1; % the trial number counter
        
        %% Clear cued response
        CedrusResponseBox('FlushEvents', dev.link); 
        
        %% Show image and 
        clearvars theImage imageTexture
        theImage = imread ([ cd '\ImageFolder\Picture' int2str(Condition) int2str(Exhibit) '.jpg']);
        % Make the image into a texture
        imageTexture = Screen('MakeTexture', window, theImage);
        pause(0.01);
        % the texture full size in the center of the screen. We first draw
        % the image in its correct orientation.
        Screen('DrawTexture', window, imageTexture, [0 0 2592 1944], [0 0 1280 1024]); %takes texture location and puts into display location.
        
        % Flip to the screen
        Screen('Flip', window);
        
        %% Send trigger for photo presentation 
        data_out    = Condition*10 ; % the trigger that is sent (1-control photo, 2-tour photo)
        io64(ioObj,address,data_out); % send a signal
        data_out = 0;
        pause(0.01); %10 miliseconds should be perfectly ok
        io64(ioObj,address,data_out); % stop sending a signal
        
        %% Take 1st response {remember or dont}, send trigger
        tic
        CedrusResponseBox('FlushEvents', dev.link);
        
        button_pressed = 0;
        while ((button_pressed == 2 | button_pressed == 8)~=1) % not zero or zero ?
            
            evt = CedrusResponseBox('WaitButtonPress', dev.link);
            button_pressed = evt.button; %reads which button was pressed from evt
            
            switch button_pressed
                case 2  % most left button, dont remember
                    Trigger_1 = 1;
                    Resp = 1;
                case 8 % right button, remember the photo
                    Trigger_1 = 2;
                    Resp = 2;
            end
        end
        
        RT1 = toc;
        
        CedrusResponseBox('FlushEvents', dev.link);
        
        data_out    = Trigger_1; % the trigger that is sent
        io64(ioObj,address,data_out); % send a signal
        data_out = 0;
        pause(0.01); %10 miliseconds should be perfectly ok
        io64(ioObj,address,data_out); % stop sending a signal
        
        %Flush button box presses
        CedrusResponseBox('FlushEvents', dev.link);
        
        %% the 2nd level response, send trigger
             
        % show confidence screen 
        clearvars theImage imageTexture
        theImage = imread ([ cd '\ConfidenceRating.jpg']);
        pause(0.01);
        imageTexture = Screen('MakeTexture', window, theImage);
        pause(0.01);
        Screen('DrawTexture', window, imageTexture, [0 0 960 720], [0 0 1280 1024]); %takes texture location and puts into display location.
        Screen('Flip', window);
        
        tic
        evt = CedrusResponseBox('WaitButtonPress', dev.link);
        RT2 = toc;
        
        button_pressed = evt.button; %reads which button was pressed from evt
        
        % code response % 2 Not recognise, left button, 5 familiar, middle
        % 8 remember, right button
        switch button_pressed
            case 2
                Trigger_2 = 21; % left side, less confident
                Conf = 1;
            case 3
                Trigger_2 = 22;
                Conf = 2;
            case 4
                Trigger_2 = 23;
                Conf = 3;
            case 5
                Trigger_2 = 24;
                Conf = 4;
            case 6
                Trigger_2 = 25;
                Conf = 5;
            case 7
                Trigger_2 = 26;
                Conf = 6;
            case 8
                Trigger_2 = 27; % right side, more confident
                Conf = 7;
        end
        
        data_out    = Trigger_2; % the trigger that is sent
        io64(ioObj,address,data_out); % send a signal
        data_out = 0;
        pause(0.01); %10 miliseconds should be perfectly ok
        io64(ioObj,address,data_out); % stop sending a signal
        
        % Flush button box presses
        CedrusResponseBox('FlushEvents', dev.link);
        
        %% Fill the screen black between picutre
        Screen('FillRect', window, [grey]);
        Screen('Flip', window);
        WaitSecs(InterPicture_Dur); % duration of each presentation
        
        
        %% Write results in file
        fprintf(File2_id, '%4.0f\t%4.0f\t%4.0f\t%4.0f\t%4.0f\t%4.0f\t%4.0f\n', Trial, Condition, Exhibit, Resp, RT1*1000 ,Conf, RT2*1000);
        
        
        %% Breaks if a key was pressed, sometimes doesn't work!
        [avail, numChars] = CharAvail;
        if avail == 1
            disp 'key pressed'
            Screen('FillRect', window, [57 57 57]);
            Screen('TextFont',window, 'Times');
            Screen('TextSize',window, 23);
            WelcomeText = 'Break time! \n \n Press any button to continue';
            [xp, yp] = DrawFormattedText(window, WelcomeText, 'center', 'center', 0);
            % Not recognise, left button, familiar, middle
            %  remember, right button
            Screen('Flip', window);
            evt = CedrusResponseBox('WaitButtonPress', dev.link);
        end
        ListenChar(0);
        
        
        %% Break
        if mod(Trial,BreakTrial) == 0 && ((Trial==No_Blocks)~=1)
            Screen('FillRect', window, [57 57 57]);
            Screen('TextFont',window, 'Times');
            Screen('TextSize',window, 23);
            WelcomeText = 'Break time! \n \n Press any button to continue';
            [xp, yp] = DrawFormattedText(window, WelcomeText, 'center', 'center', 0);
            % Not recognise, left button, familiar, middle
            % remember, right button
            Screen('Flip', window);
            pause(0.05); %50 miliseconds, seems to reduce errors
            evt = CedrusResponseBox('WaitButtonPress', dev.link);
        end
        
        % %   show white screen between blocks, not sure if it's neccesary
        %     Screen('FillRect', window, [57 57 57]);
        %     Screen('Flip', window);
        %     WaitSecs(InterBlock_Dur);
        
    end
    
    
    % Wait
    WaitSecs(.5);
    
    CedrusResponseBox('FlushEvents', dev.link);
    
    %% End of the experiment
    [xp, yp] = DrawFormattedText(window, 'End of experiment', 'center', 'center', 0);
    Screen('Flip', window);
    evt=CedrusResponseBox('WaitButtonPress', dev.link); % for the response box
    sca;
    
    % Quick summary of the experiment 
    QuickSum([Name,'_results.txt']);
    
    ShowCursor;
%     clearvars % commented out for debugging 
    disp 'Finished'
    clear io64; % for the triggers
    
    
catch
    disp 'catch executed'
    %this "catch" section executes in case of an error in the "try" section
    %above.
    ShowCursor;
    Priority(0);
    istatus = fclose('all');
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    clearvars
    clear io64; % for the triggers
    
end %try..catch..
