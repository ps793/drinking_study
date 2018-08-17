% main function of whole pipeline

clear;
% constants
SEM = false; HEXOSKIN = true;

% configuration
plot_middle_result = false;
save_feature_csv = false;

base_folder = 'F:\resp';%'C:\Users\Chen\Documents\RawDataFromCravingStudy\Data\';
%black list; first run generate black list and then run second time 
fid=fopen('list_gen.txt','w');
ctrlList = readtable('list_control.txt');

% sensorType = SEM; userlist = {'1001','1004','1005','1007','1008','1010','1013','1014','1019','1020'};
% sensorType = HEXOSKIN; userlist = {'1032','1031','1030','1029','1028','1027','1026','1025','1024','1022','1021','1017','1014','1007'};
sensorType = 0; 
%userlist = {'1037','1032','1031','1030','1029','1028','1027','1026','1025','1024','1022','1021','1017','1014','1007'};
userlist = {'1035'};

if(sensorType); type = 'sem'; else type = 'hexo'; end;
allSurvey = LoadSurvey();
% allFeatures = [];
allDataset = [];

for i = 1:length(userlist)
%     if(sensorType); user = strcat('sem',userlist{i}); else user = strcat('hexo',userlist{i}); end;
    user = strcat(type, userlist{i});
    userdir = fullfile(base_folder,strcat(user,{'.mat'}));

    %disp(userdir);
    if(~exist(userdir{1}, 'file') )
        continue;
    end
    
    tic;load(userdir{1});loadtime=toc;
    disp(char(10));
    disp(strcat(['load ',user,' in ',num2str(loadtime),' seconds']));

    %load('1008_survey.mat');%survey(strcmp(survey(:,1),'1008'),:);
    survey = allSurvey(strcmp(allSurvey(:,1), userlist{i}),:);
    % clean data after loading
    rrClean=rrData;
    %rrClean = SplitDate(user, survey, ctrlList, accData, rrData, fid);
    %respClean = SplitDateResp(user, ctrlList, respStatus, respData, 10, 100);
    %minvClean = SplitDateResp(user, ctrlList, respStatus, minVentData, 1000, 120000);
    %feature calculation
%     allFeatures = [allFeatures; userFeatures];
    userFeatures = PostProcess(user, survey, rrClean);
end
    %respFeatures = PostProcessResp(user, survey, respClean);
    %minvFeatures = PostProcessResp(user, survey, minvClean);

    if(isempty(userFeatures)); continue; end
    
%rr and resp
    %join all features together 
    tableA=dataset(userFeatures(:,1:2), userFeatures(:,3:8), userFeatures(:,9:end),'VarNames',{'day','datetime','features'});
    tableB=dataset(respFeatures(:,2:7), respFeatures(:,8:9),'VarNames',{'datetime','resp'});

    mergeSet = join(tableA,tableB,'Key',{'datetime'},'Type','inner','MergeKeys',true); % drink day, survey
    mergeSet=dataset2cell(mergeSet);
    mergeSet(1,:)=[];
    mergeSet = cell2mat(mergeSet);
    mergeSet(isnan(mergeSet))=0;
    
    %exchange last 4 columns
    temp = mergeSet(:,end-1:end);
    mergeSet = [mergeSet(:,1:end-4), temp, mergeSet(:,end-3:end-2)];
% second join    
% rr_br and minv
    tableA=dataset(mergeSet(:,1:2), mergeSet(:,3:8), mergeSet(:,9:end),'VarNames',{'day','datetime','features'});
    tableB=dataset(minvFeatures(:,2:7), minvFeatures(:,8:9),'VarNames',{'datetime','minv'});

    mergeSet = join(tableA,tableB,'Key',{'datetime'},'Type','inner','MergeKeys',true); % drink day, survey
    mergeSet=dataset2cell(mergeSet);
    mergeSet(1,:)=[];
    mergeSet = cell2mat(mergeSet);
    mergeSet(isnan(mergeSet))=0;
    
    %exchange last 4 columns
    temp = mergeSet(:,end-1:end);
    mergeSet = [mergeSet(:,1:end-4), temp, mergeSet(:,end-3:end-2)];
    
%    
    %save all features in csv file, add user at first column
    userDataset = [dataset({repmat({user},length(mergeSet),1) 'user'}),...
                   dataset({mergeSet ...
                        'day','isdrinkday','yy','mm','dd','hh','mmm','sss',...
                        'HR','MEAN','MEDIAN','QD','PRCT20','PRCT80','VARI','RMSSD','SDSD','NN50','pNN50','NN20','pNN20',...
                        'LB','MB','HB','LBHB', 'SDANN','LF','HF','LFHF','BR','BRNORM','MINVENT','MINVENTNORM','isdrinking','dosage'})];
    allDataset = [allDataset; userDataset];
    
