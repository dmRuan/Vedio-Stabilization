function facebbox = getfacebbox(img, thr, lower, upper, oldbbox)


facebbox	= [];
nfacebbox	= size(facebbox, 1);

eyeDetector     = vision.CascadeObjectDetector('EyePairBig');
mouthDetector   = vision.CascadeObjectDetector('Mouth');
noseDetector    = vision.CascadeObjectDetector('Nose');

while( thr >= 0 )
    faceDetector	= vision.CascadeObjectDetector('MergeThreshold',thr);
    facebbox        = step(faceDetector, img);
    
    nfacebbox	= size(facebbox, 1);
    X = [num2str(thr), ' ', num2str(nfacebbox)];
    disp(X);
    if( nfacebbox < lower )
        thr = thr-1;
    elseif( nfacebbox > upper )
        thr = thr+1;
    else
        break;
    end   
end

if( nfacebbox == 1 )
    A	= imcrop(img, facebbox);
    
    eyebbox     = step(eyeDetector, A);
    mouthbbox	= step(mouthDetector, A);
    nosebbox    = step(noseDetector, A);
    
    neyebbox    = size(eyebbox, 1);
    nmouthbbox  = size(mouthbbox, 1);
    nnosebbox   = size(nosebbox, 1);
    
    if( ~neyebbox && ~nmouthbbox && ~nnosebbox )
        faceDetector    = vision.CascadeObjectDetector('MergeThreshold',thr-1);
        facebbox    = step(faceDetector, img);
    end
end


test = facebbox;

cnt	= zeros(nfacebbox);
for k=1 : nfacebbox
    I	= imcrop(img, facebbox(k,:));
    
    eyebbox     = step(eyeDetector, I);
    mouthbbox	= step(mouthDetector, I);
    nosebbox    = step(noseDetector, I);
    
    neyebbox    = size(eyebbox, 1);
    nmouthbbox  = size(mouthbbox, 1);
    nnosebbox   = size(nosebbox, 1);
    
    if( neyebbox )  cnt(k) = cnt(k)+1; end
    if( nmouthbbox )    cnt(k) = cnt(k)+1; end
    if( nnosebbox ) cnt(k) = cnt(k)+1; end
end

[ii, ~]	= find(cnt == max(max(cnt)));
if( size(ii,1) == 1 )
    facebbox	= facebbox(ii, :);
else
    disp('hi');
    facebbox    = oldbbox;
end



