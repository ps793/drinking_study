function [rrDatetimeList, rrGapFlag] = RRGap(user, rr)
%this function is to use 10 minute sliding window to remove the situation
%which it has several points in one gap
    %%
    % rr=readtable('15062802_RR.csv');
    % 
    % dateTimeRR=DateHandler(rr{:,1}, rr{:,2},'mm/dd/yy HH:MM:SS.');
    % rr=rr{:,3};

    %%
    % consider HR ranges 40~200 bpm, RR int. ranges 1500~300 ms
    % remove invalid value

    vec1Min = [0,0,0,0,1,0];

    % special value in SEM , no need to 
    % rr(rr(:,7)<=195,:)=[];

    %%
    % rr
    rrDatetimeStart = [rr(1,1:5), 0];
    rrDatetimeEnd = [rr(end,1:5), 0];

    rrDatetimeList = datenum(datevec([datenum(rrDatetimeStart):datenum(vec1Min):datenum(rrDatetimeEnd)]'));
    rrCmp = [datenum([rr(:,1:5), zeros(size(rr(:,6)))]), rr(:,7)];

    rrGapFlag=zeros(length(rrDatetimeList),1);
    rrGapNum=zeros(length(rrDatetimeList),1);

    thresMin = 10;
    thres = thresMin*40; % y*z

    for i = 1:length(rrDatetimeList)
        if(i<thresMin)
            rrGapFlag(i) = 1;
            continue;
        elseif(i>=length(rrDatetimeList)-thresMin)
            rrGapFlag(i) = 0;
            continue;
        end

        lower = rrDatetimeList(i-thresMin+1);
        upper = rrDatetimeList(i);


        rrGapNum(i)=sum(rrCmp(:,1)>=lower & rrCmp(:,1)<=upper);

        if(sum(rrCmp(:,1)>=lower & rrCmp(:,1)<=upper) <= thres)
            rrGapFlag(i) = 0;
        else
            rrGapFlag(i) = 1;
        end
    end

    %%
    % % rrDatetime = rr(:,1:6);
    % rrDatetimeMins = [rr(:,1:5), zeros(size(rr(:,6)))];
    % [rrDatetimeUni,IA,IC]=unique(rrDatetimeMins,'rows');
    % rrGapFlag=zeros(length(rrDatetimeUni),1);
    % rrGapNum=zeros(length(rrDatetimeUni),1);
    % 
    % thresMin = 10;
    % 
    % start=1; stop=1; flag=0;% 0 if removed;
    % for i = 1:length(rrDatetimeUni)
    %     if(i<thresMin)
    %         
    %         continue;
    %     elseif(i>=length(rrDatetimeUni)-thresMin)
    %         continue;
    %     end
    %     
    %     stop = i;
    %     rrGapNum(i)=length(rr(IA(i-thresMin+1):IA(i+1)-1));
    %     if(length(rr(IA(i-thresMin+1):IA(i+1)-1)) <= thresMin*50)
    %         if(flag)%flag==1
    %             flag=0;
    %             
    %         else%flag==0
    %             ;
    %         end
    %         rrGapFlag(i) = 0;
    %     else
    %         if(flag)%flag==1
    %             ;
    %             
    %         else%flag==0
    %             flag=1;
    % 
    %         end
    %         rrGapFlag(i) = 1;
    %     end
    %     
    % end

    %{
    figure;
    plot(datenum(rr(:,1:6)), rr(:,7),'.');
    hold on;
    plot(datenum(rrDatetimeList), rrGapFlag.*100.+50);
    %plot(datenum(rrDatetimeList), rrGapNum,'*');
    datetick('x',15);
    title(strcat({'#'},user, {' RR Int. : '},{'with 10min Gap.'}));%num2str(round(percent*100,2)), {'% with LOW confidence'}));
    xlabel(strcat({'Date '},datestr(rr(1,1:6),'mm/dd/yyyy'),{' Time'}));ylabel('Gap (in Low) and RR Int.(ms)');
    %}

end