end
alldata = dataset2table(allDataset);
start_index=[];
end_index=[];
for i=2:size(alldata,1)
    if table2array(alldata(i-1,'isdrinking'))==0 && table2array(alldata(i,'isdrinking'))==1
        start_index=[start_index;i];
    end;
    if table2array(alldata(i-1,'isdrinking'))==1 && table2array(alldata(i,'isdrinking'))==0
        end_index=[end_index;i-1];
    end;
end;
alldata.datenum(1)=0;
formatIn = 'yy/mm/dd/HH/MM';
for i=1:size(alldata,1)
    time=table2array(alldata(i,4:8));
    timestring=sprintf('%d/%d/%d/%d/%d',time(1),time(2),time(3),time(4),time(5));
    alldata.datenum(i)=datenum(timestring,formatIn);
    alldata.ind(i)=i;
end

%subdata
for i=1:size(start_index,1)
    subdata{i,1}=alldata(start_index(i):end_index(i),:);
    subdata{i,2}=subdata{i,1}.datenum(1);
end;

%combine data

for i=1:(size(subdata,1)-1)
    if cell2mat(subdata(i+1,2))-cell2mat(subdata(i,2))<=hours(2.5)
        subdata{i,3}=1;
    else
        subdata{i,3}=0;
    end;
end;

index=cell2mat(subdata(:,3));
index(end+1)=0;
s_index=[];
e_index=[];
for i=1:(size(index,1)-1)
    if index(i)==0 && index(i+1)==1
        s_index=[s_index,i+1];
    end
    if index(i)==1 && index(i+1)==0 
        e_index=[e_index,i];
    end;
end;

if ~isempty(s_index)
    for i=1:size(s_index,1)
        block{i}=alldata(alldata.ind(subdata{s_index(i),1}.ind(1):subdata{e_index(i)+1,1}.ind(end)),:);
    end;
end;
count=2; 
if index(1)==0
    block{2,1}=subdata{1,1};
    count=count+1;
end;     
for i=2:size(index,1)   
    if index(i)==0 && index(i-1)~=1
        block{count,1}=subdata{i,1};
        count=count+1;
    end;
end;



%%%%%%%%%find negative sample
neg_data=alldata(table2array(alldata(:,'isdrinkday'))==0,:);
midnight_data=neg_data(neg_data.hh<=5|neg_data.hh>=18,:);
morning_data=neg_data(neg_data.hh>=6&neg_data.hh<=11,:);
afternoon_data=neg_data(neg_data.hh>=12&neg_data.hh<=17,:);
formatIn = 'yy/mm/dd/';
for i=1:size(block,1)
    pos=block{i,1};
    time_c=pos.hh(1);
    %midnight
    if time_c>=18 || time_c<=5
        random_flag=randi(size(midnight_data,1)-size(pos,1),1,1);
        date=table2array(midnight_data(random_flag,4:6));
        time=sprintf('%d/%d/%d/',date(1),date(2),date(3));
        later_date=table2array(midnight_data(random_flag+size(pos,1),4:6));
        later_time=sprintf('%d/%d/%d/',later_date(1),later_date(2),later_date(3));
        while ~strcmp(time,later_time)
            random_flag=randi(size(midnight_data,1)-size(pos,1),1,1);
            date=table2array(midnight_data(random_flag,4:6));
            time=sprintf('%d/%d/%d/',date(1),date(2),date(3));
            later_date=table2array(midnight_data(random_flag+size(pos,1),4:6));
            later_time=sprintf('%d/%d/%d/',later_date(1),later_date(2),later_date(3));
        end;
        block{i,2}=midnight_data(random_flag:random_flag+size(pos,1)-1,:);
        midnight_data(random_flag:random_flag+size(pos,1),:)=[];
    end
    %morning
    if time_c>=6 && time_c<=11
        random_flag=randi(size(morning_data,1)-size(pos,1),1,1);
        date=table2array(morning_data(random_flag,4:6));
        time=sprintf('%d/%d/%d/',date(1),date(2),date(3));
        later_date=table2array(morning_data(random_flag+size(pos,1),4:6));
        later_time=sprintf('%d/%d/%d/',later_date(1),later_date(2),later_date(3));
        while ~strcmp(time,later_time)
            random_flag=randi(size(morning_data,1)-size(pos,1),1,1);
            date=table2array(morning_data(random_flag,4:6));
            time=sprintf('%d/%d/%d/',date(1),date(2),date(3));
            later_date=table2array(morning_data(random_flag+size(pos,1),4:6));
            later_time=sprintf('%d/%d/%d/',later_date(1),later_date(2),later_date(3));
        end;
        block{i,2}=morning_data(random_flag:random_flag+size(pos,1)-1,:);
        morning_data(random_flag:random_flag+size(pos,1),:)=[];
    end
    %afternoon
    if time_c>=12 || time_c<=17
        random_flag=randi(size(afternoon_data,1)-size(pos,1),1,1);
        date=table2array(afternoon_data(random_flag,4:6));
        time=sprintf('%d/%d/%d/',date(1),date(2),date(3));
        later_date=table2array(afternoon_data(random_flag+size(pos,1),4:6));
        later_time=sprintf('%d/%d/%d/',later_date(1),later_date(2),later_date(3));
        while ~strcmp(time,later_time)
            random_flag=randi(size(afternoon_data,1)-size(pos,1),1,1);
            date=table2array(afternoon_data(random_flag,4:6));
            time=sprintf('%d/%d/%d/',date(1),date(2),date(3));
            later_date=table2array(afternoon_data(random_flag+size(pos,1),4:6));
            later_time=sprintf('%d/%d/%d/',later_date(1),later_date(2),later_date(3));
        end;
        block{i,2}=afternoon_data(random_flag:random_flag+size(pos,1)-1,:);
        afternoon_data(random_flag:random_flag+size(pos,1),:)=[];
    end
