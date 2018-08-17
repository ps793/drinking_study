function RRPlot(user,survey,rrInitial, flagRRLowConf,flagRRExtreme,flagRROutlier,rrMeanIn1m, rrStdIn1m,flagRRTooFew, flagRRAct,accDatetimeUni,accStdIn10s)
% this function is to plot features
%configuration
    plotInOne = true;
    saveFig = false;

%
    rr = rrInitial;
    if(isempty(rr)); return; end
    
%% plot intermediate result graph
    figure;
    set(gcf, 'position', [0 50 1000 500]);
    
% low confidence
    if plotInOne subplot(2,3,1); else figure; end
    plot(datenum(rr(flagRRLowConf==0,1:6)), rr(flagRRLowConf==0,7),'r.');
    hold on;
    plot(datenum(rr(flagRRLowConf==1,1:6)), rr(flagRRLowConf==1,7),'.');
    datetick('x',15);
    title(strcat({'#'},user, {' RR Int. : '},{'with LOW Conf.'}));%num2str(round(percent*100,2)), {'% with LOW confidence'}));
    xlabel(strcat({'Date '},datestr(rrInitial(1,1:6),'mm/dd/yyyy'),{' Time'}));ylabel('LOW Conf.(in Red) and RR Int.(ms)');
    
    rr = rr(flagRRLowConf==1,:);
    if(isempty(rr)); return; end
    
% extreme value
    if plotInOne subplot(2,3,2); else figure; end
    plot(datenum(rr(flagRRExtreme==1,1:6)), rr(flagRRExtreme==1,7),'.');
    hold on;
    plot(datenum(rr(flagRRExtreme==0,1:6)), rr(flagRRExtreme==0,7),'r.');
    datetick('x',15);
    title(strcat({'#'},user, {' RR Int. : '},{'with Extreme Val.'}));%num2str(round(percent*100,2)), {'% with LOW confidence'}));
    xlabel(strcat({'Date '},datestr(rrInitial(1,1:6),'mm/dd/yyyy'),{' Time'}));ylabel('EX. Value(in Red) and RR Int.(ms)');

    rr = rr(flagRRExtreme==1,:);
    if(isempty(rr)); return; end
    
% outlier
    if plotInOne subplot(2,3,3); else figure; end
    plot(datenum(rr(flagRROutlier==1,1:6)), rr(flagRROutlier==1,7),'.');
    hold on;
    plot(datenum(rr(flagRROutlier==0,1:6)), rr(flagRROutlier==0,7),'r.');
    %
    rrDatetimeCtrl=[rr(:,1:5),zeros(size(rr(:,6)))];
    [rrDatetimeUni,IA]=unique(rrDatetimeCtrl,'rows');
    plot(datenum(rrDatetimeUni),rrMeanIn1m,'g');
    plot(datenum(rrDatetimeUni),rrStdIn1m);
    %
    datetick('x',15);
    title(strcat({'#'},user, {' RR Int. : '},{'with Outlier'}));%num2str(round(percent*100,2)), {'% with LOW confidence'}));
    xlabel(strcat({'Date '},datestr(rrInitial(1,1:6),'mm/dd/yyyy'),{' Time'}));ylabel('RR Interval (s)');

    rr = rr(flagRROutlier==1,:);
    if(isempty(rr)); return; end
    
% too few
    if plotInOne subplot(2,3,4); else figure; end
    plot(datenum(rr(flagRRTooFew==1,1:6)), rr(flagRRTooFew==1,7),'.');
    hold on;
    plot(datenum(rr(flagRRTooFew==0,1:6)), rr(flagRRTooFew==0,7),'r.');
    datetick('x',15);
    title(strcat({'#'},user, {' RR Int. : '},{'with Too Few'}));%num2str(round(percent*100,2)), {'% with LOW confidence'}));
    xlabel(strcat({'Date '},datestr(rrInitial(1,1:6),'mm/dd/yyyy'),{' Time'}));ylabel('Too Few (in Red) and RR Int.(ms)');

    rr = rr(flagRRTooFew==1,:);
    if(isempty(rr)); return; end
    
