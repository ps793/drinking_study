function rrClean = SplitDate(user, survey, ctrlList, acc, rr, fid)
% this function is to split .mat files by day for each user id
%     user = user, survey, ctrlList, accData, rrData, fid;
%     acc = accData;
%     preclean = precleanData;
%     rr = rrData;

% constants
WHITE_LIST = true; BLACK_LIST = false;

% configuration
ctrl_list_fun = WHITE_LIST;
    
%
    [days, IA] = unique(rr(:,1));
    disp(strcat([user, ' contains ' , num2str(length(days)), ' files of raw data']));
    rrClean = [];
    
    dayIndex = 0;
    for i=1:length(days)
        
%         % control list; using 
%         if(ctrl_list_fun)
%             %allow
%             if(sum(datenum(ctrlList{strcmp(user,ctrlList{:,1}),2:4}) == datenum(rr(IA(i),2:4))) == 0)
%                 continue;
%             end
%         else
%             %block
%             if(sum(datenum(ctrlList{strcmp(user,ctrlList{:,1}),2:4}) == datenum(rr(IA(i),2:4))) > 0)
%                 continue;
%             end
%         end
        
        %
        [rrProcessed, flagRRAct] = ...
        ProcessData(user, survey, acc(acc(:,1)==i,2:size(acc,2)), rr(rr(:,1)==i,2:size(rr,2)), fid);
%preclean(preclean(:,1)==i,2:size(preclean,2))??????
        dayIndex = dayIndex + 1;
        rrClean = [rrClean; [ones(length(rrProcessed),1)*dayIndex, rrProcessed]]; %,flagRRAct at the end
        
        %PostProcess(user,survey,rr, flagRRAct,accDatetimeUni,accStdIn10s);
    end
    
    
end