end;

for i=1:size(block,1)
    block{i,1}.pos=repmat('pos',size(block{i,1},1),1);
    block{i,1}.match=repmat(i,size(block{i,1},1),1);
    block{i,1}.datenum=[];
    block{i,1}.ind=[];
    block{i,2}.pos=repmat('neg',size(block{i,1},1),1);
    block{i,2}.match=repmat(i,size(block{i,1},1),1);
    block{i,2}.datenum=[];
    block{i,2}.ind=[];
end;

output=[];
for i=1:size(block,1)
    for j=1:size(block,2)
        output=[output;block{i,j}];
    end;
end;

writetable(output,'template.csv')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(save_feature_csv)
    %save csv
    delete(strcat('features_',type,'.csv'));
    export(allDataset,'file',strcat('features_',type,'.csv'),'Delimiter',',');
    
    %save mat
    delete(strcat('features_',type,'.mat'));
    save(strcat('features_',type,'.mat'), 'allDataset','type');
end
clear i loadtime;
fclose(fid);

seq = 0;

%% save arff
NON_DRINK_DAY = 0; DRINK_DAY = 1;

balanced = true;
balance_from = NON_DRINK_DAY;
scaled = false; %need to add column names
scale_type = '';

%scale 0-1
if(scaled)
    scale_type = '_scaled';
    scaledDataset = mapminmax(double(allDataset(:,10:30))',0,1)';
    scaledDataset = [allDataset(:,1:9),...
                    dataset({scaledDataset ...
                        'HR','MEAN','MEDIAN','QD','PRCT20','PRCT80','VARI','RMSSD','SDSD','NN50','pNN50','NN20','pNN20',...
                        'LB','MB','HB','LBHB', 'SDANN','LF','HF','LFHF'}),...
                    allDataset(:,31)];
else
    scaledDataset = allDataset(:,1:end);
end
            

drinkingMins = sum(scaledDataset.isdrinking==1);
nonDrinkingMins = sum(scaledDataset.isdrinkday==balance_from & scaledDataset.isdrinking==0);
if(balanced)
    selectMins = min((floor(drinkingMins/100)+1)*100, nonDrinkingMins);
else
    selectMins = nonDrinkingMins;
end

%randomly select $selectMins from $nonDrinkingMins
a=1:nonDrinkingMins;K=randperm(length(a));N=selectMins;b=a(K(1:N));
c=scaledDataset(scaledDataset.isdrinkday==balance_from & scaledDataset.isdrinking==0,:);
c=c(b,:);
d = [c;scaledDataset(scaledDataset.isdrinking==1,:)];

d=sortrows(d,[1,4:9]);
seq = seq +1;
WriteArff(strcat('features_',type,num2str(seq),scale_type,'.arff'), double(d(:,10:end)));


%%
% csvwrite('feature.csv',allFeatures);
% title
% day,drinkday,yy,mm,dd,hh,mmm,sss,HR,MEAN,MEDIAN,QD,PRCT20,PRCT80,VARI,RMSSD,SDSD,NN50,pNN50,NN20,pNN20,LB,MB,HB,LBHB, SDANN,LF,HF,LFHF,class
% sum(allFeatures(:,30)==1)
% sum(allFeatures(:,2)==1 & allFeatures(:,30)==0)

%{
%sem
a=1:7151;K=randperm(length(a));N=1800;b=a(K(1:N));
c=allFeatures(allFeatures(:,2)==0 & allFeatures(:,30)==0,:);
c=c(b,:);
d = [c;allFeatures(allFeatures(:,30)==1,:)];
d=sortrows(d,3:8);
csvwrite('feature.csv',d);
%}

%{
%hexoskin
a=1:3660;K=randperm(length(a));N=500;b=a(K(1:N));
c=allFeatures(allFeatures(:,2)==0 & allFeatures(:,30)==0,:);
c=c(b,:);
d = [c;allFeatures(allFeatures(:,30)==1,:)];
d=sortrows(d,3:8);
csvwrite('feature.csv',d);
%}
