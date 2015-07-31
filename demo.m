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
    'facebbox',zeros(1,4), 'nFrames', nFrames,...
    'after',zeros(H,W));

for i=1 : nFrames
    video(i).facebbox(3)	= W;
    video(i).facebbox(4)	= H;
end

% video = faceTracking(video, hVideoSrc);

[video, fial]	= videoStabilization(video, hVideoSrc, fail);