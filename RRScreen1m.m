function [flagRROutlier,rrMeanIn1m,rrStdIn1m]= RRScreen1m(user, rr)
% this function is to remove outlier in one minute window
%1min window
    rrDatetimeCtrl=[rr(:,1:5),zeros(size(rr(:,6)))];

    [rrDatetimeUni,IA]=unique(rrDatetimeCtrl,'rows');
    rrMeanIn1m = zeros(length(IA),1);
    rrStdIn1m = zeros(length(IA),1);
    flagRROutlier = ones(length(rrDatetimeCtrl),1);
    if(isempty(IA)); return; end

    for i = 1:length(IA)-1
        rrIn1m = rr(IA(i):IA(i+1)-1,7);
        rrMeanIn1m(i) = mean(rrIn1m);
        rrStdIn1m(i) = std(rrIn1m);
        flagRROutlier(IA(i):IA(i+1)-1) = ...
            rrIn1m>=rrMeanIn1m(i)-2*rrStdIn1m(i) ...
            & rrIn1m<=rrMeanIn1m(i)+2*rrStdIn1m(i);
    end
    rrIn1m = rr(IA(end):end,7);
    rrMeanIn1m(end) = mean(rrIn1m);
    rrStdIn1m(end) = std(rrIn1m);
    flagRROutlier(IA(end):end) = ...
        rrIn1m>=rrMeanIn1m(end)-2*rrStdIn1m(end) ...
        & rrIn1m<=rrMeanIn1m(end)+2*rrStdIn1m(end);
    

% % plot outliers
% figure;
% plot(datenum(rr(:,1:6)),rr(:,7),'.');
% hold on;
% plot(datenum(rr(flagRROutlier==0,1:6)),rr(flagRROutlier==0,7),'rx')
% plot(datenum(rrDatetimeUni),rrMeanIn1m,'r.');
% 
% plot(datenum(rrDatetimeUni),rrMeanIn1m+2*rrStdIn1m,'g.');
% plot(datenum(rrDatetimeUni),rrMeanIn1m-2*rrStdIn1m,'g.');
% 
% plot(datenum(rrDatetimeUni), rrStdIn1m);
% datetick('x',13);

end