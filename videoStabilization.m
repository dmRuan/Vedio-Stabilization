function [v, fail] = videoStabilization(v, hVideoSrc, fail)

% initialization
bboxA = []; bboxB = [];
nFrames         = hVideoSrc.NumberOfFrames;
% faceDetector	= vision.CascadeObjectDetector('MergeThreshold', 5);
% noseDetector    = vision.CascadeObjectDetector('Nose');

% initialize the first frame
v(1).cdata  = read(hVideoSrc, 1);
imgB        = rgb2gray(v(1).cdata);

% translate
facebbox = getfacebbox(imgB);
imgB = pullNoseMid(imgB, facebbox);

v(1).after  = imgB;
v(1).ans    = v(1).cdata;
imgA        = imgB;

% show time
cnt = 0;
for i=2 : nFrames
    dispSchedule(i, nFrames);
    
    v(i).cdata	= read(hVideoSrc, i);
    imgB        = rgb2gray(v(i).cdata);
    
    % display
%     figure; imshowpair(imgA, imgB, 'montage');
%     title(['Frame A', repmat(' ',[1 70]), 'Frame B']);

    
    %%%%%%%%%%%% collect salient points from each frame %%%%%%%%%%%%
    % Detect feature points in the face region.
    bboxA = getfacebbox(imgA, bboxB);
    bboxB = getfacebbox(imgB, bboxA);
%     bboxA	= step(faceDetector, imgA);
%     bboxB	= step(faceDetector, imgB);
    
%     nbboxA	= size(bboxA, 1);
%     nbboxB	= size(bboxB, 1);
    pointsA = [];
    pointsB = [];
%     for ii=1 : nbboxA
%         for jj=1 : nbboxB            
            pointsA	= detectMinEigenFeatures(imgA, 'ROI', bboxA, 'MinQuality', 0.0001);
            pointsB	= detectMinEigenFeatures(imgB, 'ROI', bboxB, 'MinQuality', 0.0001);
            % Display the detected points.
        %         figure, imshow(imgA), hold on, title('A');
        %         plot(pointsA);    
        %         figure, imshow(imgB), hold on, title('B');
        %         plot(pointsB);    



            %%%%%%%%%%%% select correspondences between points %%%%%%%%%%%%
            % Extract FREAK descriptors for the corners
            [featuresA, pointsA]	= extractFeatures(imgA, pointsA);
            [featuresB, pointsB]	= extractFeatures(imgB, pointsB);

            indexPairs	= matchFeatures(featuresA, featuresB, 'MaxRatio',0.7);
            pointsA     = pointsA(indexPairs(:, 1), :);
            pointsB     = pointsB(indexPairs(:, 2), :);

%             if( size(pointsA, 1) > size(pointsA, 1) )
%                 faceid = jj;
%                 pointsA	= pointsA;
%                 pointsB = pointsB;
%             end
%         end
%     end
    % display
%     figure; showMatchedFeatures(imgA, imgB, tpointsA, tpointsB); hold on;
%     title('Before');
%     legend('A', 'B');


    if( size(pointsA,1) >= 3 )
        %%%%%%%%%%%% estimating transform from noisy correspondences %%%%%%%%%%%%
        [tform, pointsBm, pointsAm] = estimateGeometricTransform(...
            pointsB, pointsA, 'affine');
%         imgBp       = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
%         pointsBmp	= transformPointsForward(tform, pointsBm.Location);

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

%         imgBold	= imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
        imgBsRt = imwarp(imgB, tformsRT, 'OutputView', imref2d(size(imgB)));
        imgBsRt = pullNoseMid(imgBsRt, bboxB);
        
        imgsRt      = imwarp(v(i).cdata, tformsRT, 'OutputView', imref2d(size(v(i).cdata)));
        v(i).ans	= pullNoseMid(imgsRt, bboxB);
%         v(i).ans(:,:,2)	= pullNoseMid(imgsRt(:,:,2), bboxB);
%         v(i).ans(:,:,3)	= pullNoseMid(imgsRt(:,:,3), bboxB);

        % display
%         figure(2), clf;
%         imshowpair(imgBold,imgBsRt,'ColorChannels','red-cyan'), axis image;
%         title('After');

%         imgBsRt     = pullNoseMid(imgBsRt, faceDetector, noseDetector);
        v(i).after	= imgBsRt;
    else
        cnt = cnt+1;
        fail(cnt) = i;
        imgB	= pullNoseMid(imgB, bboxB);
        v(i).after	= imgB;
        v(i).ans = imgB;
    end
    
    imgA	= v(i).after;
    
%     close all;
end

