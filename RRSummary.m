function RRSummary(user, survey, rr, rrInitial, fid) % write white list
% this function is to generate white list/black list
    if(isempty(survey)); return; end
 
    dtStart = datenum(rrInitial(1,1:6));
    dtEnd = datenum(rrInitial(end,1:6));
    dtSurvey = datenum(survey(:,3));
    seq = dtSurvey > dtStart & dtSurvey < dtEnd;
    dtSurvey = dtSurvey(seq);
    
    surveyID = dtSurvey(strcmp(survey(seq,2),'ID'));
    surveyDF = dtSurvey(strcmp(survey(seq,2),'DF'));
    surveyRS = dtSurvey(~cellfun(@isempty,regexp(survey(seq,2),'^RS')));
    
    percent = length(rr)/length(rrInitial);
    
% write information
    hasSurvey = ~(isempty(surveyID) & isempty(surveyDF) & isempty(surveyRS));
    
    if(percent > 0.30)
    fprintf(fid,'%s,%d,%d,%d,%f,%d\n',user,rrInitial(1,1:3),percent,hasSurvey);
    end
end