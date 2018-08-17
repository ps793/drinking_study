%% heatmap for pairwised correlation
map_type = 1; %2,3
sorted = true;
abs_sum = true;

p_corr = corr(double(allDataset(:,[10:31,33])));
raw_label = {  'HR','MEAN','MEDIAN','QD','PRCT20','PRCT80',...
                        'VARI','RMSSD','SDSD','NN50','pNN50','NN20','pNN20','LB','MB','HB','LBHB',...
                        'SDANN','LF','HF','LFHF','BR','MV'};
if(sorted)
    sum_p = sum(p_corr);
    if(abs_sum)
        sum_p = sum(abs(p_corr));
    end
    
    [Y,idx ] = sort(sum_p);
    p_corr = corr(double(allDataset(:,idx+9)));
    raw_label = raw_label(idx);
end


figure;

if(map_type == 1)
    colormap('hot')
elseif(map_type == 2)
    range = [1:-0.02:0]';
    range_z = zeros(size(range));
    range_map=[range_z,range,range_z;0,0,0;flipud(range),range_z,range_z];
    colormap(range_map);
else
    range = [1:-0.02:0]';
    range_z = zeros(size(range));
    range_map=[range,range,range;0,0,0;flipud(range),flipud(range),flipud(range)];
    colormap(range_map);
end

imagesc(p_corr)
colorbar
caxis([-1,1])

% label
set(gca,'XTick',[1:23]);
set(gca,'XTicklabel',raw_label);
set(gca,'YTick',[1:23]);
set(gca,'YTicklabel',raw_label);

xtl=get(gca,'XTickLabel');
xt=get(gca,'XTick');    
yt=get(gca,'YTick');  
    
xtextp=xt;                    
ytextp_bottom=ones(1,length(xt))*yt(end)+0.7;
ytextp_top=ones(1,length(xt))*yt(1)-0.7;

text(xtextp,ytextp_bottom,xtl,'HorizontalAlignment','right','rotation',90);
%text(xtextp,ytextp_top,xtl,'HorizontalAlignment','left','rotation',90);

set(gca,'xticklabel','');
%title('Heatmap for Pairwised Correlation');



%% dosage level histogram heatmap
bins=20;

set_Nondrink = allDataset(allDataset.isdrinkday==0,:);
set_Drink = allDataset(allDataset.isdrinking==1,:);
set_Dosage1 = allDataset(allDataset.dosage==1,:);
set_Dosage23 = allDataset(allDataset.dosage==2 |allDataset.dosage==3,:);
set_Dosage456 = allDataset(allDataset.dosage==4 |allDataset.dosage==5 |allDataset.dosage==6,:);

set_VarNames = allDataset.Properties.VarNames;

% figure;j=1;
for i=10:32

%HR
set_MAX = max(double(allDataset(:,i)));
set_MIN = min(double(allDataset(:,i)));
set_Range = set_MIN:(set_MAX-set_MIN)/bins:set_MAX;

Hist1 = histc(double(set_Nondrink(:,i)), set_Range);
set_Freq_Drink1 = Hist1/length(set_Nondrink); 

Hist2 = histc(double(set_Drink(:,i)), set_Range);
set_Freq_Drink2 = Hist2/length(set_Drink);

Hist3 = histc(double(set_Dosage1(:,i)), set_Range);
set_Freq_Drink3 = Hist3/length(set_Dosage1);

Hist4 = histc(double(set_Dosage23(:,i)), set_Range);
set_Freq_Drink4 = Hist4/length(set_Dosage23);

Hist5 = histc(double(set_Dosage456(:,i)), set_Range);
set_Freq_Drink5 = Hist5/length(set_Dosage456);


hist = [set_Freq_Drink1,set_Freq_Drink2,set_Freq_Drink3,set_Freq_Drink4,set_Freq_Drink5];
% sum(hist)
figure;
% subplot(2,3,j);j=j+1;
colormap('bone')
imagesc(flipud(hist))
colorbar

set(gca,'XTick',[1:5]);
set(gca,'XTicklabel',{'NonDrink','AllDrink','Dosage1','Dosage23','Dosage456'});
set(gca,'YTick',[1:bins+1]);
set(gca,'YTicklabel',fliplr(set_Range));
ylabel('Probability in each bag');
title(strcat(type,{': Histo-Heatmap at diff. Dosage Levels for '},set_VarNames(i)));

end


%% comparing features distribution via histograms
bins=22;
plotOne = true;

set_Nondrink = d(d.isdrinkday==0,:);
set_Drink = d(d.isdrinking==1,:);

set_VarNames = d.Properties.VarNames;

if(plotOne); figure;j=1; end
for i=[10:31,33]

%HR
set_MAX = max(double(d(:,i)));
set_MIN = min(double(d(:,i)));
set_Range = set_MIN:(set_MAX-set_MIN)/bins:set_MAX;

if(~plotOne); figure; 
else subplot(6,4,j);j=j+1; end
histogram(double(set_Nondrink(:,i)),set_Range, 'FaceAlpha', 0.2, 'EdgeColor', 'r', 'FaceColor','r')
hold on
histogram(double(set_Drink(:,i)),set_Range, 'FaceAlpha', 0.2, 'EdgeColor', 'g', 'FaceColor','g')
leg = legend('Non-Drink','Drink');
set(leg,'FontSize',5);

ylabel('Number');
title(strcat(type,{': Distribution of '},set_VarNames(i)));



end
