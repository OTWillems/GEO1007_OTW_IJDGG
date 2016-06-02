%% GEO1007 - Creating SVG Figures of the usage of the Buildings at the TU Delft Campus

close all; clear all; clc;

%-- Created by IJ.D.G. Groeneveld and O.T. Willems

%% Import dummy data and (pre)processing of the data

data = xlsread('DUMMY_DATA.xlsx');
[num,txt,raw] = xlsread('DUMMY_DATA.xlsx'); dates = datenum(txt(2:183,2));
unidatenum = unique(dates);
for j = 1:length(dates)
    for k = 1:length(unidatenum)
        if unidatenum(k)==dates(j)
            dates(j) = k;
        end
    end
end
headers = txt(1,:);

SLD = '<?xml version="1.0" encoding="UTF-8"?><StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.1.0/StyledLayerDescriptor.xsd" xmlns:se="http://www.opengis.net/se"><NamedLayer><se:Name>Building Statistics</se:Name><UserStyle><se:Name>Building Statistics</se:Name><se:FeatureTypeStyle>';

bno = unique(data(:,1));
datumxlabel = unique(txt(2:183,2));
% IMPORTANT use the correct formatIn depending on language of the OS
formatIn = 'dd-m-yyyy';
%formatIn = 'dd/m/yyyy';

str = datenum(datumxlabel,formatIn);
% IMPORTANT use the correct formatIn depending on language of the OS
formatOut = 'dd-mm';
%formatOut = 'dd/mm';
strn = cellstr(datestr(str,formatOut,'local'));

week = accumarray(data(:,1),dates(:,1),[],@(n){n});
reg = accumarray(data(:,1),data(:,3),[],@(n){n});
irreg = accumarray(data(:,1),data(:,4),[],@(n){n});

%% Creating the SVG figures and the corresponding SLD file

for i = transpose(bno) 
    bnodata = [week{i}, reg{i}, irreg{i}]; % make 3 dependable on for loop and run figure on bnodata
    bnostring = num2str(i);
%% Create y-mirrored bar charts, save them as SVG and create SLD rule

g = real([log10(bnodata(:,2)) -log10(bnodata(:,3))]);

close all
f = figure('Color','none');
set(f,'Visible','off');
ax1 = subplot(2,1,1,'XTickLabel',[]);
bar(bnodata(:,1),g.*(g>0),'stacked','g')
gt = num2str(10.^(g(:,1)));
text(1:length(g),g(:,1),num2str(10.^(g(:,1))),'VerticalAlignment','bottom','HorizontalAlignment','center','fontsize',8)
ylim(ax1, [0 log10(10000)]);
ax1.YTick = [0 1 2 3 4 5];
ax1.YTickLabel = {'0','10^{1}','10^{2}','10^{3}','10^{4}'};
title(['Usage of building ' bnostring])
ylabel('# Users regular hours')
set(gca,'Color','none');

%--
ax2 = subplot(2,1,2,'XTickLabel',[]);
bar(bnodata(:,1),g.*(g<0),'stacked','y')
labels = arrayfun(@num2str,(10.^(abs(real(g(:,2))))),'uniform',false);
htext = text(1:length(g),g(:,2),labels);
set(htext, 'VerticalAlignment','top','HorizontalAlignment','center','fontsize',8);
ylim(ax2,[-log10(10000) 0]);
ax2.YTick = [-4 -3 -2 -1 0];
ax2.YTickLabel = {'10^{4}','10^{3}','10^{2}','10^{1}',''};
ylabel('# Users irregular hours')
xlabel('Date')
lim1 = get(ax1,'YLim');
lim2 = get(ax2,'YLim');
pos = get(ax2,'position');
maxh = 1-2*pos(2);
posh = maxh*sum(abs(lim2))/sum(abs(lim1)+abs(lim2));
set(ax2,'position',[pos(1:3) posh])
set(ax1,'position',[pos(1) pos(2)+posh pos(3) maxh-posh])

%-- Set the x-axis labels
ax2.XTick = [transpose(dates(1:7))];
labels = [strn(1);strn(2);strn(3);strn(4);strn(5);strn(6);strn(7)];
ax2.XTickLabel = labels;
set(gca,'Color','none');

%% Save figures as SVG
saveas(f, ['SVG\chart_' bnostring], 'svg');

%% SLD rule
size = 70;
rule = strcat('<se:Rule><se:Name>',int2str(i),'</se:Name><se:Description><se:Title>',int2str(i),'</se:Title></se:Description><ogc:Filter xmlns:ogc="http://www.opengis.net/ogc"><ogc:PropertyIsEqualTo><ogc:PropertyName>',headers(1),'</ogc:PropertyName><ogc:Literal>',int2str(i),'</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter><se:PointSymbolizer uom="http://www.opengeospatial.org/se/units/metre"><se:Graphic><se:ExternalGraphic><se:OnlineResource xlink:type="simple" xlink:href="./SVG/chart_',int2str(i),'.svg"/><se:Format>image/svg+xml</se:Format></se:ExternalGraphic><se:Size>',int2str(size),'</se:Size></se:Graphic></se:PointSymbolizer></se:Rule>');
SLD = strcat(SLD,rule);

end

SLD = strcat(SLD,'</se:FeatureTypeStyle></UserStyle></NamedLayer></StyledLayerDescriptor>');
fid = fopen('test.sld','wt');
fprintf(fid,'%s',SLD{1});
fclose(fid);