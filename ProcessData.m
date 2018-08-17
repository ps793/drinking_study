function [rr, flagRRAct] = ProcessData(user, survey, acc, rr, fid)

% configuration
plot_middle_result = false;
save_ctrl_list = false;
remove_activity = true;
flagRRAct=[];      
%   acc=accData(accData(:,1)==i,2:size(accData,2)); preclean=precleanData(precleanData(:,1)==i,2:size(precleanData,2)); rr=rrData(rrData(:,1)==i,2:size(rrData,2));

% sort data
    rr = sortrows(rr,1:6);
    preclean = sortrows(preclean,1:6);
    acc = sortrows(acc,1:6);

% trim RR
    % remove the first x=5 minutes, %and the last 1 minute
    % the last y (y<10) minutes will be dropped through RRGap
    x=5;
    rrDatetimeCtrl = [rr(:,1:5), zeros(size(rr(:,6)))];
    [rrDatetimeUni,IA]=unique(rrDatetimeCtrl,'rows');

    %rr isn't sorted
    rr = rr(IA(x+1):IA(end-1)-1,:);
    rrInitial = rr;
% 
% % low confidence RR in 1 min
%     % conficence below 80, more than 80% of 1 minute, all minute will be removed
%     flagRRLowConf = RRLowConf(user, rr, preclean);
%     
%     %screening
%     rr = rr(flagRRLowConf==1,:);
%     
% % remove extreme values 40~200 bpm = 1500~300ms
%     flagRRExtreme = RRExtremeValue(user, rr);
%     
%     %screening
%     rr = rr(flagRRExtreme==1, :);
%     
% % remove outliers, with 10s moving window mean and 2*std
%     
%     [flagRROutlier,rrMeanIn1m,rrStdIn1m] = RRScreen1m(user, rr);
%     
%     %screening
%     rr = rr(flagRROutlier==1, :);
%     
% % not enough data in 1 min
%     flagRRTooFew = RRTooFew(user, rr);
% 
%     %screening
%     rr = rr(flagRRTooFew==1, :);
%     
% % affected by activity by 1 min window
%     [flagRRAct,accDatetimeUni,accStdIn10s] = RRAct(user, rr, acc);
%     
%     %not screening but marking
%     if(remove_activity);
%     rr = rr(flagRRAct==0, :); % label 1 means under activity, 0 means stationary. need to be reversed
%     end

% remove gap, within y=10 mins window data points less than y*z points,
    % z=50

    % on post process
    %[rrDatetimeList, rrGapFlag] = RRGap(user, rr); %1 is valid, 0 is remvoed
    
% label with drinking
    % on post process


%% summary
% plot
    if(plot_middle_result);
        RRPlot(user, survey, rrInitial, flagRRLowConf,flagRRExtreme,flagRROutlier,rrMeanIn1m,rrStdIn1m,flagRRTooFew, flagRRAct,accDatetimeUni,accStdIn10s);
    end
    
% write ctrlList to file
    %
    if(save_ctrl_list)
        %RRSummary(user, survey, rr, rrInitial, fid);
    end
    
% get summary
    %summary = '';
    %RRSummary2(user, survey, rr, rrInitial, fid);
    
    
%%
%     dateTimePreclean = preclean(:,1:6);
%     lowHRconfidence = preclean(:,8);
%     lowHRflag = zeros(length(lowHRconfidence),1);
%     lowHRflag(lowHRconfidence>=80)=1;
%     
%     dateTimeRR=rr(:,1:6);
%     rr=rr(:,7);
% 
%     flag=(rr==0);
%     dateTimeRR(flag,:)=[];
%     rr(flag)=[];
% 
%     figure;
%     plot(datenum(dateTimeRR), rr,'.');
%     datetick('x',15);
% 
%     %1min window
%     dateTimeRRIn1m=[dateTimeRR(:,1:5),zeros(size(dateTimeRR(:,6)))];
% 
%     [dateTimeRRIn1m,IA]=unique(dateTimeRRIn1m,'rows');
%     rrMeanIn1m = zeros(length(IA),1);
%     rrStdIn1m = zeros(length(IA),1);
% 
%     for i = 2:length(IA)
%         rrMeanIn1m(i-1) = mean(rr(IA(i-1):IA(i)-1));
%         rrStdIn1m(i-1) = std(rr(IA(i-1):IA(i)-1));
%     end
% 
%     hold on;
%     plot(datenum(dateTimeRRIn1m),rrMeanIn1m,'r.');
% 
%     plot(datenum(dateTimeRRIn1m),rrMeanIn1m+2*rrStdIn1m,'g.');
%     plot(datenum(dateTimeRRIn1m),rrMeanIn1m-2*rrStdIn1m,'g.');
% 
%     plot(datenum(dateTimeRRIn1m), rrStdIn1m);
%     
%     plot(datenum(dateTimePreclean), lowHRflag*2000);
%     
%     datetick('x',15);
    
    
end