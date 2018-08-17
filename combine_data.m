
input_path='D:\chrome\trull.hexoskin\trull.hexoskin\1035\*\';

matfiles=dir(fullfile(input_path,'*rrinterval_averaged.csv'));

foldername=matfiles(1).folder;
filename=matfiles(1).name;
csv=importfile(fullfile(foldername,filename));
time=cellfun(@(x){x(4:end)}, csv.TimeStamp);
time=cellfun(@(x){strrep(x,'CDT','');}, time);
t=datenum(time,'mmm dd HH:MM:SS  yyyy');
date=datevec(t);
all_csv=[repmat(1,size(csv,1),1),date,csv.Value];
for i=2:length(matfiles)
    foldername=matfiles(i).folder;
    filename=matfiles(i).name;
    csv=importfile(fullfile(foldername,filename));
    time=cellfun(@(x){x(4:end)}, csv.TimeStamp);
    time=cellfun(@(x){strrep(x,'CDT','');}, time);
    t=datenum(time,'mmm dd HH:MM:SS  yyyy');
    date=datevec(t);
    csv_table=[repmat(i,size(csv,1),1),date,csv.Value]; % need to be change later
    all_csv=[all_csv;csv_table];
end

rrData=all_csv;
save('1035.mat','rrData')
survey=readsurvey('1035.csv');
userSurvey=[userSurvey;survey];
%accData=all_csv;
