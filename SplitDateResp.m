function respClean = SplitDateResp(user, ctrlList, respStatus, resp, min, max)
% this function is to split .mat files by day for each user id (resp version)
%     user = {'1008'};
%     acc = accData;
%     preclean = precleanData;
%     rr = rrData;

% constants
WHITE_LIST = true; BLACK_LIST = false;

% configuration
ctrl_list_fun = WHITE_LIST;
    
%
    [days, IA] = unique(resp(:,1));
    disp(strcat([user, ' contains ' , num2str(length(days)), ' days of raw data']));
    respClean = [];
    
    dayIndex = 0;
    for i=1:length(days)
        
        % control list; using 
        if(ctrl_list_fun)
            %allow
            if(sum(datenum(ctrlList{strcmp(user,ctrlList{:,1}),2:4}) == datenum(resp(IA(i),2:4))) == 0)
                continue;
            end
        else
            %block
            if(sum(datenum(ctrlList{strcmp(user,ctrlList{:,1}),2:4}) == datenum(resp(IA(i),2:4))) > 0)
                continue;
            end
        end
        
        %
        respProcessed = ProcessDataResp(user, respStatus(respStatus(:,1)==i,2:end), resp(resp(:,1)==i,2:end),min, max);

        dayIndex = dayIndex + 1;
        respClean = [respClean; [ones(length(respProcessed),1)*dayIndex, respProcessed]]; %,flagRRAct at the end
        
        %PostProcess(user,survey,rr, flagRRAct,accDatetimeUni,accStdIn10s);
    end
    
    
end