function flagRRExtreme = RRExtremeValue(user, rr)
%remove extreme value
%  1500~300ms

    if(max(rr(:,7))<10)
       upper = 1.5; lower = 0.3 ;
    else
        upper = 1500; lower = 300;
    end

    flagRRExtreme = rr(:,7)>=lower & rr(:,7)<=upper;

end