% labeling with activity
    if plotInOne subplot(2,3,5); else figure; end
    plot(datenum(rr(:,1:6)), rr(:,7),'.');
    hold on;
    plot(datenum(rr(flagRRAct==1,1:6)), rr(flagRRAct==1,7),'r.');

    plot(datenum(accDatetimeUni),accStdIn10s,'.');
    if(~isempty(strfind(user,'hexo'))) thres=0.035; else thres=35; end
    plot(datenum(accDatetimeUni(accStdIn10s>thres,:)),accStdIn10s(accStdIn10s>thres),'.');
    
    datetick('x',15);
    title(strcat({'#'},user, {' RR Int. : '},{'with Activity'}));%num2str(round(percent*100,2)), {'% with LOW confidence'}));
    xlabel(strcat({'Date '},datestr(rrInitial(1,1:6),'mm/dd/yyyy'),{' Time'}));ylabel('Activity Indicators and RR (s)');
    
% initial and final
    if plotInOne subplot(2,3,6); else figure; end
    plot(datenum(rrInitial(:,1:6)), rrInitial(:,7),'r.');
    hold on;
    plot(datenum(rr(:,1:6)), rr(:,7),'.');
    datetick('x',15);
    percent = length(rr)/length(rrInitial);
    %title(strcat({'#'},user, {' RR Int. : '},{'with Final '} ,num2str(100-round(percent*100,2)), {'% removed'}));
    title(strcat({'#'},user, {' RR Int. : '},{'with Final'}));%num2str(round(percent*100,2)), {'% with LOW confidence'}));
    xlabel(strcat({'Date '},datestr(rrInitial(1,1:6),'mm/dd/yyyy'),{' Time'}));ylabel('All Removed (in Red) and RR Int.(ms)');
 
% save intermediate step
    if(saveFig)
        name = strcat('i_',user,'_',datestr(rrInitial(1,1:6),'mm-dd-yyyy'));
        saveas(gcf,strcat('.\fig\',name,'.fig'));
        %print(gcf,'-dpng','.\slide0304\abc.png');

        frame=getframe(gcf);                                     
        imwrite(frame.cdata,strcat('.\png\',name,'.png')); 
    end
    
%% plot initial and final in individal graph

% plot
    figure;
    set(gcf, 'position', [0 50 1000 500]);
    plot(datenum(rrInitial(:,1:6)), rrInitial(:,7),'r.');
    hold on;
    plot(datenum(rr(:,1:6)), rr(:,7),'.');
    
    datetick('x',15);
    percent = length(rr)/length(rrInitial);
    %title(strcat({'#'},user, {' RR Int. : '},{'with Final'}));%num2str(round(percent*100,2)), {'% with LOW confidence'}));
    title(strcat({'#'},user, {' RR Int. : '},{'with '} ,num2str(100-round(percent*100,2)), {'% removed'}));
    xlabel(strcat({'Date '},datestr(rrInitial(1,1:6),'mm/dd/yyyy'),{' Time'}));ylabel('All Removed (in Red) and RR Int.(ms)');
 
% label survey
    if(isempty(survey)); return; end
 
    dtStart = datenum(rrInitial(1,1:6));
    dtEnd = datenum(rrInitial(end,1:6));
    dtSurvey = datenum(survey(:,3));
    seq = dtSurvey > dtStart & dtSurvey < dtEnd;
    dtSurvey = dtSurvey(seq);
    
    surveyID = dtSurvey(strcmp(survey(seq,2),'ID'));
    surveyDF = dtSurvey(strcmp(survey(seq,2),'DF'));
    surveyRS = dtSurvey(~cellfun(@isempty,regexp(survey(seq,2),'^RS')));
    
    if(~isempty(strfind(user,'hexo'))); yy=[0,4]; else yy=[100,2000]; end
    legendHandle=[];
    legendColor={};
    if(~isempty(surveyID))
        a=line([surveyID,surveyID]',yy,'color','r');
        legendHandle = [legendHandle ; a(1)];
        legendColor = [legendColor 'ID'];
    end
    if(~isempty(surveyDF))
        b=line([surveyDF,surveyDF]',yy,'color','g');
        legendHandle = [legendHandle ; b(1)];
        legendColor = [legendColor 'DF'];
    end
    if(~isempty(surveyRS))
        c=line([surveyRS,surveyRS]',yy,'color','b');
        legendHandle = [legendHandle ; c(1)];
        legendColor = [legendColor 'RS'];
    end

% legend
    %legend([a(1);b(1)],{'ID','DF'});
    if(~isempty(legendHandle)); legend(legendHandle,legendColor); end
    
% save initial and final plot
    if(saveFig)
        name = strcat(user,'_',datestr(rrInitial(1,1:6),'mm-dd-yyyy'));
        saveas(gcf,strcat('.\fig\',name,'.fig'));
        %print(gcf,'-dpng','.\slide0304\abc.png');

        frame=getframe(gcf);                                     
        imwrite(frame.cdata,strcat('.\png\',name,'.png')); 
    end

end