clear;
clc;

tic;
%input video, and initialize
global facecnt;
global nosecnt;
facecnt = zeros(100, 1);
nosecnt = zeros(100, 1);
facethr = 0;
nosethr = 0;

hVideoSrc           = VideoReader('input5.avi');
nFrames             = hVideoSrc.NumberOfFrames;
H                   = hVideoSrc.height;
W                   = hVideoSrc.width;
Rate                = hVideoSrc.framerate;
video(1:nFrames)	= struct('cdata',zeros(H,W,3,'uint8'), 'after',zeros(H,W),...
    'ans',zeros(H,W,3,'uint8'));

% video = faceTracking(video, hVideoSrc);

fail = [];
[video, fail]	= videoStabilization(video, hVideoSrc, fail);


createNewVideo;

clc;
disp('Complete.');
toc;

sum = 0;
for i=1 : 100
    sum = sum+facecnt(i);
    facethr = facethr+i*facecnt(i);
end
facethr = facethr/sum;

sum = 0;
for i=1 : 100
    sum = sum+nosecnt(i);
    nosethr = nosethr+i*nosecnt(i);
end
nosethr = nosethr/sum;
