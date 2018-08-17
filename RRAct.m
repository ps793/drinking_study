function [mergeSet ,accDatetimeUni,accStdIn10s] = RRAct(user, rr, acc)
% this function is to remove activity effection on rr interval; resp also
% use this function to remove activity effection
% in 10s window, calculate acc std
    if(size(acc,2)==7) %hexoskin
        stdThres = 0.035;
        actThres = 2; % out of 6
        accMag = acc(:,7); 
    else
        stdThres = 35;
        actThres = 2; % out of 6
        accMag = (acc(:,7).^2 + acc(:,8).^2 + acc(:,9).^2).^0.5;
    end
    
    accDatetimeCtrl = [acc(:,1:5),fix(acc(:,6)./10).*10];

    [accDatetimeUni,IA] = unique(accDatetimeCtrl,'rows');
    accStdIn10s = zeros(length(IA),1);

    for i = 1:length(IA)-1
        accStdIn10s(i) = std(accMag(IA(i):IA(i+1)-1));
    end
    accStdIn10s(end) = std(accMag(IA(end):end));

% extreme values
    accStdIn10s(accStdIn10s > 1500) = 0;
    
%     figure;
%     plot(datenum(accDatetimeUni),accStdIn10s,'.');
%     hold on;
%     plot(datenum(accDatetimeUni(accStdIn10s>35,:)),accStdIn10s(accStdIn10s>35),'.');
    
% translate to 1 min window
    accStdDatetimeCtrl = [accDatetimeUni(:,1:5),zeros(size(accDatetimeUni(:,6)))];
    
    [accStdDatetimeUni,IA] = unique(accStdDatetimeCtrl,'rows');
    accStdFlag = zeros(length(IA),1);

    for i = 1:length(IA)-1
        accStdFlag(i) = sum(accStdIn10s(IA(i):IA(i+1)-1)>stdThres) > actThres; % out of 6
    end
    accStdFlag(end) = sum(accStdIn10s(IA(end):end)>stdThres) > actThres;
    
% labeling rr
    rrDatetimeCtrl=[rr(:,1:5),zeros(size(rr(:,6)))];

    tableA=dataset(accStdDatetimeUni,accStdFlag,'VarNames',{'datetime','flags'});
    tableB=dataset(rrDatetimeCtrl,'VarNames',{'datetime'});
    
    mergeSet = join(tableB,tableA,'Key',{'datetime'},'Type','left','MergeKeys',true);
    mergeSet=dataset2cell(mergeSet);
    mergeSet(1,:)=[];
    mergeSet = cell2mat(mergeSet(:,2));
    mergeSet(isnan(mergeSet))=0;

    
% plot
%{
    figure;
    plot(datenum(rr(:,1:6)), rr(:,7),'.');
    hold on;
    plot(datenum(rr(mergeSet==1,1:6)), rr(mergeSet==1,7),'r.');

    plot(datenum(accDatetimeUni),accStdIn10s,'.');
    plot(datenum(accDatetimeUni(accStdIn10s>35,:)),accStdIn10s(accStdIn10s>35),'.');
    
    datetick('x',13);
%}

end