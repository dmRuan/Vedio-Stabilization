function img = pullNoseMid(img, facebbox)

global nosex;
global nosey;

dim = length(size(img));

W = size(img, 1); H = size(img, 2);

if( dim == 2 )
%     faceimg     = imcrop(img, facebbox);
    nosebbox	= getnosebbox(img, facebbox);
    nosex = nosex+nosebbox(1,3)/350;
    nosey = nosey+nosebbox(1,4)/350;
    p           = [W/2, H/2];
    % q           = [facebbox(2)+nosebbox(1,2)+nosebbox(1,4)/2,...
    %                facebbox(1)+nosebbox(1,1)+nosebbox(1,3)/2];
    q = [nosebbox(2)+nosebbox(4)/2, nosebbox(1)+nosebbox(3)/2];
    y = p(1)-q(1)-nosebbox(1,4)*0.172;
    x = p(2)-q(2)-nosebbox(1,3)/33;
    se          = translate(strel(1), floor([y x]));
    img         = imdilate(img, se);

elseif( dim == 3 )
    nosebbox	= getnosebbox(img(:,:,2), facebbox);
    p           = [W/2, H/2];
    q = [nosebbox(2)+nosebbox(4)/2, nosebbox(1)+nosebbox(3)/2];
    y = p(1)-q(1)-nosebbox(1,4)*0.172;
    x = p(2)-q(2)-nosebbox(1,3)/33;
    se          = translate(strel(1), floor([y x]));
    img(:,:,1)	= imdilate(img(:,:,1), se);
    img(:,:,2)	= imdilate(img(:,:,2), se);
    img(:,:,3)	= imdilate(img(:,:,3), se);
end
