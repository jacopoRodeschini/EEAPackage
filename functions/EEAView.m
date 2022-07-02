function EEAView(Metadata, options)
% View station in geomap & #station for pollutant
% Author: Jacopo Rodeschini (UniBg Researcher)


% ISSUES 
% La funzione EEAView non modifica il sistema di riferimento dello shape
% file e quindi dei poligoni. -> modificare in EPSG:4979 (WGS84)
% (stessa dei dati).

% Adesso il sistema usa la poriezione ETRS89-extended / LAEA Europe che è
% quella utilizzada dallo shape file europeo di Eurostat. Nella seconda
% versione dare la possibilità di specificare la proiezione come parametro
% di options e mettere come default WGS84
% Inoltre dare una serie di warning nel caso in cui si stia utilizzando una
% proiezione non cmpatibile. Oppure non si riesca ad esereguire una
% modifica della proiezione. 

%%

arguments
    Metadata(:,18) table
    options.shapefile(1,1) = "./ShapeFile/ShapeFIle_EU_NUTS3/NUTS_RG_03M_2021_3035.shp";
    options.delta(1,1)  = 0.7;
    
    % Detail mode - Enable (Default - Lombardy case)
    options.detail(1,1) = true;
    % Detail mode - Area to display
    options.NUTS_ID(1,1) = "ITC4"; % NUTS_ID :: "Type = 1" :: ("DE9"=lower saxony;"ITC4"=Lombary)
    % Detail mode - Regions that compose the area of options.NUTS_ID
    %options.Region = ["Lombardia"]; % distretti governati (region % Lombardy)
    % Detail mode - buffer for options.NUTS_ID;
    options.Buffer(1,1) = "./ShapeFile/Buffer/Lombardia/LombardyBuffer.shp";
    
end

[~,index] = unique(Metadata.IDStation);
temp = Metadata(index,:);

%% Read ShapeFile
if isfile(options.shapefile)
    S = shaperead(options.shapefile); % ETRS89-extended / LAEA Europe
    info = shapeinfo(options.shapefile);
    proj = info.CoordinateReferenceSystem;
else
    disp(sprintf("Error - Shapefile not fount \npath .shp: %s", options.shapefile))
    return
end

%% Add buffer in shape file

