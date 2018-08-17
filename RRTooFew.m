function mergeSet = RRTooFew(user, rr)
% this function is to remove 1 minute's data which is less than 50 points
% allign too few flag with 1min window
    rrDatetimeCtrl=[rr(:,1:5),zeros(size(rr(:,6)))];
    
    [rrDatetimeUni,IA]=unique(rrDatetimeCtrl,'rows');
    rrTooFew = zeros(length(IA),1);
    if(isempty(IA));
        mergeSet = rrTooFew;
        return;
    end
    
    thres = 50;

    for i = 1:length(IA)-1
        rrTooFew(i) = length(rr(IA(i):IA(i+1)-1)) > thres;
    end
    rrTooFew(end) = length(rr(IA(end):end,:)) > thres;

% allign flag with rr
    tableA=dataset(rrDatetimeUni,rrTooFew,'VarNames',{'datetime','flags'});
    tableB=dataset(rrDatetimeCtrl,'VarNames',{'datetime'});

    mergeSet = join(tableB,tableA,'Key',{'datetime'},'Type','left','MergeKeys',true);
    mergeSet=dataset2cell(mergeSet);
    mergeSet(1,:)=[];
    mergeSet = cell2mat(mergeSet(:,2));
    mergeSet(isnan(mergeSet))=0;

% plot
%     figure;
%     plot(datenum(rr(mergeSet==1,1:6)),rr(mergeSet==1,7),'.');
%     hold on;
%     plot(datenum(rr(mergeSet==0,1:6)),rr(mergeSet==0,7),'rx');
    
end