# PhD EnhancementStudy ExperimentScript

## Main_Script.m
This is the expreimental script for a recognition paradigm that takes _new_ (unseen by participant) and _old_ (unseen by participant) photos and presents them to the participant. The experiment asks participants to respond using a response box (Cedrus) on whether or not they remember the photo and also how confident they are in their judgment. 

It sends triggers to the EEG amplifier for when the photos are shown, the participants provides memory judgment, and the confidence judgment. The triggers contain information about the type of photo shown (whether new or old) and the type of memory and confidence judgment. 

## Rename.m
Renames the photos so that the experimental script can pick them. 
Photos are renamed inside the Rename folder. 

## QuickSum.m
Summarises participants responses. It's used in the end of the Main_Script to provide a quick summary of the responses. 

## GetParticipantsInfo.m
Asks participants for demographic information
