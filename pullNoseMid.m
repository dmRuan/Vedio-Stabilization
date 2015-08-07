function [img, move] = pullNoseMid(img, facebbox, move)


dim = length(size(img));

W = size(img, 1); H = size(img, 2);

if( dim == 2 )
    if( nargin < 3 )
        nosebbox	= getnosebbox(img, facebbox);
        p           = [W/2, H/2];
        q = [nosebbox(2)+nosebbox(4)/2, nosebbox(1)+nosebbox(3)/2];
        y = p(1)-q(1)-nosebbox(1,4)*0.172;
        x = p(2)-q(2)-nosebbox(1,3)/33;
        move = [y x];
    end
    se          = translate(strel(1), floor(move));
    img         = imdilate(img, se);

elseif( dim == 3 )
    if( nargin < 3 )
        nosebbox	= getnosebbox(img(:,:,2), facebbox);
        p           = [W/2, H/2];
        q = [nosebbox(2)+nosebbox(4)/2, nosebbox(1)+nosebbox(3)/2];
        y = p(1)-q(1)-nosebbox(1,4)*0.172;
        x = p(2)-q(2)-nosebbox(1,3)/33;
        move = [y x];
    end
    se          = translate(strel(1), floor(move));
    img(:,:,1)	= imdilate(img(:,:,1), se);
    img(:,:,2)	= imdilate(img(:,:,2), se);
    img(:,:,3)	= imdilate(img(:,:,3), se);
end
