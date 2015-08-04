% videoPlayer1	= vision.VideoPlayer;
% videoPlayer2	= vision.VideoPlayer;
% n = video.nFrames;
% cnt2 = 0;
% cnt1 = 0;
% cnt0 = 0;
% for i=1 : n    
%     for j=1 : 15000000 
%     end
%     step(videoPlayer1, video(i).after);
% %     step(videoPlayer2, video(i).cdata);
% end
% 
% release(videoPlayer1);
% release(videoPlayer2);


% nFrames = video.nFrames;
% noseatmid = zeros(nFrames, 2);
% for i=1 : nFrames
%     disp(i);
%     videoFrame = video(i).after;
%     fig = figure;
%     imshow(videoFrame); title('Detected face'); hold on;
%     set(gcf,'Position',[400,100,1600,800],'color','w');
%     [noseatmid(i,1), noseatmid(i,2)] = getpts(fig);
%     close all;
% end

% nFrames = video.nFrames;
% faceDetector = vision.CascadeObjectDetector('MergeThreshold', 5);
% eyeDetector = vision.CascadeObjectDetector('EyePairBig');
% noseDetector = vision.CascadeObjectDetector('Nose', 'MergeThreshold',50);
% mouthDetector = vision.CascadeObjectDetector('Mouth');
% 
% for i=250 : nFrames
%     %     disp(i);
%     bbox = step(faceDetector, video(i).cdata);
%     faceimg = imcrop(video(i).cdata, bbox(end,:));
%     
%     nosebbox = step(noseDetector, faceimg);
%     
%     videoFrame = rgb2gray(video(i).cdata);
%     videoFrame = insertShape(videoFrame, 'Rectangle', nosebbox);
%     img = reshape(videoFrame(:, :, 1), H, W);
%     
% %     points	= detectMinEigenFeatures(img, 'ROI',bbox(end, :), 'MinQuality',0.005);
%     
% %     points.Location(:, 1) = points.Location(:, 1)+bbox(1);
% %     points.Location(:, 2) = points.Location(:, 2)+bbox(2);
%     % Display the detected points.
%     figure, imshow(img), hold on;
% %     plot(points);    
%     close all;
% end

% faceDetector = vision.CascadeObjectDetector('MergeThreshold', 5);
% noseDetector = vision.CascadeObjectDetector('Nose');
% pointA = [W/2, H/2];
% 
% se = translate(strel(1), [25 25]);
% J = imdilate(video(1).cdata, se);
% imshow(J);

% n = video.nFrames;
% for i=1 : n
%     img = video(i).cdata;
%     facebbox = step(faceDetector, img);
%     faceimg = imcrop(img, facebbox);
%     bbox = step(noseDetector, faceimg);
%     
%     img = insertShape(img, 'Rectangle', bbox(1, :));
%     
%     pointB = [bbox(1, 1)+bbox(1, 3)/2, bbox(1, 2)+bbox(1, 4)/2];
%     point(1, 1) = uint8(pointA(1)-(pointB(1, 1) + facebbox(1)));
%     point(1, 2) = uint8(pointA(1)-(pointB(1, 2) + facebbox(2)));
%     
%     img = translate(strel(1), double(point));
%     imshow(img); hold on;
%     
% end