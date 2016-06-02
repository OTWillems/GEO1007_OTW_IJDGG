%% GEO1007 - Creating SVG Figures of the usage of the Buildings at the TU Delft Campus

close all; clear all; clc;

%-- Created by IJ.D.G. Groeneveld and O.T. Willems

%% Import dummy data

shape = struct2table(shaperead('SHP\CBS_wijk_Delft.dbf'));

%% SLD xml start

SLD = '<?xml version="1.0" encoding="UTF-8"?><StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.1.0/StyledLayerDescriptor.xsd" xmlns:se="http://www.opengis.net/se"><NamedLayer><se:Name>Building Statistics</se:Name><UserStyle><se:Name>Building Statistics</se:Name><se:FeatureTypeStyle>';

%% Loop over the data

for i = 1:length(table2array(shape(:,1)));
    wkcode = char(table2array(shape(i,5)));

    if table2array(shape(i,16)) > 0
        wkname = table2array(shape(i,6));
        data = [table2array(shape(i,16)) table2array(shape(i,17)) table2array(shape(i,18)) table2array(shape(i,19)) table2array(shape(i,20))];
        variables = shape.Properties.VariableNames;
        labelst = strrep(variables(16:20),'_',' ');
        explode = ones(1,length(labelst));
        labels = strcat(transpose(labelst),': ',int2str(transpose(data)),'%');
        
        fig = figure('Color', 'white');
        set(fig,'Visible','off');
        h = pie(data, explode);%,labels);
        oldExtents = cell2mat(get(findobj(h,'Type','text'),'Extent')); % numeric array
        
        fig = figure('Color', 'none');
        set(fig,'Visible','off');
        h = pie(data, labels);%explode, labels);
        title(wkname);
        titlepos = get(gca,'Title');
        set(titlepos,'Position',get(titlepos,'Position') - [0 -0.1 0]);
        
        hText = findobj(h,'Type','text');
        newExtents = cell2mat(get(hText,'Extent')); % numeric array
        width_change = newExtents(:,3)-oldExtents(:,3);
        signValues = sign(oldExtents(:,1));
        offset = signValues.*(width_change/2);
        textPositions = cell2mat(get(hText,{'Position'})); % numeric array
        textPositions(:,1) = textPositions(:,1) + offset; % add offset
        for j = 1:length(hText) 
            hText(j).Position = textPositions(j,:);
        end
        
        saveas(fig, ['SVG\chart_' wkcode], 'svg');
        size = 60;
        rule = strcat('<se:Rule><se:Name>',wkcode,'</se:Name><se:Description><se:Title>',wkcode,'</se:Title></se:Description><ogc:Filter xmlns:ogc="http://www.opengis.net/ogc"><ogc:PropertyIsEqualTo><ogc:PropertyName>',variables(5),'</ogc:PropertyName><ogc:Literal>',wkcode,'</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter><se:PointSymbolizer uom="http://www.opengeospatial.org/se/units/metre"><se:Graphic><se:ExternalGraphic><se:OnlineResource xlink:type="simple" xlink:href="./SVG/chart_',wkcode,'.svg"/><se:Format>image/svg+xml</se:Format></se:ExternalGraphic><se:Size>',int2str(size),'</se:Size></se:Graphic></se:PointSymbolizer></se:Rule>');
        SLD = strcat(SLD,rule);
    else
        fig = figure('Color', 'b');
        set(fig,'Visible','off');
        saveas(fig, ['SVG\chart_' wkcode], 'svg');
    end
end

%% Finalize SLD

SLD = strcat(SLD,'</se:FeatureTypeStyle></UserStyle></NamedLayer></StyledLayerDescriptor>');
fid = fopen('CBS_Pie.sld','wt');
fprintf(fid,'%s',char(SLD(1)));
fclose(fid);
