function features = PostProcessResp(user,survey,rrClean)

% post process
    disp(strcat(['post process on ',user]));

    features = [];
    if(isempty(rrClean)); return; end
    
% handle different units, all to ms
%     if(~isempty(strfind(user,'hexo')))
%         rrClean(:,8) = rrClean(:,8)*1000;
%     end
    
% normalized across user
    rrUserMean = mean(rrClean(:,8));
    rrUserStd  = std (rrClean(:,8));
    rrNormal = (rrClean(:,8)-rrUserMean) / rrUserStd;
    
% for each day
    days = unique(rrClean(:,1));
    for j = 1:length(days)
        seq = rrClean(:,1)==j;
        rr = [rrClean(seq,2:8),rrNormal(seq,:)]; %7:raw 8:norm

% get gap position
        %

% calculate features in 1min window and 5mins moving window
        rrDatetimeCtrl=[rr(:,1:5),zeros(size(rr(:,6)))];
        [rrDatetimeUni,IA]=unique(rrDatetimeCtrl,'rows');
        IA2 = [IA(2:end)-1;length(rr)];
        
        %rrFeatures = zeros(length(IA),17);
        MEAN = zeros(length(IA),1);
        MEAN_norm = zeros(length(IA),1);
        
        
        lastRR = mean(rr(:,7)); %initial with the mean of the user
        for i = 1:length(IA)
            %1min window
            rrIn1m =     rr(IA(i):IA2(i),7);%7
            rrNormIn1m = rr(IA(i):IA2(i),8);%8
            MEAN(i)      = mean(rrIn1m);
            MEAN_norm(i) = mean(rrNormIn1m);
            
            
        end %end for 1 min window
        
%remove gap edges and get features
        %
        rrFeatures = [rrDatetimeUni,MEAN, MEAN_norm];%labeling should be on the last column

        features = [features; [ones(length(rrFeatures),1)*j, rrFeatures]];
        
    end % end for days
    
% label activity, and maybe user also
    
    
    
% dump labeled features
    %outside

end