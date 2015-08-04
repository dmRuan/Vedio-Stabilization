function bbox = getfacebbox(img, oldbbox)

global facecnt;

disp('face detection');

thr     = 4;
bbox	= [];
nbbox	= size(bbox, 1);
eyeDetector	= vision.CascadeObjectDetector('EyePairBig');

ii = 0;
while( nbbox ~= 1 )
    faceDetector = vision.CascadeObjectDetector('MergeThreshold',thr);
    bbox = step(faceDetector, img);
    nbbox = size(bbox, 1);
    if( nbbox > 1 )         
        thr = thr+1;
    elseif( nbbox == 0 )	
        thr = thr-1;
    end
    
    if( ii > 50 && nbbox > 1 )
        break;
    end
    if( thr < 0)     
        break;
    end;
    ii = ii+1;
    if( nbbox == 1 ) facecnt(thr) = facecnt(thr)+1; end
    X = [num2str(thr), num2str(size(bbox,1))];
    disp(X);
end

if( nbbox < 1 )
    facecnt(thr) = facecnt(thr)+1;
    bbox = oldbbox;  
elseif( nbbox > 1 )
    n = nbbox;
    for i=1 : n
        I = imcrop(img, bbox(i,:));
        eyebbox = step(eyeDetector, I);
        if( size(eyebbox,1) == 1 )
            bbox = bbox(i,:);
            break;
        end
    end
end

disp('complete face detection');