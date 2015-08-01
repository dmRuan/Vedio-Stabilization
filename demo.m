clear;
clc;

%input video, and initialize
fail                = 0;
hVideoSrc           = VideoReader('input4.avi');
nFrames             = hVideoSrc.numberofframes;
H                   = hVideoSrc.height;
W                   = hVideoSrc.width;
Rate                = hVideoSrc.framerate;
video(1:nFrames)	= struct('cdata',zeros(H,W,3,'uint8'),...
    'nFrames', nFrames, 'after',zeros(H,W),...
    'ans',zeros(H,W,3,'uint8'));

% video = faceTracking(video, hVideoSrc);

video	= videoStabilization(video, hVideoSrc);

createNewVideo;

clc;
disp('Complete.')