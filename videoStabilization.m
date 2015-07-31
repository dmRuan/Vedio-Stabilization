function [v, fail] = videoStabilization(v, hVideoSrc, fail)

% initialization
% videoPlayer	= vision.VideoPlayer;
nFrames     = v.nFrames;

% initialize the first frame
v(1).cdata  = read(hVideoSrc, 1);
imgB        = rgb2gray(v(1).cdata);
v(1).after  = imgB;
imgA        = imgB;
% step(videoPlayer, imgB);

% show time
cnt = 1;
n = 271;
faceDetector = vision.CascadeObjectDetector('MergeThreshold', 5);
for i=2 : nFrames
    cnt = cnt+1;
    disp(cnt);
    v(i).cdata	= read(hVideoSrc, i);
    imgB        = rgb2gray(v(i).cdata);
    
    % display
%     figure; imshowpair(imgA, imgB, 'montage');
%     title(['Frame A', repmat(' ',[1 70]), 'Frame B']);

    
    %%%%%%%%%%%% collect salient points from each frame %%%%%%%%%%%%
    % Detect feature points in the face region.
    bboxA	= step(faceDetector, imgA);
    bboxB	= step(faceDetector, imgB);
    
    nbboxA	= size(bboxA, 1);
    nbboxB	= size(bboxB, 1);
    pointsA = [];
    pointsB = [];
    for ii=1 : nbboxA
        for jj=1 : nbboxB            
            tpointsA	= detectMinEigenFeatures(imgA, 'ROI', bboxA(ii, :), 'MinQuality', 0.001);
            tpointsB	= detectMinEigenFeatures(imgB, 'ROI', bboxB(jj, :), 'MinQuality', 0.001);
            % Display the detected points.
        %         figure, imshow(imgA), hold on, title('A');
        %         plot(pointsA);    
        %         figure, imshow(imgB), hold on, title('B');
        %         plot(pointsB);    



            %%%%%%%%%%%% select correspondences between points %%%%%%%%%%%%
            % Extract FREAK descriptors for the corners
            [featuresA, tpointsA]	= extractFeatures(imgA, tpointsA);
            [featuresB, tpointsB]	= extractFeatures(imgB, tpointsB);

            indexPairs	= matchFeatures(featuresA, featuresB);
            tpointsA     = tpointsA(indexPairs(:, 1), :);
            tpointsB     = tpointsB(indexPairs(:, 2), :);

            % display
        %         figure; showMatchedFeatures(imgA, imgB, pointsA, pointsB); hold on;
        %         title('Before');
        %         legend('A', 'B');
            if( size(tpointsA, 1) > size(pointsA, 1) )
                pointsA	= tpointsA;
                pointsB = tpointsB;
            end
        end
    end


    if( size(pointsA, 1) == size(pointsB,1) && size(pointsA, 1) >= 3)
        %%%%%%%%%%%% estimating transform from noisy correspondences %%%%%%%%%%%%
        [tform, pointsBm, pointsAm] = estimateGeometricTransform(...
            pointsB, pointsA, 'affine');
        imgBp       = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
        pointsBmp	= transformPointsForward(tform, pointsBm.Location);

        % display
%         figure;
%         showMatchedFeatures(imgA, imgBp, pointsAm, pointsBmp);
%         legend('A', 'B');



        %%%%%%%%%%%% transform approximation and smoothing %%%%%%%%%%%%
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

        imgBold	= imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
        imgBsRt = imwarp(imgB, tformsRT, 'OutputView', imref2d(size(imgB)));

        % display
%         figure(2), clf;
%         imshowpair(imgBold,imgBsRt,'ColorChannels','red-cyan'), axis image;
%         title('After');

        v(i).after	= imgBsRt;
%         step(videoPlayer, imgBsRt);
    else
        v(i).after	= imgB;
%         step(videoPlayer, imgB);
    end
    
    imgA	= v(i).after;
    
%     close all;
end

% release(videoPlayer);