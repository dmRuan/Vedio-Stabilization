function dispSchedule(ii, sum)

clc;
ii      = ii+1;
ratio	= uint8((ii/sum)*100);
X       = [num2str(ratio), '%'];
disp(X);

