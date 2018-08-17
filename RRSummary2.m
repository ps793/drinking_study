function RRSummary2(user, survey, rr, rrInitial, fid)
% this function is to generate white list/black list(need to be checked later) 
    if(isempty(rr)); return; end
    
    rrDatetimeCtrl=[rr(:,1:5),zeros(size(rr(:,6)))];
    [rrDatetimeUni,IA]=unique(rrDatetimeCtrl,'rows');
    valid = length(rrDatetimeUni);
    
    rrDatetimeCtrl=[rrInitial(:,1:5),zeros(size(rrInitial(:,6)))];
    [rrDatetimeUni,IA]=unique(rrDatetimeCtrl,'rows');
    total = length(rrDatetimeUni);
    
    fprintf(fid,'%s,%d,%d\n',user,valid,total);
end