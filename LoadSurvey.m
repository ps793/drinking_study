function returnSurvey = LoadSurvey()

% configuration
    adjust_time = false;
    
% constants
    USER_ID     = 1;    %1 
    SURVEY_ID   = 3;    %2 
    SURVEY_TYPE = 4;    %3 
    SV_SCHEDULE = 5;    %4 
    SV_START    = 9;    %5 
    SV_FINISH   =10;    %6 
    ID_HOW_MANY = 81;   %7 
    ID_WHEN     = 80;   %8 
    DF_HOW_MANY = 181;  %9 
    RS_IS_DRINK = 133;  %10
    RS_HOW_MANY = 134;  %11
    RS_WHEN     = 191;  %12

    SV_DT = [USER_ID, SURVEY_ID, SURVEY_TYPE, SV_SCHEDULE, SV_START, SV_FINISH];
    ID = [ID_HOW_MANY, ID_WHEN];
    DF = [DF_HOW_MANY];
    RS = [RS_IS_DRINK, RS_HOW_MANY, RS_WHEN];
    MR = [46,47,184];
    
%
    load('newallSurvey8-2.mat'); % userSurvey
    
    rows = strcmp(userSurvey{:,SURVEY_TYPE},'ID') |...
          (strcmp(userSurvey{:,SURVEY_TYPE},'DF') & userSurvey{:,DF_HOW_MANY} >0) |...
          (~cellfun(@isempty,regexp(userSurvey{:,SURVEY_TYPE},'^RS')) & userSurvey{:,RS_IS_DRINK} ==1);
    cols = [SV_DT, ID, DF, RS, MR];
      
    allSurvey = userSurvey(rows, cols);

    returnSurvey = allSurvey{:,[1,3,5]};
    
% adjust drinking time
    if(adjust_time)
        adjust = ones(size(allSurvey{:,8}));
        
        seq1 = ~isnan(allSurvey{:,8}); seq2 = ~isnan(allSurvey{:,12}); % adjust for ID and RS survey
        adjust(seq1) = allSurvey{seq1,8}; adjust(seq2) = allSurvey{seq2,12}; % merge
        adjust = (adjust-1)*15; % how many of 15 mins
        adjust(adjust<=0)=0; adjust(adjust>=60)=60; % trim
        
        adjustMins = zeros(length(adjust),6); adjustMins(:,5) = adjust;
        adjusted = datestr(datenum(allSurvey{:,5}) - datenum(adjustMins), 'mm/dd/yyyy HH:MM:SS');
        
        returnSurvey(:,3) = cellstr(adjusted);
    end


%     <answer id="1">Just now.</answer>
%     <answer id="2">15 minutes ago.</answer>
%     <answer id="3">30 minutes ago.</answer>
%     <answer id="4">45 minutes ago.</answer>
%     <answer id="5">1 hour ago.</answer>
%     <answer id="6">More than 1 hour ago.</answer>


% add number of episose
    episode = allSurvey{:,[7,9,11]};

    episode(episode(:,1)==0)=1; % for earliest ID that can input 0 for # of drinks
    ind = find(isnan(episode)); episode(ind)=0; % remove NaN
    episode = sum(episode,2);
    
    returnSurvey = [returnSurvey, num2cell(episode)];
    %unique by 1:3
    [~,idx] = unique(strcat(returnSurvey(:,1),returnSurvey(:,2),returnSurvey(:,3)));
    returnSurvey = returnSurvey(sort(idx),:);

%% old one, combine new with Peng's
%{
    data = readtable('survey_raw_csv\survey data for all patient.csv');

    temp = data(:,[1,3,4,5,9,10, 80,81, 181, 133,134,191  46,47,184]);
    temp = temp((temp{:,2}~=9 &temp{:,2}~=8   ),:);
    temp = temp((temp{:,2}~=11 &temp{:,2}~=10   ),:);
    temp = temp((temp{:,2}~=7   ),:);

    seq=strcmp(temp{:,3},'ID') | (strcmp(temp{:,3},'DF') & temp{:,9} >0) |  (~cellfun(@isempty,regexp(temp{:,3},'^RS')) & temp{:,10} ==1);
    oldAllSurvey = temp{seq,[1,3,5]};
    
    load('survey_raw_csv\newAllSurvey.mat');

    allSurvey = [oldAllSurvey ; newAllSurvey];
%}



end
