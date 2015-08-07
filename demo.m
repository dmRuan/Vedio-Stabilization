clear;
clc;

tic;

hVideoSrc           = VideoReader('input12.avi');
nFrames             = hVideoSrc.NumberOfFrames;
H                   = hVideoSrc.height;
W                   = hVideoSrc.width;
Rate                = hVideoSrc.framerate;
video(1:nFrames)	= struct('cdata',zeros(H,W,3,'uint8'), 'ans',zeros(H,W,3,'uint8'));


video	= videoStabilization(video, hVideoSrc);


createNewVideo;

clc;
disp('Complete.');

toc;