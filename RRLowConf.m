function mergeSet = RRLowConf(user, rr, preclean)
% this function is to remove low confidence value according to the preclean
% allign RR in 1min window
%     % with 1 min interval and for the following flags
%     rrDatetimeStart = [rr(1,1:5), 0];
%     rrDatetimeEnd = [rr(end,1:5), 0];
%     
%     datevec1Min = [0,0,0,0,1,0];
%     rrDatetimeList = datevec([datenum(rrDatetimeStart):datenum(datevec1Min):datenum(rrDatetimeEnd)]');
    
    
% allign low confidence in 1min window
    if(sum(preclean(:,7)==1)==0)
        flag = preclean(:,8)==0;
    else
        flag = preclean(:,8)>80;
    end
    precleanDatetimeCtrl=[preclean(:,1:5),zeros(size(preclean(:,6)))];
    
    [precleanDatetimeUni,IA]=unique(precleanDatetimeCtrl,'rows');
    precleanLowConf = zeros(length(IA),1);
    
    for i = 1:length(IA)-1
        % could be percertage of the total number of 1 min
        precleanLowConf(i) = sum(flag(IA(i):IA(i+1)-1)) / length(flag(IA(i):IA(i+1)-1)) > 0.8;
    end
    % very end line modify here
    precleanLowConf(end) = sum(flag(IA(end):end)) / length(flag(IA(end):end)) > 0.8;


% allign low confidence with rr
    rrDatetimeCtrl=[rr(:,1:5),zeros(size(rr(:,6)))];

    tableA=dataset(precleanDatetimeUni,precleanLowConf,'VarNames',{'datetime','flags'});
    tableB=dataset(rrDatetimeCtrl,'VarNames',{'datetime'});
    
    mergeSet = join(tableB,tableA,'Key',{'datetime'},'Type','left','MergeKeys',true);
    mergeSet=dataset2cell(mergeSet);
    mergeSet(1,:)=[];
    mergeSet = cell2mat(mergeSet(:,2));
    mergeSet(isnan(mergeSet))=0;

% plot or show current screening
%     percent = sum(precleanLowConf==0)/length(precleanLowConf);
% 
%     figure;
%     plot(datenum(rr(:,1:6)), rr(:,7),'.');
%     hold on;
%     plot(datenum(precleanDatetimeUni(:,1:6)), precleanLowConf*200,'*');
%     datetick('x',15);
% 
%     title(strcat(user, {' RR Int. : '},num2str(round(percent*100,2)), {'% with LOW confidence'}));
%     xlabel(strcat({'Date '},datestr(precleanDatetimeUni(1,1:6),'mm/dd/yyyy'),{' Time'}));ylabel('Confidence(in Red) and RR Int.(ms)');

end