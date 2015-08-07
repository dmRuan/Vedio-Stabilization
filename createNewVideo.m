outputVideo	= VideoWriter('C:\Users\Mindi\Desktop\Image Stabilization\stable_video12(2).avi');
outputVideo.FrameRate = Rate;
open(outputVideo)

for i=1 : nFrames
    clc;
    disp('Loading...')
    writeVideo(outputVideo, video(i).ans);
end

close(outputVideo)