if isfile(options.Buffer)
    buffer = shaperead(options.Buffer); % (lat-lon WGS84 projection)
    info = shapeinfo(options.Buffer);
    
    % proj = projcrs(3035); % ETRS89-extended / LAEA Europe project
    [X, Y] = projfwd(proj,[buffer.Y],[buffer.X]);
    
    % Add buffer in S struct % NUTS_ID = "Buff", LEVL_CODE = 5;
    nutsid = string(deblank(vertcat({S.NUTS_ID})')) == options.NUTS_ID;
    S = [S; S(nutsid,:)];
    S(end).BoundingBox = buffer.BoundingBox;
    S(end).X = X;
    S(end).Y = Y;
    S(end).NUTS_ID = "Buff";
    S(end).LEVL_CODE = 5; % Buffer level code;
    
else
    disp(sprintf("Error - Buffer not fount \npath .shp: %s", options.Buffer))
    return
end

eea_zone =  categorical({'rural','rural-nearcity','rural-regional', ...
    'rural-remote',  'suburban', 'urban'});

eea_type = categorical({'background','industrial','traffic'});

RGB = [1 0 0;1 0 1;0 0 1;1 1 0;0 1 0;0 1 1];
RGBT = [1 0 0;0 1 0;0 1 1];

%% Check station in buffer

inx = string(deblank(vertcat({S.CNTR_CODE})')) == string(unique(temp.Countrycode));
reg = cell2mat(vertcat({S.LEVL_CODE})') == 2;
prov = cell2mat(vertcat({S.LEVL_CODE})') == 3;

[lat_reg, lon_reg] = projinv(proj,[S(inx & reg).X],[S(inx & reg).Y]);
[lat_prov, lon_prov] = projinv(proj,[S(inx & prov).X],[S(inx & prov).Y]);

% GEO MAP
figure;
geoscatter(temp.Latitude,temp.Longitude,'c','filled','Marker','o','MarkerEdgeColor','b');
hold on
geolimits([min(temp.Latitude)-options.delta max(temp.Latitude)+options.delta],...
    [min(temp.Longitude)-options.delta max(temp.Longitude)+options.delta]);
geoplot(lat_prov,lon_prov,'LineWidth',1, 'Color','r')
geoplot(lat_reg,lon_reg,'LineWidth',3, 'Color','b')
legend({sprintf("Total stations: %d",length(temp.Latitude)),'Region (NUTS-2)','Province (NUTS-3)'})
title('Pollutant Station')
subtitle('Download from EEA service')


%% Detail mode - Enable
% plot more detail graph

if(options.detail == true)
    
    
    %% Detail graph for full metadata stations
    % In this context we dosent consider options.NUTS_ID, options.regions
    % and options.Buffer. The plot cover all station in metadata table
    
    % PLOT:
    % - 1) Scatter plot by station zone group
    % - 2) Scatter plot by station arpa type group
    
    
    % 1) Scatter plot by station zone group
    
    %     inx = string(deblank(vertcat({S.CNTR_CODE})')) == string(unique(temp.Countrycode));
    %     reg = cell2mat(vertcat({S.LEVL_CODE})') == 2;
    %     prov = cell2mat(vertcat({S.LEVL_CODE})') == 3;
    %
    %     [lat_reg, lon_reg] = projinv(proj,[S(inx & reg).X],[S(inx & reg).Y]);
    %     [lat_prov, lon_prov] = projinv(proj,[S(inx & prov).X],[S(inx & prov).Y]);
    %
    %     eea_zone =  categorical({'rural','rural-nearcity','rural-regional', ...
    %        'rural-remote',  'suburban', 'urban'});
    %
    %     [~,inx] = ismember(temp.ARPA_zone, eea_zone);
    %
    %     tab = tabulate(inx);
    %     tab(tab(:,2)==0,:)=[];
    %
    %     zone_type = cell(size(tab,1),1);
    %     figure;
    %     for i = 1:length(arpa_zone)
    %         geoscatter(temp.Latitude(inx == i),temp.Longitude(inx == i),[],RGB(i,:),'filled','Marker','o','MarkerEdgeColor','k');
    %         geolimits([min(temp.Latitude)-options.delta max(temp.Latitude)+options.delta*2.5],...
    %             [min(temp.Longitude)-options.delta max(temp.Longitude)+options.delta]);
    %         zone_type{i} = sprintf("Type %s - %d", string(arpa_zone(tab(i,1))),tab(i,2));
    %         hold on
    %     end
    %     geoplot(lat_reg,lon_reg,'.b',lat_prov,lon_prov,'-r')
    %
    %
    %     legend({sprintf("Total stations: %d",length(temp.Latitude)),'Region','Province'})
    %     title(sprintf('Station Type Classification - Total Station %d',sum(tab(:,2))));
    %
    %
    %
    %
    %     % 2) Scatter plot by station arpa type group
    %     arpa_type = unique(temp.ARPA_stat_type);
    %     [~,inx] = ismember(temp.ARPA_stat_type, arpa_type);
    %
    %     tab = tabulate(inx);
    %     tab(tab(:,2)==0,:)=[];
    %
    %
    %     st_type = cell(size(tab,1),1);
    %     st_zone = figure;
    %
    %     for i = 1:length(arpa_type)
    %         geoscatter(temp.Latitude(inx == i),temp.Longitude(inx == i),[],RGBT(i,:),'filled','Marker','o','MarkerEdgeColor','k');
    %         geolimits([min(temp.Latitude)-options.delta max(temp.Latitude)+options.delta*2.5],...
    %             [min(temp.Longitude)-options.delta max(temp.Longitude)+options.delta]);
    %         st_type{i} = sprintf("Type %s - %d", string(arpa_type(tab(i,1))),tab(i,2));
    %         hold on
    %     end
    %
    %     title(sprintf('Station Type Classification - Total Station %d',sum(tab(:,2))));
    
    
    %% Scatter plot only for detail regions
    % the options.NUTS_ID is more greather then single region,
    % For example, Lower saxony is comoserd by more regions but has i'it
    % own NUTS_ID;
    % in this contex we consider a buffer regions specified by: options.Buffer
    
    % PLOT:
    % - 1) Only Detail region without both station and buffer;
    % - 2) Only Detail region with buffer and without stations;
    % - 3) Only Detail region with buffer and stations;
    % - 4) Only Detail region with buffer and stations divide by type and
    % area
    % - 5) Bar grapth for type of stations;
    
    % 1) Only Detail region without both station and buffer
    nutsid = string(deblank(vertcat({S.NUTS_ID})')) == options.NUTS_ID;
    name = string(deblank(S(nutsid).NUTS_NAME));
    [lat, long] = projinv(proj,[S(nutsid).X],[S(nutsid).Y]);
    
    
    figure
    geoplot(lat,long,'LineWidth',2, 'Color','b')
    title(sprintf('%s - regional borders',name))
    legend({'Region'});
    
    figure
    geoplot(lat,long,'LineWidth',2, 'Color','b')
    geobasemap landcover
    title(sprintf('%s - regional borders',name))
    %subtitle('basemap - landcover')
    legend({'Lombardy borders'});
    
    figure
    geoplot(lat,long,'LineWidth',2, 'Color','b')
    geobasemap topographic
    title(sprintf('%s - regional borders',name))
    subtitle('basemap - topographic')
    legend({'Region'});
    
    figure
    geoplot(lat,long,'LineWidth',2, 'Color','b')
    geobasemap satellite
    title(sprintf('%s - regional borders',name))
    subtitle('basemap - satellite')
    legend({'Region'});
    
    % 2) Only Detail region with buffer and without stations;
    buffid = string(deblank(vertcat({S.NUTS_ID})')) == "Buff";
    [lat_buf, long_buf] = projinv(proj,[S(buffid).X],[S(buffid).Y]);
    
    figure
    geoplot(lat_buf,long_buf,'LineWidth',2, 'Color','b')
    title(sprintf('%s - regional borders with buffer',name))
    legend({'Region and buffer'});
    
    figure
    geoplot(lat_buf,long_buf,'LineWidth',2, 'Color','b')
    geobasemap landcover
    title(sprintf('%s - regional borders with neighbors area',"Lombary"))
    %subtitle('basemap - landcover')
    legend({'borders with neighbors area'});
    
    figure
    geoplot(lat_buf,long_buf,'LineWidth',2, 'Color','b')
    geobasemap topographic
    title(sprintf('%s - regional borders with buffer',name))
    subtitle('basemap - topographic')
    legend({'Region and buffer'});
    
    figure
    geoplot(lat_buf,long_buf,'LineWidth',2, 'Color','b')
    geobasemap satellite
    title(sprintf('%s - regional borders with buffer',name))
    subtitle('basemap - satellite')
    legend({'Region and buffer'});
    
    % 3) Only Detail region with buffer and stations (divided by type / area);
    
    % Create polyshape from Options.NUTS_ID
    regionPoly = polyshape([S(nutsid).X],[S(nutsid).Y]); % region poligon
    bufferPoly = polyshape([S(buffid).X],[S(buffid).Y]); % buffer poligon
    
    % check station inside poly
    % poly -> (X,Y) proietions, CRS :: ETRS89-extended / LAEA Europe
    % station -> (lat,lon) proiettions, CRS :: ETRS89-extended / LAEA Europe
    
    [X, Y] = projfwd(proj,temp.Latitude,temp.Longitude); % create (X,Y) projections for station
    
    % station inside a region
    inx_reg = isinterior(regionPoly,X,Y);
    
    % staion inside a buffer
    inx_buf = isinterior(bufferPoly,X,Y);
    
    %     plot(regionPoly);
    %     hold on
    %     plot(X(inx),Y(inx),'o');
    
    
    
    figure
    geoscatter(temp.Latitude(inx_reg),temp.Longitude(inx_reg),'c','filled','Marker','o','MarkerEdgeColor','b');
    hold on
    geoscatter(temp.Latitude(inx_buf),temp.Longitude(inx_buf),'g','filled','Marker','s','MarkerEdgeColor','r');
    geoplot(lat_buf,long_buf,'LineWidth',2, 'Color','b')
    geobasemap landcover
    title(sprintf('%s - Station Type classification',name))
    subtitle(sprintf('Total station %d',sum(inx_buf) + sum(inx_reg)))
    legend({sprintf('Regional station - %d',sum(inx_reg)),...
        sprintf('Buffer station - %d', sum(inx_buf)), 'Region and buffer'})
    
    % 4) Only Detail region with buffer and stations divide by type and
    % area
    
    % type
    
    inx_glob = inx_reg | inx_buf;
    
    [~,ind] = ismember(temp.ARPA_stat_type(inx_glob), eea_type);
    tab = tabulate(ind);
    tab(tab(:,2)== 0,:) = [];
    
    leg = cell(size(tab,1),1);
    figure;
    for i = 1:length(leg)
        %inx = temp.ARPA_stat_type(inx_glob) == type_reg_buf(i);
        inx = ind == tab(i,1);
        geoscatter(temp(inx_glob,:).Latitude(inx),temp(inx_glob,:).Longitude(inx),[],RGBT(tab(i,1),:),'filled','Marker','o','MarkerEdgeColor','k');
        geolimits([min(temp(inx_glob,:).Latitude)-options.delta max(temp(inx_glob,:).Latitude)+options.delta],...
            [min(temp(inx_glob,:).Longitude)+options.delta max(temp(inx_glob,:).Longitude)-options.delta]);
        leg{i} = sprintf("Type %s - %d", string(eea_type(tab(i,1))),tab(i,2));
        hold on
    end
    geobasemap landcover
    geoplot(lat_buf,long_buf,'LineWidth',2, 'Color','b')
    leg = [leg; {'Region and Buffer'}];
    legend(leg)
    title(sprintf('%s - Station Type classification',name))
    subtitle(sprintf('Total station %d',sum(tab(:,2))))
    
    
    % zone
    
    inx_glob = inx_reg | inx_buf;
    [~,ind] = ismember(temp.ARPA_zone(inx_glob), eea_zone);
    tab = tabulate(ind);
    tab(tab(:,2)== 0,:) = [];
    
    
    leg = cell(size(tab,1),1);
    figure;
    for i = 1:length(leg)
        %inx = temp.ARPA_zone(inx_glob) == type_reg_buf(i);
        inx = ind == tab(i,1);
        geoscatter(temp(inx_glob,:).Latitude(inx),temp(inx_glob,:).Longitude(inx),[],RGB(tab(i,1),:),'filled','Marker','o','MarkerEdgeColor','k');
        geolimits([min(temp(inx_glob,:).Latitude)-options.delta max(temp(inx_glob,:).Latitude)+options.delta],...
            [min(temp(inx_glob,:).Longitude)+options.delta max(temp(inx_glob,:).Longitude)-options.delta]);
        leg{i} = sprintf("Type %s - %d", string(eea_zone(tab(i,1))),tab(i,2));
        hold on
    end
    geoplot(lat_buf,long_buf,'LineWidth',2, 'Color','b')
    geobasemap landcover
    leg = [leg; {'Region and Buffer'}];
    legend(leg)
    title(sprintf('%s - Station Zone classification',name))
    subtitle(sprintf('Total station %d',sum(tab(:,2))))
    
    
    %%  BAR GRAPH
    temp = tabulate(Metadata.IDSensor);
    temp(:,end) = [];
    temp(temp(:,2)== 0,:) = [];
    
    [~,index] = ismember(temp(:,1),Metadata.IDSensor);
    label = string(Metadata.Pollutant(index));
    
    
    figure
    bar(temp(:,2))
    grid minor
    title("Distribution of sensors respect pollutants")
    xticks([1:length(temp)])
    xticklabels(label)
    xtickangle(50)
    legend(sprintf('Total Sensor: %d',sum(temp(:,2))))
    ylabel("Numer of sensor")
    xlabel("Pollutant")
    %print('PollutantSensor','-dpng')
    
    
    % staked bar grapph by sensor type sensor only for region and buffer
    
    [X, Y] = projfwd(proj,Metadata.Latitude,Metadata.Longitude); % create (X,Y) projections for sensor
    
    inx_reg = isinterior(regionPoly,X,Y);
    inx_buf = isinterior(bufferPoly,X,Y);
    
    inx_glob = inx_reg | inx_buf;
    
    region = Metadata(inx_glob,:);
    tab = tabulate(region.IDSensor);
    tab(tab(:,2)== 0,:) = [];
    
    
    stat = grpstats(region,{'IDSensor','ARPA_zone'},[],'DataVars',{'IDSensor'});
    poll = unique(stat.IDSensor);
    
    [~,index] = ismember(poll,region.IDSensor);
    label = region.Pollutant(index);
    
    stk = table('Size',[numel(unique(region.IDSensor)),numel(unique(region.ARPA_zone))],...
        'VariableNames',string(unique(region.ARPA_zone)'),'VariableType',repmat({'double'},numel(unique(region.ARPA_zone)),1));
    
    for i = 1:length(poll)
        temp = stat(stat.IDSensor == poll(i),{'ARPA_zone','GroupCount'});
        stk{i,string(temp.ARPA_zone)} = temp.GroupCount';
    end
    
    figure
    b = bar(stk{:,:},'stacked');
    grid minor
    title(sprintf('%s - distribution of sensors respect pollutants and type',name))
    subtitle(sprintf('Total Sensor: %d',sum(sum(stk{:,:}))))
    xticks([1:numel(poll)])
    xticklabels(label)
    xtickangle(50)
    legend(stk.Properties.VariableNames)
    ylabel("Numer of sensor")
    xlabel("Pollutant")
    ylim([0 max(sum(stk{:,:},2))+5])
    
    
    for i= 1:length(b)-1
        xtips1 = b(i).XEndPoints;
        ytips1 = b(i).YEndPoints;
        labels1 = string(b(i).YData);
        text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
            'VerticalAlignment','baseline')
    end
    
    xtips1 = b(end).XEndPoints;
    ytips1 = b(end).YEndPoints;
    labels1 = string(b(end).YData) + '/(' + string(b(end).YEndPoints)  + ')';
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','baseline')
    
    
    
    
end

end

