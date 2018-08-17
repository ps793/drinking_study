function resp = ProcessDataResp(user, respStatus, resp, extMin, extMax)

% configuration
plot_middle_result = false;
save_ctrl_list = false;
remove_activity = true;
       
%   acc=accData(accData(:,1)==i,2:size(accData,2)); preclean=precleanData(precleanData(:,1)==i,2:size(precleanData,2)); rr=rrData(rrData(:,1)==i,2:size(rrData,2));

% sort data
    resp = sortrows(resp,1:6);
    respStatus = sortrows(respStatus,1:6);

% trim RR
    % remove the first x=5 minutes, %and the last 1 minute
    % the last y (y<10) minutes will be dropped through RRGap
    x=5;
    rrDatetimeCtrl = [resp(:,1:5), zeros(size(resp(:,6)))];
    [rrDatetimeUni,IA]=unique(rrDatetimeCtrl,'rows');

    %rr isn't sorted
    resp = resp(IA(x+1):IA(end-1)-1,:);
    respInitial = resp;

% low confidence RR in 1 min
    % conficence below 80, more than 80% of 1 minute, all minute will be removed
    flagRespLowConf = RRLowConf(user, resp, respStatus);
    
    %screening
    resp = resp(flagRespLowConf==1,:);
    
% remove extreme values 40~200 bpm = 1500~300ms
    flagRespExtreme = resp(:,7)>=extMin & resp(:,7)<=extMax;
    
    %screening
    resp = resp(flagRespExtreme==1, :);
    
% remove outliers, with 10s moving window mean and 2*std
    
    flagRespOutlier = RRScreen1m(user, resp);
    
    %screening
    resp = resp(flagRespOutlier==1, :);
    
% not enough data in 1 min
    flagRespTooFew = RRTooFew(user, resp);

    %screening
    resp = resp(flagRespTooFew==1, :);
    
% affected by activity by 1 min window
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
        RRPlot(user, survey, rrInitial, flagRRLowConf,flagRRExtreme,flagRROutlier,flagRRTooFew, flagRRAct,accDatetimeUni,accStdIn10s);
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