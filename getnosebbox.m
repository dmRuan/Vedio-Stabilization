function bbox = getnosebbox(img, facebbox)

global nosecnt;

thr     = 12;
bbox	= [];
nbbox	= size(bbox, 1);

ii = 0;
while( nbbox ~= 1 )
    noseDetector = vision.CascadeObjectDetector('Nose', 'MergeThreshold',thr);
    bbox = step(noseDetector, img);
    nbbox = size(bbox, 1);
    X = ['*', num2str(thr), num2str(size(bbox,1))];
    disp(X);
    if( nbbox > 1 )         
        thr = thr+1;
    elseif( nbbox == 0 )	
        thr = thr-1;
    end
    
    if( ii > 50 && nbbox > 1 )
        break;
    end 
    ii = ii+1;
end

nosecnt(thr) = nosecnt(thr)+1;

if( nbbox > 1 )
    n = size(bbox, 1);
    for i=1 : n
        if( bbox(i,1) > facebbox(1) && bbox(i,2) > facebbox(2) && ...
                bbox(i,3) < facebbox(3) && bbox(i,4) < facebbox(4) )
            bbox = bbox(i, :);
%             disp('hi');
            break;
        end
    end
end
