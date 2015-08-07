function v = videoStabilization(v, hVideoSrc)

%% initialization
lowerFaceThr	= 1;
upperFaceThr    = 10;
startThr        = 4;
bboxB = [];
nFrames         = hVideoSrc.NumberOfFrames;

% initialize the first frame
v(1).cdata  = read(hVideoSrc, 1);
imgB        = rgb2gray(v(1).cdata);
% translate the image
facebbox	= getfacebbox(imgB, startThr, lowerFaceThr, upperFaceThr);
imgB        = pullNoseMid(imgB, facebbox);
% for iteration
imgA	= imgB;

v(1).ans	= pullNoseMid(v(1).cdata, facebbox);


%% show time
for i=2 : nFrames
    dispSchedule(i, nFrames);
    disp(i);
    
    v(i).cdata	= read(hVideoSrc, i);
    imgB        = rgb2gray(v(i).cdata);
    
%     display
%     figure; imshowpair(imgA, imgB, 'montage');
%     title(['Frame A', repmat(' ',[1 70]), 'Frame B']);

    
%% collect salient points from each frame
    % Detect feature points in the face region.
    bboxA = getfacebbox(imgA, startThr, lowerFaceThr, upperFaceThr, bboxB);
    bboxB = getfacebbox(imgB, startThr, lowerFaceThr, upperFaceThr, bboxB);
    
    pointsA	= detectMinEigenFeatures(imgA, 'ROI', bboxA, 'MinQuality', 0.0001);
    pointsB	= detectMinEigenFeatures(imgB, 'ROI', bboxB, 'MinQuality', 0.0001);
%     Display the detected points.
%         figure, imshow(imgA), hold on, title('A');
%         plot(pointsA);    
%         figure, imshow(imgB), hold on, title('B');
%         plot(pointsB);    



%% select correspondences between points
    % Extract FREAK descriptors for the corners
    [featuresA, pointsA]	= extractFeatures(imgA, pointsA);
    [featuresB, pointsB]	= extractFeatures(imgB, pointsB);

    indexPairs	= matchFeatures(featuresA, featuresB, 'MaxRatio',0.7);
    pointsA     = pointsA(indexPairs(:, 1), :);
    pointsB     = pointsB(indexPairs(:, 2), :);

%     display
%     figure; showMatchedFeatures(imgA, imgB, tpointsA, tpointsB); hold on;
%     title('Before');
%     legend('A', 'B');


%% estimating transform from noisy correspondences
    if( size(pointsA,1) >= 3 )
        [tform, pointsBm, pointsAm] = estimateGeometricTransform(...
            pointsB, pointsA, 'affine');
%         imgBp       = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
%         pointsBmp	= transformPointsForward(tform, pointsBm.Location);

%         display
%         figure;
%         showMatchedFeatures(imgA, imgBp, pointsAm, pointsBmp);
%         legend('A', 'B');



%% transform approximation and smoothing
        % Extract scale and rotation part sub-matrix.
        H	= tform.T;
        R	= H(1:2,1:2);
        % Compute theta from mean of two possible arctangents
        theta	= mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
        % Compute scale from mean of two stable mean calculations
        scale	= mean(R([1 4])/cos(theta));
        % Translation remains the same:
        translation	= H(3, 1:2);
        % Reconstitute new s-R-t transform:
        HsRt	= [[scale*[cos(theta) -sin(theta); sin(theta) cos(theta)]; ...
          translation], [0 0 1]'];
        tformsRT	= affine2d(HsRt);

%         imgBold	= imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
        imgBsRt = imwarp(imgB, tformsRT, 'OutputView', imref2d(size(imgB)));
        [imgBsRt, move] = pullNoseMid(imgBsRt, bboxB);
        
        imgsRt      = imwarp(v(i).cdata, tformsRT, 'OutputView', imref2d(size(v(i).cdata)));
        [v(i).ans, ~]	= pullNoseMid(imgsRt, bboxB, move);

%         display
%         figure(2), clf;
%         imshowpair(imgBold,imgBsRt,'ColorChannels','red-cyan'), axis image;
%         title('After');

        after	= imgBsRt;
    else        
        [imgB, move]        = pullNoseMid(imgB, bboxB);
        after               = imgB;
        [v(i).ans, move]	= pullNoseMid(v(i).ans, bboxB, move);
    end
    
    imgA	= after;
    
%     close all;
end

