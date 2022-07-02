function [DailyData] = SSMHourly2Daily(hData,options)
%%  Creazione dati orari partendo dai dati giornalieri
%   Author: Jacopo Rodeschini (UniBg Researcher)

%   Use of Space Time Model (SSM) with Kalman smoother for recostruct NaN
%   data

arguments
    hData(:,:) timetable = {}; %hourly time series
    options.Threshold(1,1) double = 5;
end

% 1 - Extract timeSeries;
pollutant = hData.Properties.VariableNames;


% 2 - Define a SSM - AR(1) [scalare];
A = [nan];
B = [nan];
C = [1];
D = [1];

mod = ssm(A,B,C,D);

% 3 - Define daily structure

dStart = min(hData.Properties.RowTimes);
dStop =  dateshift(max(hData.Properties.RowTimes),'end','day');

nDays = caldays(between(dStart,dStop,'days'));
VarType = repmat({'double'},length(pollutant),1);

DailyData = timetable('Size',[nDays length(pollutant)],'VariableType',VarType,...
    'TimeStep',days(1),'StartTime',dStart ,'VariableNames',pollutant);
DailyData(:,pollutant) = {nan};


for i = 1:length(pollutant) % for each pollutant
   
    % 4 - Check NaN gap
    % If some day have max(gap) >= 6 drop day and split Time series
    
    % max gap intra-day (foreach day)
    check = retime(hData(:, pollutant(i)),"daily",@(x)...
        sum(diff(find(isnan(x))) == 1));
    
    % 5 - Check threshold
    % DataDrop = Data with nan values
    DateDrop = check(check{:,pollutant(i)} >= options.Threshold,:).Properties.RowTimes; % day -> nan
    
    % 6 - Estimate a SSM with full times series of data
    mhat = estimate(mod,hData{:, pollutant(i)},[1,1],'lb',[0,0],'Display','off');
   
    % 7 - smooth sullo stato xt (= yt) per tutta la serie
    xhat = smooth(mhat,hData{:, pollutant(i)});
    
    % 8 - replace huorly smoothed data (where data is nan)
    inx = isnan(hData{:, pollutant(i)});
    hData{inx, pollutant(i)} = xhat(inx,1);
    
    % 9 - Aggregate by mean function and replace drop days with nan
    temp = retime(hData(:, pollutant(i)),'daily',@mean);
    temp(DateDrop,pollutant(i)) = {nan};
    
    DailyData(temp.Properties.RowTimes,pollutant(i)) = temp(:,pollutant(i)); 
     
end

end







