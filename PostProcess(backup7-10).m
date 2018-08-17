function features = PostProcess(user,survey,rrClean)

% configuration
    plot_feature = true;

% post process
    disp(strcat(['post process on ',user]));

    features = [];
    if(isempty(rrClean)); return; end
    
% handle different units, all to ms
    if(~isempty(strfind(user,'hexo')))
        rrClean(:,8) = rrClean(:,8)*1000;
    end
    rrClean(:,end+1)=datenum(rrClean(:,2:7));
    [UA,ia,idx] = unique(rrClean(:,end));
    new_rr=[rrClean(ia,1:7),round(accumarray(idx,rrClean(:,8),[],@mean)),rrClean(ia,9)];
    rrClean=new_rr;
% make decision on small gap or big gap
    %1st column is research day
    days=unique(rrClean(:,1));
    time=rrClean(:,5)+rrClean(:,6)/60+rrClean(:,7)/3600;
    rrClean(:,9)=time;
    rr_total=[];
    for i=1:size(days,1)
        subdata=rrClean(rrClean(:,1)==i,:);
        overnight=subdata(subdata(:,9)<=3 & subdata(:,9)>=0,9);
        if ~isempty(overnight)
            subdata(subdata(:,9)<=3 & subdata(:,9)>=0,9)=overnight+24;
        end;
        s_time=subdata(1,9);
        e_time=subdata(end,9);
        subdata(:,9)=round(subdata(:,9),4);
        std_time=round((s_time:1/3600:e_time)',4);
        tb1=array2table(subdata);
        tb1.Properties.VariableNames(9) = {'time'};
        tb2=array2table(std_time);
        tb2.Properties.VariableNames(1) = {'time'};
        combine_tb=outerjoin(tb1,tb2,'Keys','time');
        subdata=table2array(combine_tb);  
        
        s_ind=[];
        e_ind=[];
        for j=1:(size(subdata,1)-1)
            if ~isnan(subdata(j,8)) && isnan(subdata(j+1,8))
                s_ind=[s_ind;j+1];
            end
            if isnan(subdata(j,8)) && ~isnan(subdata(j+1,8))
                e_ind=[e_ind;j];
            end
        end
        
        for j=1:size(s_ind,1)
            if e_ind(j)-s_ind(j)<=10
                block=subdata(s_ind(j)-1:e_ind(j)+1,:);
                yi=block(~isnan(block(:,8)),8);
                y1=block(~isnan(block(:,8)),1);
                y2=datenum(block(~isnan(block(:,8)),2:7));
                xi=block(~isnan(block(:,8)),10);
                fitlinear=round(interp1(xi,yi,block(:,10),'linear'),4);
                fit_day=round(interp1(xi,y1,block(:,10),'linear'));
                datevec1Min=datenum([0,0,0,0,0,1]);
                s=y2(1);
                e=y2(end);
                fit_date=datevec([datenum(s):datenum(datevec1Min):datenum(e)]');
                
                %subdata(s_ind(j)-1:e_ind(j)+1,8)=fitlinear;
                subdata(s_ind(j)-1:e_ind(j)+1,1)=fit_day;
                subdata(s_ind(j)-1:e_ind(j)+1,2:7)=fit_date;
            end;
        end;
        % do interpolation here
        rr_total=[rr_total;subdata];
    end;
    
    rrClean=rr_total;
    rrClean(isnan(rrClean(:,8)),:)=[];
% normalized across day
    rrUserMean = mean(rrClean(:,8));
    rrUserStd  = std (rrClean(:,8));
    rrNormal = (rrClean(:,8)-rrUserMean) / rrUserStd;
    
% for each day

    
    days = unique(rrClean(:,1));
    pos_block={};
    pos_survey_block={};
    user_survey=survey;
    for j = 1:length(days)
        seq = rrClean(:,1)==j;
        rr = [rrClean(seq,:),rrNormal(seq,:)]; %8:raw 11:norm
        if(isempty(survey)); continue; end
        
        if rr(1,5)>3
            dtStart = datenum([rr(1,2:4),6,0,0]);
            dtEnd = datenum([rr(1,2:3),rr(1,4)+1,2,59,59]);%end with 3 clock in the night
        else
            dtStart = datenum([rr(1,2:3),rr(1,4)-1,6,0,0]);
            dtEnd = datenum([rr(1,2:4),2,59,59]);
        end
        dtSurvey = datenum(survey(:,3));
        seq = dtSurvey > dtStart & dtSurvey < dtEnd;
        dtSurvey = dtSurvey(seq);
        

        
        %dtDosage = sum(cell2mat(survey(seq,4)));%across all the drinking 

        surveyID = dtSurvey(strcmp(survey(seq,2),'ID'));
        surveyDF = dtSurvey(strcmp(survey(seq,2),'DF'));
        surveyRS = dtSurvey(~cellfun(@isempty,regexp(survey(seq,2),'^RS')));
        block=[];
        block_sensor={};
        block_survey={};
        datevec1Min=datenum([0,0,0,0,0,1]);
        if length(dtSurvey)~=0
            if length(dtSurvey)>1
                clear start_list
                start_list{1,1}=dtSurvey(1);
                start_list{1,2}=dtSurvey(1);
                k=1;
                while k< length(dtSurvey)
                    start_list{end,1}=dtSurvey(k);
                    start_list{end,2}=dtSurvey(k);
                    start=dtSurvey(k);
                    
                    for m=(k+1):length(dtSurvey)
                        if dtSurvey(m)-start>datenum([0,0,0,2,0,0])
                            %start_list=[start_list;s_survey];
                            start_list{end,2}=dtSurvey(m-1);
                            start_list{end+1,1}=dtSurvey(m);
                            start_list{end,2}=dtSurvey(m);
                            break;
                        else
                            start_list{end,2}=dtSurvey(m);
                            start=start_list{end,2};
                        end
                    end
                    k=m;
                    
                end 
                start_list = start_list(~all(cellfun(@isempty, start_list),2), :);
                for n=1:size(start_list,1)
                    if start_list{n,1}==start_list{n,2}
                        bias=datenum([0,0,0,0,15,0]);
                        before=start_list{n,1}-datenum([0,0,0,0,30,0]);
                        drink=start_list{n,2}+datenum([0,0,0,0,0,0]);
                        after=start_list{n,2}+datenum([0,0,0,2,0,0]);
                        dtSurveyVec = datevec([datenum(before)-bias:datenum(datevec1Min):datenum(start_list{n,1})-bias]');
                        block{n,1}=[dtSurveyVec, zeros(length(dtSurveyVec),1)];
                        dtSurveyVec = datevec([datenum(start_list{n,1})-bias:datenum(datevec1Min):datenum(drink)]');
                        %seq =datenum(survey(:,3)) > datenum(start_list{n,1})-bias & datenum(survey(:,3)) < datenum(drink);
                        %dtDosage = sum(cell2mat(survey(seq,4)));%across all the drinking 
                        block{n,2}=[dtSurveyVec, ones(length(dtSurveyVec),1)];
                        dtSurveyVec = datevec([datenum(drink):datenum(datevec1Min):datenum(after)]');
                        block{n,3}=[dtSurveyVec, zeros(length(dtSurveyVec),1)];
                    else
                        bias=datenum([0,0,0,0,15,0]);
                        before=start_list{n,1}-datenum([0,0,0,0,30,0]);
                        drink=start_list{n,2}+datenum([0,0,0,0,0,0]);
                        after=start_list{n,2}+datenum([0,0,0,2,0,0]);
                        dtSurveyVec = datevec([datenum(before)-bias:datenum(datevec1Min):datenum(start_list{n,1})-bias]');
                        block{n,1}=[dtSurveyVec, zeros(length(dtSurveyVec),1)];
                        dtSurveyVec = datevec([datenum(start_list{n,1})-bias:datenum(datevec1Min):datenum(drink)]');
                        %seq = datenum(survey(:,3)) > datenum(start_list{n,1})-bias & datenum(survey(:,3)) < datenum(drink);
                        %dtDosage = sum(cell2mat(survey(seq,4)));%across all the drinking 
                        block{n,2}=[dtSurveyVec, zeros(length(dtSurveyVec),1)];
                        dtSurveyVec = datevec([datenum(drink):datenum(datevec1Min):datenum(after)]');
                        block{n,3}=[dtSurveyVec, zeros(length(dtSurveyVec),1)];
                    end;
                end

            else
                bias=datenum([0,0,0,0,15,0]);
                before  = dtSurvey - datenum([0,0,0,0,30,0]);
                drink = dtSurvey + datenum([0,0,0,0,0,0]);
                after = dtSurvey + datenum([0,0,0,2,0,0]);
                dtSurveyVec = datevec([datenum(before)-bias:datenum(datevec1Min):datenum(dtSurvey)-bias]');
                block{1,1}=[dtSurveyVec, zeros(length(dtSurveyVec),1)];
                dtSurveyVec = datevec([datenum(dtSurvey)-bias:datenum(datevec1Min):datenum(drink)]');
                %seq =datenum(survey(:,3)) > datenum(dtSurvey)-bias & datenum(survey(:,3)) < datenum(drink);
                %dtDosage = sum(cell2mat(survey(seq,4)));%across all the drinking 
                block{1,2}=[dtSurveyVec, zeros(length(dtSurveyVec),1)];
                dtSurveyVec = datevec([datenum(drink):datenum(datevec1Min):datenum(after)]');
                block{1,3}=[dtSurveyVec, zeros(length(dtSurveyVec),1)];
            end
        end;
        %before > drink > after
        
        
        
        %dtSurveyExpend = unique(dtSurveyExpend,'rows');
        
        if(~isempty(block))
            %bug fixed, new generated survey contains seconds, old doesn't
            
            block_sensor=[];
            block_survey=[];
            tableA=dataset(ones(length(rr),1), rr(:,2:7), rr(:,8:end),'VarNames',{'drinkday','datetime','features'});
            for r=1:size(block,1)
                for c=1:size(block,2)
                    dtSurveyExpend=block{r,c};
                    dtSurveyDosage = dtSurveyExpend(:,7);
                    tableB=dataset(dtSurveyExpend(:,1:6), ones(length(dtSurveyExpend),1), dtSurveyDosage, 'VarNames',{'datetime','survey','dosage'});
                    merge_memory=dataset2cell(tableB);
                    merge_memory(1,:)=[];
                    merge_memory = cell2mat(merge_memory);   
                    
                    
                    mergeSet = join(tableA,tableB,'Key',{'datetime'},'Type','left','MergeKeys',true); % drink day, survey
                    mergeSet=dataset2cell(mergeSet);
                    mergeSet(1,:)=[];
                    mergeSet = cell2mat(mergeSet);                                      
                    mergeSet(isnan(mergeSet(:,end)),:)=[];
                    if ~isempty(mergeSet)
                        start_time=dtSurveyExpend(1,1:6);
                        end_time=dtSurveyExpend(end,1:6);
                        seq =datenum(survey(:,3)) >= datenum(start_time) & datenum(survey(:,3)) <= datenum(end_time);
                        dtDosage = max(1,sum(cell2mat(survey(seq,4))));%can not have 0 dosage for their drinking. 
                        if c==2
                            mergeSet(:,end)=ones(size(mergeSet,1),1)*dtDosage;
                            tableB(:,end)=dataset(ones(size(tableB,1),1)*dtDosage);
                        end;
                        block_sensor{r,c}=dataset(mergeSet(:,1),mergeSet(:,2:7),mergeSet(:,8),mergeSet(:,end),'VarNames',{'drinkday','datetime','rr','dosage'});      
                        block_sensor{r,4}=1;
                        block_sensor{r,c+4}=datenum(mergeSet(1,2:7));
                        block_survey{r,c}=tableB;
                        block_survey{r,4}=1;
                        block_survey{r,c+4}=datenum(tableB.datetime(1,:));
                    else
                        start_time=dtSurveyExpend(1,1:6);
                        end_time=dtSurveyExpend(end,1:6);
                        seq =datenum(survey(:,3)) >= datenum(start_time) & datenum(survey(:,3)) <= datenum(end_time);
                        dtDosage = max(1,sum(cell2mat(survey(seq,4))));%can not have 0 dosage for their drinking. 
                        if c==2
                            merge_memory(:,8)=ones(size(merge_memory,1),1)*dtDosage;
                            tableB(:,end)=dataset(ones(size(tableB,1),1)*dtDosage);
                        end;
                        
                        merge_memory(:,7)=repmat(99999, size(merge_memory(:,7)));
                        block_sensor{r,c}=dataset(ones(length(merge_memory(:,1)),1),merge_memory(:,1:6),merge_memory(:,7),merge_memory(:,end),'VarNames',{'drinkday','datetime','rr','dosage'}); % still give output if no sensor
                        block_sensor{r,4}=1;
                        block_sensor{r,c+4}=datenum(merge_memory(1,1:6));
                        block_survey{r,c}=tableB;
                        block_survey{r,4}=1;
                        block_survey{r,c+4}=datenum(tableB.datetime(1,:));
                    end
                        
                end
            end
        end
        
        pos_block=[pos_block;block_sensor];
        pos_survey_block=[pos_survey_block;block_survey];
        dtSurvey = datenum(survey(:,3));
        seq = dtSurvey > dtStart & dtSurvey < dtEnd;
        survey(seq,:)=[];
    end
    
    
    %pos_block(end,:)=[];
    pos_block = pos_block(~all(cellfun(@isempty, pos_block),2), :);
    
    
    %%%%%%%make them in order
    dtSurvey=datenum(survey(:,3));
    if length(dtSurvey)~=0
        if length(dtSurvey)>1
            clear start_list
            start_list{1,1}=dtSurvey(1);
            start_list{1,2}=dtSurvey(1);
            k=1;
            while k< length(dtSurvey)
                start_list{end,1}=dtSurvey(k);
                start_list{end,2}=dtSurvey(k);
                start=dtSurvey(k);

                for m=(k+1):length(dtSurvey)
                    if dtSurvey(m)-start>datenum([0,0,0,2,0,0])
                        %start_list=[start_list;s_survey];
                        start_list{end,2}=dtSurvey(m-1);
                        start_list{end+1,1}=dtSurvey(m);
                        start_list{end,2}=dtSurvey(m);
                        break;
                    else
                        start_list{end,2}=dtSurvey(m);
                        start=start_list{end,2};
                    end
                end
                k=m;

            end 
            start_list = start_list(~all(cellfun(@isempty, start_list),2), :);
            for n=1:size(start_list,1)
                if start_list{n,1}==start_list{n,2}
                    bias=datenum([0,0,0,0,15,0]);
                    before=start_list{n,1}-datenum([0,0,0,0,30,0]);
                    drink=start_list{n,2}+datenum([0,0,0,0,0,0]);
                    after=start_list{n,2}+datenum([0,0,0,2,0,0]);
                    dtSurveyVec = datevec([datenum(before)-bias:datenum(datevec1Min):datenum(start_list{n,1})-bias]');
                    block{n,1}=[dtSurveyVec, zeros(length(dtSurveyVec),1)];
                    dtSurveyVec = datevec([datenum(start_list{n,1})-bias:datenum(datevec1Min):datenum(drink)]');
                    seq =datenum(survey(:,3)) >= datenum(start_list{n,1})-bias & datenum(survey(:,3)) <= datenum(drink);
                    dtDosage = sum(cell2mat(survey(seq,4)));%across all the drinking 
                    block{n,2}=[dtSurveyVec, ones(length(dtSurveyVec),1)*dtDosage];
                    dtSurveyVec = datevec([datenum(drink):datenum(datevec1Min):datenum(after)]');
                    block{n,3}=[dtSurveyVec, zeros(length(dtSurveyVec),1)];
                    block{n,4}=0;
                    block{n,5}=datenum(block{n,1}(1,1:6));
                    block{n,6}=datenum(block{n,2}(1,1:6));
                    block{n,7}=datenum(block{n,3}(1,1:6));
                else
                    bias=datenum([0,0,0,0,15,0]);
                    before=start_list{n,1}-datenum([0,0,0,0,30,0]);
                    drink=start_list{n,2}+datenum([0,0,0,0,0,0]);
                    after=start_list{n,2}+datenum([0,0,0,2,0,0]);
                    dtSurveyVec = datevec([datenum(before)-bias:datenum(datevec1Min):datenum(start_list{n,1})-bias]');
                    block{n,1}=[dtSurveyVec, zeros(length(dtSurveyVec),1)];
                    dtSurveyVec = datevec([datenum(start_list{n,1})-bias:datenum(datevec1Min):datenum(drink)]');
                    seq = datenum(survey(:,3)) >= datenum(start_list{n,1})-bias & datenum(survey(:,3)) <= datenum(drink);
                    dtDosage = sum(cell2mat(survey(seq,4)));%across all the drinking 
                    block{n,2}=[dtSurveyVec, ones(length(dtSurveyVec),1)*dtDosage];
                    dtSurveyVec = datevec([datenum(drink):datenum(datevec1Min):datenum(after)]');
                    block{n,3}=[dtSurveyVec, zeros(length(dtSurveyVec),1)];
                    block{n,4}=0;
                    block{n,5}=datenum(block{n,1}(1,1:6));
                    block{n,6}=datenum(block{n,2}(1,1:6));
                    block{n,7}=datenum(block{n,3}(1,1:6));
                end;
            end

        else
            bias=datenum([0,0,0,0,15,0]);
            before  = dtSurvey - datenum([0,0,0,0,30,0]);
            drink = dtSurvey + datenum([0,0,0,0,0,0]);
            after = dtSurvey + datenum([0,0,0,2,0,0]);
            dtSurveyVec = datevec([datenum(before)-bias:datenum(datevec1Min):datenum(dtSurvey)-bias]');
            block{1,1}=[dtSurveyVec, zeros(length(dtSurveyVec),1)];
            dtSurveyVec = datevec([datenum(dtSurvey)-bias:datenum(datevec1Min):datenum(drink)]');
            seq =datenum(survey(:,3)) >= datenum(dtSurvey)-bias & datenum(survey(:,3)) <= datenum(drink);
            dtDosage = sum(cell2mat(survey(seq,4)));%across all the drinking 
            block{1,2}=[dtSurveyVec, ones(length(dtSurveyVec),1)*dtDosage];
            dtSurveyVec = datevec([datenum(drink):datenum(datevec1Min):datenum(after)]');
            block{1,3}=[dtSurveyVec, zeros(length(dtSurveyVec),1)];
            block{1,4}=0;
            block{1,5}=datenum(block{1,1}(1,1:6));
            block{1,6}=datenum(block{1,2}(1,1:6));
            block{1,7}=datenum(block{1,3}(1,1:6));
        end
    end;
    pos_block=[pos_block;block];
      
    %%%pos_survey in order
    pos_survey_block=[pos_survey_block;block];
    
    pos_block=sortrows(pos_block,[5]);
    pos_survey_block=sortrows(pos_survey_block,[5]);
    
    %%find negative sample
    tableA=dataset(ones(length(rrClean),1), rrClean(:,2:7), rrClean(:,8:end),'VarNames',{'drinkday','datetime','features'});
    neg=dataset2cell(tableA);
    neg(1,:)=[];
    neg=cell2mat(neg);
    neg_block=[];
    for r=1:size(pos_block,1)
        pos_data=[];
        for c=1:3
            if pos_block{r,4}==1
                pos=pos_block{r,c};
                if ~isempty(pos)
                    pos=dataset2cell(pos);
                    pos(1,:)=[];
                    pos=cell2mat(pos);
                    start_time=datenum(pos(1,2:7));
                    end_time=datenum(pos(end,2:7));
                    table_time=datenum(tableA.datetime);
                    seq = table_time > start_time & table_time < end_time;
                    neg(seq,:)=NaN(size(neg(seq,:)));
                end
            end
        end
        
    end
    
    
    table_time=tableA.datetime;
    [DayNumber,DayName]=weekday(datenum(tableA.datetime));
    %weekend
    seq1 = DayNumber==5 & table_time(:,4) >= 17;
    seq2 = DayNumber==6;
    seq3 = DayNumber==7 & table_time(:,4) < 17;
    seq = seq1 | seq2 | seq3;
    weekend_data=neg(seq,:);
    
        
    %weekday
    seq=~seq;
    weekday_data=neg(seq,:);
    
    
    %%%%%%%%%%%%%%weekend 
    % night 18-3
    
    table_time=weekend_data(:,2:7);
    seq = table_time(:,4) >= 18 | table_time(:,4) < 3;
    weekend_night_neg=weekend_data(seq,:);
    
    %morning 3-12
    seq = table_time(:,4) >= 3 & table_time(:,4) < 12;
    weekend_morning_neg=weekend_data(seq,:);
    
    %afternoon 12-18
    seq = table_time(:,4) >= 12 & table_time(:,4) < 18;
    weekend_afternoon_neg=weekend_data(seq,:);
    
    %%%%%%%%%%%%weekday
    table_time=weekday_data(:,2:7);
    seq = table_time(:,4) >= 18 | table_time(:,4) < 3;
    weekday_night_neg=weekday_data(seq,:);
    
    %morning 3-12
    seq = table_time(:,4) >= 3 & table_time(:,4) < 12;
    weekday_morning_neg=weekday_data(seq,:);
    
    %afternoon 12-18
    seq = table_time(:,4) >= 12 & table_time(:,4) < 18;
    weekday_afternoon_neg=weekday_data(seq,:);
    
    %%%%%%%%%%%%negative selection
    count=0;
    for r=1:size(pos_block,1)
        if pos_block{r,4}==1
            for c=1:3
            
                
                pos=pos_block{r,c};
                flag_time=pos.datetime(1,:);
                week_info=weekday(datenum(flag_time));
                flag_time=flag_time(4);

                if (week_info == 5 && flag_time>=17) || week_info == 6 || (week_info ==7 && flag_time<17)
                    if flag_time >=3 && flag_time <12
                        neg_data=weekend_morning_neg;
                        label='m';
                    end
                    if flag_time >=12 && flag_time <18
                        neg_data=weekend_afternoon_neg;
                        label='a';
                    end
                    if flag_time >=18 || flag_time <3
                        neg_data=weekend_night_neg;
                        label='n';
                    end
                else
                    if flag_time >=3 && flag_time <12
                        neg_data=weekday_morning_neg;
                        label='m';
                    end
                    if flag_time >=12 && flag_time <18
                        neg_data=weekday_afternoon_neg;
                        label='a';
                    end
                    if flag_time >=18 || flag_time <3
                        neg_data=weekday_night_neg;
                        label='n';
                    end
                end



                if pos.rr(1)~=99999
                    pos_len=length(pos);
                    pos_time_interval=datenum(pos.datetime(end,:))-datenum(pos.datetime(1,:));
                    %%%search closer time at first
                    flag_time=pos.datetime(1,:);
                    flag_time=flag_time(4);
                    neg_block{r,c}=[];
                    time=flag_time;
                    if time <3
                        time=time+24;
                    end;
                    neg_data(neg_data(:,5)<3,5)=neg_data(neg_data(:,5)<3,5)+24;
                    while isempty(neg_block{r,c})
                        %disp(time)
                        if label=='n' && time <18
                            break;
                        end
                        if label=='a' && time <12
                            break;
                        end
                        if label=='m' && time <3
                            break;
                        end
                        closer_data=neg_data(neg_data(:,5)>=time,:);  
                        n_idx=1;
                        while n_idx < length(closer_data)-pos_len+1
                            next=closer_data(n_idx:n_idx+pos_len-1,:);
                            non_next=next;
                            non_next(isnan(non_next(:,8)),:)=[];%interpolation
                            if ~isempty(non_next)
                                neg_time_interval=datenum(non_next(end,2:7))-datenum(non_next(1,2:7));
                            else
                                neg_time_interval=0;
                            end
                            if length(non_next)==length(next) && neg_time_interval==pos_time_interval
                                next(next(:,5)>=24,5)=next(next(:,5)>=24,5)-24;
                                neg_block{r,c}=next;
                                neg_block{r,4}=1;

                                closer_data(n_idx:n_idx+pos_len-1,:)=NaN(size(closer_data(n_idx:n_idx+pos_len-1,:)));
                                break;
                            else
                                n_idx=n_idx+1;
                            end;
                        end
                        neg_data(neg_data(:,5)>=time,:)=closer_data;
                        time=time-1;
                    end
                else
                    neg_block{r,c}=[];
                    neg_block{r,4}=1;
                end;
                
                pos=pos_block{r,c};
                flag_time=pos.datetime(1,:);
                week_info=weekday(datenum(flag_time));
                flag_time=flag_time(4);
                neg_data(neg_data(:,5)>=24,5)=neg_data(neg_data(:,5)>=24,5)-24;
                if (week_info == 5 && flag_time>=17) || week_info == 6 || (week_info ==7 && flag_time<17)
                    if flag_time >=3 && flag_time <12
                        weekend_morning_neg=neg_data;
                    end
                    if flag_time >=12 && flag_time <18
                        weekend_afternoon_neg=neg_data;
                    end
                    if flag_time >=18 || flag_time <3
                        weekend_night_neg=neg_data;
                    end
                else
                    if flag_time >=3 && flag_time <12
                        weekday_morning_neg=neg_data;
                    end
                    if flag_time >=12 && flag_time <18
                        weekday_afternoon_neg=neg_data;
                    end
                    if flag_time >=18 || flag_time <3
                        weekday_night_neg=neg_data;
                    end
                end
                
                
            end
        else
            neg_block{r,c}=[];
            neg_block{r,4}=0;
        end
    end
    users=user;
    
    
    %%%%%%%%%%%sensor table
    episode_num=1;
    all_ep=[];
    for r=1:size(pos_block,1)
        if pos_block{r,4}==1
            pos_combine=[];
            neg_combine=[];
            for c=1:3
                %%%positive
                pos=pos_block{r,c};
                if ~isempty(pos)
                    pos=dataset2cell(pos);
                    pos(1,:)=[];
                    pos=cell2mat(pos);                
                    s_time=pos(1,2:7);
                    e_time=pos(end,2:7);
                    pos_len(c)=round(60*24*(datenum(e_time)-datenum(s_time)));
                    type=c;
                    is_drink=1;
                    dosage=mean(pos(:,9));
                    hr=60*1000/mean(pos(:,8));
                    if mean(pos(:,8))==99999
                        hr=99999;
                    end
                    one_output=[s_time,e_time,type,is_drink,dosage,hr];
                    pos_combine=[pos_combine,one_output];
                else
                    nine_output=repmat(99999,1,16);
                    pos_combine=[pos_combine,nine_output];
                    pos_len(c)=99999;
                end
                %%%negative
                neg=neg_block{r,c};
                if ~isempty(neg)           
                    s_time=neg(1,2:7);
                    e_time=neg(end,2:7);
                    neg_len(c)=round(60*24*(datenum(e_time)-datenum(s_time)));
                    type=c;
                    is_drink=0;
                    dosage=0;
                    hr=60*1000/mean(neg(:,8));
                    if mean(neg(:,8))==99999
                        hr=99999;
                    end
                    one_output=[s_time,e_time,type,is_drink,dosage,hr];
                    neg_combine=[neg_combine,one_output];
                else
                    nine_output=repmat(99999,1,16);
                    neg_combine=[neg_combine,nine_output];
                    neg_len(c)=99999;
                end

            end
            pos_ep=[str2num(users(end-3:end)),episode_num,pos_combine,pos_len];
            episode_num=episode_num+1;
            neg_ep=[str2num(users(end-3:end)),episode_num,neg_combine,neg_len];
            episode_num=episode_num+1;
            ep=[pos_ep;neg_ep];
            all_ep=[all_ep;ep];
        else
            pos_combine=[];
            neg_combine=[];
            for c=1:3
                %%%positive
                pos=pos_block{r,c};
                if ~isempty(pos)
                    s_time=pos(1,1:6);
                    e_time=pos(end,1:6);
                    pos_len(c)=round(60*24*(datenum(e_time)-datenum(s_time)));
                    type=c;
                    is_drink=1;
                    dosage=mean(pos(:,end));
                    hr=99999;
                    one_output=[s_time,e_time,type,is_drink,dosage,hr];
                    pos_combine=[pos_combine,one_output];
                else
                    nine_output=repmat(99999,1,16);
                    pos_combine=[pos_combine,nine_output];
                    pos_len(c)=99999;
                end
                nine_output=repmat(99999,1,16);
                neg_combine=[neg_combine,nine_output];
                neg_len(c)=99999;
        
            end
            pos_ep=[str2num(users(end-3:end)),episode_num,pos_combine,pos_len];
            episode_num=episode_num+1;
            neg_ep=[str2num(users(end-3:end)),episode_num,neg_combine,neg_len];
            episode_num=episode_num+1;
            ep=[pos_ep;neg_ep];
            all_ep=[all_ep;ep];
        end
    end
    
    

    
    output_ep=array2table(all_ep);
    output_ep.Properties.VariableNames={'user','episode','s_year_1','s_month_1','s_day_1','s_hour_1','s_min_1','s_sec_1',...
                                        'e_year_1','e_month_1','e_day_1','e_hour_1','e_min_1','e_sec_1','type_1','is_drinking_1','dosage_1','HR_1',...
                                        's_year_2','s_month_2','s_day_2','s_hour_2','s_min_2','s_sec_2',...
                                        'e_year_2','e_month_2','e_day_2','e_hour_2','e_min_2','e_sec_2','type_2','is_drinking_2','dosage_2','HR_2',...
                                        's_year_3','s_month_3','s_day_3','s_hour_3','s_min_3','s_sec_3',...
                                        'e_year_3','e_month_3','e_day_3','e_hour_3','e_min_3','e_sec_3','type_3','is_drinking_3','dosage_3','HR_3',...
                                        'duration_1','duration_2','duration_3'};
                                    
                                    
                                    
    %%%%%%%survey table
    episode_num=1;
    all_ep=[];
    for r=1:size(pos_block,1)
        if pos_block{r,4}==1
            pos_combine=[];
            neg_combine=[];
            for c=1:3
                %%%positive
                pos=pos_survey_block{r,c};
                if ~isempty(pos)
                    pos=dataset2cell(pos);
                    pos(1,:)=[];
                    pos=cell2mat(pos);                
                    s_time=pos(1,1:6);
                    e_time=pos(end,1:6);
                    pos_len(c)=round(60*24*(datenum(e_time)-datenum(s_time)));
                    type=c;
                    is_drink=1;
                    dosage=mean(pos(:,end));
                    %hr=60*1000/mean(pos(:,8));
                    one_output=[s_time,e_time,type,is_drink,dosage];
                    pos_combine=[pos_combine,one_output];
                else
                    nine_output=repmat(99999,1,15);
                    pos_combine=[pos_combine,nine_output];
                    pos_len(c)=99999;
                end
                %%%negative
                neg=neg_block{r,c};
                nine_output=repmat(99999,1,15);
                neg_combine=[neg_combine,nine_output];
                neg_len(c)=99999;

            end
            pos_ep=[str2num(users(end-3:end)),episode_num,pos_combine,pos_len];
            episode_num=episode_num+1;
            neg_ep=[str2num(users(end-3:end)),episode_num,neg_combine,neg_len];
            episode_num=episode_num+1;
            ep=[pos_ep;neg_ep];
            all_ep=[all_ep;ep];
        else
            pos_combine=[];
            neg_combine=[];
            for c=1:3
                %%%positive
                pos=pos_survey_block{r,c};
                if ~isempty(pos)
                    s_time=pos(1,1:6);
                    e_time=pos(end,1:6);
                    pos_len(c)=round(60*24*(datenum(e_time)-datenum(s_time)));
                    type=c;
                    is_drink=1;
                    dosage=mean(pos(:,end));
                    %hr=99999;
                    one_output=[s_time,e_time,type,is_drink,dosage];
                    pos_combine=[pos_combine,one_output];
                else
                    nine_output=repmat(99999,1,15);
                    pos_combine=[pos_combine,nine_output];
                    pos_len(c)=99999;
                end
                nine_output=repmat(99999,1,15);
                neg_combine=[neg_combine,nine_output];
                neg_len(c)=99999;
            end
            pos_ep=[str2num(users(end-3:end)),episode_num,pos_combine,pos_len];
            episode_num=episode_num+1;
            neg_ep=[str2num(users(end-3:end)),episode_num,neg_combine,neg_len];
            episode_num=episode_num+1;
            ep=[pos_ep;neg_ep];
            all_ep=[all_ep;ep];
        end
    end
    

    
    
    output_survey_ep=array2table(all_ep);
    output_survey_ep.Properties.VariableNames={'user','episode','ss_year_1','ss_month_1','ss_day_1','ss_hour_1','ss_min_1','ss_sec_1',...
                                        'se_year_1','se_month_1','se_day_1','se_hour_1','se_min_1','se_sec_1','stype_1','sis_drinking_1','sdosage_1',...
                                        'ss_year_2','ss_month_2','ss_day_2','ss_hour_2','ss_min_2','ss_sec_2',...
                                        'se_year_2','se_month_2','se_day_2','se_hour_2','se_min_2','se_sec_2','stype_2','sis_drinking_2','sdosage_2',...
                                        'ss_year_3','ss_month_3','ss_day_3','ss_hour_3','ss_min_3','ss_sec_3',...
                                        'se_year_3','se_month_3','se_day_3','se_hour_3','se_min_3','se_sec_3','stype_3','sis_drinking_3','sdosage_3',...
                                        'sduration_1','sduration_2','sduration_3'};
    
    
    
    final_output=[output_ep,output_survey_ep(:,3:end)];
    writetable(final_output,strcat(['C:\\Users\\ps793\\Desktop\\new_hexoskin\\',user,'(weekday_weekend_neg_survey_order_closer).csv']));
    %20sec block for each drinking episode
%     interval=60;
%     all_block20=[];
%     all_stats=zeros(7200,2);
%     for r=1:size(pos_block,1)
%         for c=1:size(pos_block,2)         
%             block20=[];
%             pos=pos_block{r,c};
%             if ~isempty(pos)
%                 pos=dataset2cell(pos);
%                 pos(1,:)=[];
%                 pos=cell2mat(pos);
%                 time=pos(:,5)+pos(:,6)/60+pos(:,7)/3600;
%                 pos(:,end+1)=time;
%                 subdata=pos;
%                 s_time=subdata(1,end);
%                 e_time=subdata(end,end);
%                 subdata(:,end)=round(subdata(:,end),4);
%                 std_time=round((s_time:1/3600:e_time)',4);
%                 tb1=array2table(subdata);
%                 tb1.Properties.VariableNames(10) = {'time'};
%                 tb2=array2table(std_time);
%                 tb2.Properties.VariableNames(1) = {'time'};
%                 combine_tb=outerjoin(tb1,tb2,'Keys','time');
%                 subdata=table2array(combine_tb);
%                 
%                 %fitloess to find outlier and missing interpolation
%                 subdata(:,end+1)=0;
%                 subdata(isnan(subdata(:,8)),end)=1;
%                 insert_count=sum(subdata(:,end));
%                 s_count=[];
%                 e_count=[];
%                 stats=[];
%                 for line=2:size(subdata,1)
%                     if subdata(line-1,end)==0 && subdata(line,end)==1
%                         s_count=[s_count,line];
%                     end
%                     if subdata(line-1,end)==1 && subdata(line,end)==0
%                         e_count=[e_count,line];
%                     end
%                     if subdata(line,end)==1 && line==size(subdata,1)
%                         e_count=[e_count,line+1];
%                     end;
%                     if subdata(line-1,end)==1 && line==2
%                         s_count=[s_count,line-1];
%                     end;
%                 end;
%                 if ~isempty(e_count)
%                     stats=e_count-s_count;
%                     %disp(stats);
%                     for s=1:length(stats)
%                         all_stats(stats(s),1)=all_stats(stats(s),1)+1;
%                     end;
%                     subdata(isnan(subdata(:,8)),8)=0;
%                 end;
%                 %disp(insert_count);
%                 
% %                 if insert_count~=0
% %                     disp([r,c])
% %                 end
%                 %%%%%%%%%%%%%%%%%%loess
%                 
%                 loess_data=subdata(:,8);
%                 sub_loess=loess(loess_data);
%                 subdata=[subdata,sub_loess];
%                 
%                 s_count=[];
%                 e_count=[];
%                 stats=[];
%                 for line=2:size(subdata,1)
%                     if subdata(line-1,end)==0 && subdata(line,end)==1
%                         s_count=[s_count,line];
%                     end
%                     if subdata(line-1,end)==1 && subdata(line,end)==0
%                         e_count=[e_count,line];
%                     end
%                     if subdata(line,end)==1 && line==size(subdata,1)
%                         e_count=[e_count,line+1];
%                     end;
%                     if subdata(line-1,end)==1 && line==2
%                         s_count=[s_count,line-1];
%                     end;
%                 end;
%                 if ~isempty(e_count)
%                     stats=e_count-s_count;
%                     %disp(stats);
%                     for s=1:length(stats)
%                         all_stats(stats(s),2)=all_stats(stats(s),2)+1;
%                     end;
% 
%                     subdata(subdata(:,end)==1,8)=subdata(subdata(:,end)==1,end-1);
%                 end;
%                 line=1;
%                 count=0;
%                 while line<size(subdata,1)-interval+1
%                     sub20=subdata(line:line+interval-1,:);
%                     sub20(isnan(sub20(:,8)),:)=[];
%                     if size(sub20,1)==interval
%                         count=count+1;
%                         hr=1000*60/mean(sub20(:,8));
%                         block20{count,1}=sub20;
%                         line=line+interval-1;
%                     else
%                         line=line+1;
%                     end
% 
%                 end
%             else
%                 block20=[];
%             end;
%             all_block20{r,c}=block20;
%         end
%     end
%     
%     
%     
% 
%     
%     all_neg_block=[];
%     for r=1:size(neg_block,1)
%         for c=1:size(neg_block,2)
%             block20=[];
%             neg=neg_block{r,c};
%             if ~isempty(neg)
%                 time=neg(:,5)+neg(:,6)/60+neg(:,7)/3600;
%                 neg(:,end+1)=time;
%                 subdata=neg;
%                 s_time=subdata(1,end);
%                 e_time=subdata(end,end);
%                 subdata(:,end)=round(subdata(:,end),4);
%                 std_time=round((s_time:1/3600:e_time)',4);
%                 tb1=array2table(subdata);
%                 tb1.Properties.VariableNames(10) = {'time'};
%                 tb2=array2table(std_time);
%                 tb2.Properties.VariableNames(1) = {'time'};
%                 combine_tb=outerjoin(tb1,tb2,'Keys','time');
%                 subdata=table2array(combine_tb);
% 
%                 line=1;
%                 count=0;
%                 while line<length(subdata)-interval+1
%                     sub20=subdata(line:line+interval-1,:);
%                     sub20(isnan(sub20(:,10)),:)=[];
%                     if size(sub20,1)==interval
%                         count=count+1;
%                         hr=1000*60/mean(sub20(:,8));
%                         block20{count,1}=sub20;
%                         line=line+interval-1;
%                     else
%                         line=line+1;
%                     end
% 
%                 end
%             else
%                 block20=[];
%             end;
%             all_neg_block{r,c}=block20;
%         end
%         
%     end
%     
%     
%     %stats for each 5min block, need to add stats in
%     all_pos20=[];
%     for r=1:size(all_block20,1)
%         for c=1:size(all_block20,2)
%             interval_block=all_block20{r,c};
%             for n=1:length(interval_block)
%                 subdata=interval_block{n,1};
%                 count=0;
%                 s_count=[];
%                 e_count=[];
%                 stats=[];
%                 for line=2:size(subdata,1)
%                     if subdata(line-1,end)==0 && subdata(line,end)==1
%                         s_count=[s_count,line];
%                     end
%                     if subdata(line-1,end)==1 && subdata(line,end)==0
%                         e_count=[e_count,line];
%                     end
%                     if subdata(line,end)==1 && line==size(subdata,1)
%                         e_count=[e_count,line+1];
%                     end;
%                     if subdata(line-1,end)==1 && line==2
%                         s_count=[s_count,line-1];
%                     end;
%                 end;
%                 if ~isempty(e_count)
%                     stats=e_count-s_count;
%                     %disp(stats);
%                     for s=1:length(stats)
%                         if stats(s)>3
%                             count=count+1;
%                         end
%                     end;
%                 end;
%                 s_time=interval_block{n,1}(1,2:7);
%                 e_time=interval_block{n,1}(end,2:7);
%                 hr=60*1000/mean(interval_block{n,1}(:,8));
%                 type=c;
%                 dosage=mean(interval_block{n,1}(~isnan(interval_block{n,1}(:,9)),9));
%                 is_drinking=1;
%                 pos20=[s_time,e_time,type,is_drinking,dosage,hr,count];
%                 all_pos20=[all_pos20;pos20];
%             end;
%         end
%     end
%     all_neg20=[];
%     for r=1:size(all_neg_block,1)
%         for c=1:size(all_neg_block,2)
%             interval_block=all_neg_block{r,c};
%             for n=1:length(interval_block)
%                                 subdata=interval_block{n,1};
%                 count=0;
%                 s_count=[];
%                 e_count=[];
%                 stats=[];
%                 for line=2:size(subdata,1)
%                     if subdata(line-1,end)==0 && subdata(line,end)==1
%                         s_count=[s_count,line];
%                     end
%                     if subdata(line-1,end)==1 && subdata(line,end)==0
%                         e_count=[e_count,line];
%                     end
%                     if subdata(line,end)==1 && line==size(subdata,1)
%                         e_count=[e_count,line+1];
%                     end;
%                     if subdata(line-1,end)==1 && line==2
%                         s_count=[s_count,line-1];
%                     end;
%                 end;
%                 if ~isempty(e_count)
%                     stats=e_count-s_count;
%                     %disp(stats);
%                     for s=1:length(stats)
%                         if stats(s)>3
%                             count=count+1;
%                         end
%                     end;
%                 end;
%                 s_time=interval_block{n,1}(1,2:7);
%                 e_time=interval_block{n,1}(end,2:7);
%                 hr=60*1000/mean(interval_block{n,1}(:,8));
%                 type=c;
%                 dosage=0;
%                 is_drinking=0;
%                 neg20=[s_time,e_time,type,is_drinking,dosage,hr,count];
%                 all_neg20=[all_neg20;neg20];
%             end;
%         end
%     end
%     
%     all_20=[all_pos20;all_neg20];
%     output_20=array2table(all_20);
%     output_20.Properties.VariableNames={'s_year','s_month','s_day','s_hour','s_min','s_sec',...
%                                         'e_year','e_month','e_day','e_hour','e_min','e_sec','type','is_drinking','dosage','HR','Outlier_Count'};
%     writetable(output_20,strcat(['C:\\Users\\ps793\\Desktop\\new_hexoskin\\',user,'(1min).csv']));
%     
% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %features = [features; rrFeatures];

% plot
%         if(~plot_feature); continue; end
%         % plot features
%         figure
%         plot(datenum(rrFeatures(:,1:6)),rrFeatures(:,7:end))
%         datetick('x',15);
%         title(strcat({'#'},user, {' All RR Features'}));
%         xlabel(strcat({'Date '},datestr(rrFeatures(1,1:6),'mm/dd/yyyy'),{' Time'}));
%         
%         % plot labeling
%         yy=[-10,800];
%         legendHandle=[];
%         legendColor={};
%         if(~isempty(surveyID))
%             a=line([surveyID,surveyID]',yy,'color','r');
%             legendHandle = [legendHandle ; a(1)];
%             legendColor = [legendColor 'ID'];
%         end
%         if(~isempty(surveyDF))
%             b=line([surveyDF,surveyDF]',yy,'color','g');
%             legendHandle = [legendHandle ; b(1)];
%             legendColor = [legendColor 'DF'];
%         end
%         if(~isempty(surveyRS))
%             c=line([surveyRS,surveyRS]',yy,'color','b');
%             legendHandle = [legendHandle ; c(1)];
%             legendColor = [legendColor 'RS'];
%         end
% 
%         if(~isempty(dtSurveySt))
%             extArea=[dtSurveySt,dtSurveyEnd];
%             hold on;
%             fill([extArea,fliplr(extArea)]',[yy(1),yy(1),yy(2),yy(2)],'k','FaceAlpha',0.1);
%         end
%         
%         % legend
%         if(~isempty(legendHandle)); legend(legendHandle,legendColor); end
 % end for days
% get gap position
        %

% % calculate features in 1min window and 5mins moving window
%         rrDatetimeCtrl=[rr(:,1:5),zeros(size(rr(:,6)))];
%         [rrDatetimeUni,IA]=unique(rrDatetimeCtrl,'rows');
%         IA2 = [IA(2:end)-1;length(rr)];
%         
%         %rrFeatures = zeros(length(IA),17);
%         MEAN = zeros(length(IA),1);
%         HR = zeros(length(IA),1);
%         MEDIAN = zeros(length(IA),1);
%         QD = zeros(length(IA),1);
%         PRCT20 = zeros(length(IA),1);
%         PRCT80 = zeros(length(IA),1);
%         
%         VARI = zeros(length(IA),1);
%         RMSSD = zeros(length(IA),1);
%         SDSD = zeros(length(IA),1);
%         NN50 = zeros(length(IA),1);
%         pNN50 = zeros(length(IA),1);
%         NN20 = zeros(length(IA),1);
%         pNN20 = zeros(length(IA),1);
%         
%         LB = zeros(length(IA),1);
%         MB = zeros(length(IA),1);
%         HB = zeros(length(IA),1);
%         LBHB = zeros(length(IA),1);
%         
%         SDANN = zeros(length(IA),1);
%         LF = zeros(length(IA),1);
%         HF = zeros(length(IA),1);
%         LFHF = zeros(length(IA),1);
%         
%         lastRR = mean(rr(:,7)); %initial with the mean of the user
%         for i = 1:length(IA)
%             %1min window
%             rrIn1m = rr(IA(i):IA2(i),7);%7
%             rrNormIn1m = rr(IA(i):IA2(i),8);%8
%             MEAN(i) = mean(rrNormIn1m);
%             HR(i) = 60*1000/mean(rrIn1m);
%             MEDIAN(i) = median(rrNormIn1m);
%             QD(i) = iqr(rrNormIn1m)/2;
%             PRCT20(i) = prctile(rrNormIn1m,20);
%             PRCT80(i) = prctile(rrNormIn1m,80);
%             VARI(i) = var(rrNormIn1m);
%             
%             %successive differences
% %             rrSDIn1m = rrIn1m - [lastRR;rrIn1m(1:end-1)]; lastRR = rrIn1m(end);%abs?
% %             RMSSD(i) = rms(rrSDIn1m);
% %             SDSD(i) = std(rrSDIn1m);
% %             NN50(i) = sum(abs(rrSDIn1m) > 50);
% %             pNN50(i) = NN50(i) / length(rrSDIn1m);
% %             NN20(i) = sum(abs(rrSDIn1m) > 20);
% %             pNN20(i) = NN20(i) / length(rrSDIn1m);
% 
%             %fft
%             [LB(i),MB(i),HB(i),LBHB(i)] = RRBandFft(rrNormIn1m);
%             
%             
%             %5mins moving window
%             extend = min([i-1,length(IA)-i,2]);%extend minutes = 2;
%             rrNormIn5m = rr(IA(i-extend):IA2(i+extend),8);%8
%             SDANN(i) = std(rrNormIn5m);
%             [LF(i),HF(i),LFHF(i)] = RRFreqFft(rrNormIn5m);
%             
%         end %end for 1 min window
%         
% %remove gap edges and get features
%         %
%         rrFeatures = [rrDatetimeUni,HR,MEAN,MEDIAN,QD,PRCT20,PRCT80,VARI,LB,MB,HB,LBHB, SDANN,LF,HF,LFHF];%labeling should be on the last column
% 
%         %5mins window without overlapping 
%         %{
%         rrDatetimeCtrlIn5m=[rr(:,1:4),fix(rr(:,5)./5).*5,zeros(size(rr(:,6)))];
%         [rrDatetimeUniIn5m,IA5]=unique(rrDatetimeCtrlIn5m,'rows');
%         IA52 = [IA5(2:end)-1;length(rr)];
%         
%         SDANN = zeros(length(IA5),1);
%         LF = zeros(length(IA5),1);
%         HF = zeros(length(IA5),1);
%         LFHF = zeros(length(IA5),1);
%         
%         for i = 1:length(IA5)
%             rrNormIn5m = rr(IA5(i):IA52(i),8);%8
%             SDANN(i) = std(rrNormIn5m);
%             [LF(i),HF(i),LFHF(i)] = RRFreqFft(rrNormIn5m);
%             
%         end %end for 5 mins window
%         rrFeaturesIn5m = [rrDatetimeUniIn5m,SDANN,LF,HF,LFHF];%labeling should be on the last column
%         %}
%         
%         % calculate features in 5 min window
%         %5mins window with overlapping 
%         %{
%         rrDatetimeCtrlIn5m=[rr(:,1:5),zeros(size(rr(:,6)))];
%         [rrDatetimeUniIn5m,IA5]=unique(rrDatetimeCtrlIn5m,'rows');
%         IA52 = [IA5(2:end)-1;length(rr)];
%         
%         SDANN = zeros(length(IA5),1);
%         LF = zeros(length(IA5),1);
%         HF = zeros(length(IA5),1);
%         LFHF = zeros(length(IA5),1);
%         
%         
%         for i = 1:length(IA5)
%             extend = min([i-1,length(IA5)-i,2]);%extend minutes = 2;
%             
%             rrNormIn5m = rr(IA5(i-extend):IA52(i+extend),8);
%             SDANN(i) = std(rrNormIn5m);
%             [LF(i),HF(i),LFHF(i)] = RRFreqFft(rrNormIn5m);
%             
%         end %end for 5 mins window
%         rrFeaturesIn5m = [rrDatetimeUniIn5m,SDANN,LF,HF,LFHF];%labeling should be on the last column
%         %}
%         
%         
% % survey labeling
% 

%should change from here
        

end