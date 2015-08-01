function v = videoStabilization(v, hVideoSrc)

% initialization
nFrames         = hVideoSrc.NumberOfFrames;
W               = hVideoSrc.height;
H               = hVideoSrc.width;
faceDetector	= vision.CascadeObjectDetector('MergeThreshold', 5);
noseDetector    = vision.CascadeObjectDetector('Nose');

% initialize the first frame
v(1).cdata  = read(hVideoSrc, 1);
imgB        = rgb2gray(v(1).cdata);

% translate
nosebbox	= step(noseDetector, imgB);
p           = [W/2, H/2];
q           = [nosebbox(1, 2)+nosebbox(1,4)/2, nosebbox(1,1)+nosebbox(1,3)/2];
y = p(1)-q(1);
x = p(2)-q(2);
se          = translate(strel(1), floor([y x]));
imgB        = imdilate(imgB, se);
fig = figure; imshow(imgB); hold on;
% plot(p(1), p(2), '+');
% [x, y] = getpts(fig);

v(1).after  = imgB;
v(1).ans    = v(1).cdata;
imgA        = imgB;

% show time
cnt = 1;
n = 271;
for i=2 : nFrames
    cnt     = cnt+1;
    ratio	= uint8((cnt/nFrames)*100);
    clc;
    X       = [num2str(ratio), '%'];
    disp(X);
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
            tpointsA	= detectMinEigenFeatures(imgA, 'ROI', bboxA(ii, :), 'MinQuality', 0.0001);
            tpointsB	= detectMinEigenFeatures(imgB, 'ROI', bboxB(jj, :), 'MinQuality', 0.0001);
            % Display the detected points.
        %         figure, imshow(imgA), hold on, title('A');
        %         plot(pointsA);    
        %         figure, imshow(imgB), hold on, title('B');
        %         plot(pointsB);    



            %%%%%%%%%%%% select correspondences between points %%%%%%%%%%%%
            % Extract FREAK descriptors for the corners
            [featuresA, tpointsA]	= extractFeatures(imgA, tpointsA);
            [featuresB, tpointsB]	= extractFeatures(imgB, tpointsB);

            indexPairs	= matchFeatures(featuresA, featuresB, 'MaxRatio',0.7);
            tpointsA     = tpointsA(indexPairs(:, 1), :);
            tpointsB     = tpointsB(indexPairs(:, 2), :);

            if( size(tpointsA, 1) > size(pointsA, 1) )
                pointsA	= tpointsA;
                pointsB = tpointsB;
            end
        end
    end
    % display
%     figure; showMatchedFeatures(imgA, imgB, tpointsA, tpointsB); hold on;
%     title('Before');
%     legend('A', 'B');


    if( size(pointsA, 1) == size(pointsB,1) && size(pointsA, 1) >= 3)
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
        v(i).ans = imwarp(v(i).cdata, tformsRT, 'OutputView', imref2d(size(v(i).cdata)));

        % display
%         figure(2), clf;
%         imshowpair(imgBold,imgBsRt,'ColorChannels','red-cyan'), axis image;
%         title('After');

        v(i).after	= imgBsRt;
    else
        v(i).after	= imgB;
    end
    
    imgA	= v(i).after;
    
    close all;
end

