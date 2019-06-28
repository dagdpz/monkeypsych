function [dailyStats] = evaluateTrainingDataALL(monkeyName,dataDirIn)
% monkeyName='Cornelius';
% dataDirIn='Z:\Data\Cornelius\20130909';
% Calculate daily performance and print to terminal.
%   2012-04-04: changed to read .mat files for the latest version of the "monkeypsych_reach"
%               output: [Date trials IT hits percent_of_all_trials
%               percent_of_IT] O.D., A.V.
%   2012-02-23: changed to read new data format from monkey_psych in 
%               setup 2
%   2012-01-05: cover specified date range or all dates.
%
%   evaluateTrainingData reads .mat files saved by test_monkey. Mat files
%   must be name like 'Lin2011-12-08_01.mat' and must contain an array
%   'trialInfoXX' (nTrials x [nTrial RT timeHold success]) where XX is the 
%   number of the run, and a strcut array TASK.
%
% INPUT
%   monkeyName: 
%   dataDir:    Path to the data directory NOT including monkey name.
%               E.g. 'D:\Data'.
%   startDate:  (optional)
%   endDate:    List only data from days between start and end date.
%               Specify as 8 digit number (e.g. 20120119) or three element
%               vector (e.g. [2012, 1, 19]). If omitted, all data will be
%               selected. (optional)
%
% OUTPUT
%   dailyStats: training_day x 6 array with columns representing [year, 
%               month, day, trials, hits, hit_rate]
%   dailyTASK:  day x 1 struct array containing TASK struct (as specified
%               in get_monkey_settings) for each training_day. [NOT
%               WORKING]
% 
% d = dir; for i=3:length(dir); movefile(d(i).name,[d(i).name(1:3) d(i).name(6:end)]); end

%% Parameters


%[number]=number_of_folders(dataDirIn,starting_folder,ending_folder);
%startDate=starting_folder;
%endDate=ending_folder;
%f_name=num2str(starting_folder);
%last_two=f_name(end-1:end); 
% for j=1:number
% 
% if nargin<1
%     monkeyName = 'Cornelius';
% end
%     dataDir ='C:\Users\M.Koester\Desktop\LindaNieuw';
%    dataDir =['Y:\Cornelius\' f_name filesep];
%dataDir =[dataDirIn f_name filesep];



% dataDir = [upper(dataDriveLetter) ':/' monkeyName '/'];   % specify data directory
%dataDir = [dataDir filesep];   % specify data directory
if ~isdir(dataDirIn); error('No valid data directory specified'); end

% if nargin < 5
%     y1=2011; m1=01; d1=01;  % start date
%     y2=2020; m2=01; d2=01;  % end date
% elseif numel(startDate)==5;
%     y1=startDate(1); m1=startDate(2); d1=startDate(3);
%     y2=endDate(1);   m2=endDate(2);   d2=endDate(3);
% else
%     y1=floor(startDate/1e4);            % convert 8 digit number to date
%     m1=floor((startDate-y1*1e4)/1e2);
%     d1=startDate-y1*1e4-m1*1e2;
%     y2=floor(endDate/1e4);
%     m2=floor((endDate-y2*1e4)/1e2);
%     d2=endDate-y2*1e4-m2*1e2;
% end


%% 1) Find all available txt files
% List all availabe .txt files from dataDir
% runsAvailable is an (nMatFiles x [year month day run]) array
D = dir(dataDirIn);
runsAvailable = nan(length(D)-2,1);   % preallocate
c = 0;
for i = 3:length(D)
    if strcmp(D(i).name(end-2:end),'mat')   % if .mat file found
        c = c+1;
%         runsAvailable(c,1)  = str2double(D(i).name(4:7));   % year
%         runsAvailable(c,2)  = str2double(D(i).name(9:10));  % month
%         runsAvailable(c,3)  = str2double(D(i).name(12:13)); % day
%         runsAvailable(c,4)  = str2double(D(i).name(15:16)); % run
        runsAvailable(c) = str2double(D(i).name(15:16));
        fnames{c}=D(i).name;
    end
end
%runsAvailable = runsAvailable(1:c,:); % truncate to actual size

%datesAvailable = runsAvailable( logical([1; diff(runsAvailable(:,3))]) ,1:3);   % all dates for which data is availabel (n x [year month day])

% check which dates fall into speficied date range
% isAfter =  (datesAvailable(:,1) > y1 | ...
%             datesAvailable(:,1) == y1 & datesAvailable(:,2) > m1 | ...
%             datesAvailable(:,1) == y1 & datesAvailable(:,2) == m1 & datesAvailable(:,3) >= d1);
% isBefore=  (datesAvailable(:,1) < y2 | ...
%             datesAvailable(:,1) == y2 & datesAvailable(:,2) < m2 | ...
%             datesAvailable(:,1) == y2 & datesAvailable(:,2) == m2 & datesAvailable(:,3) <= d2);        
% withinRange = isAfter & isBefore;
% datesAvailable(~withinRange,:) = [];

%% 2) Loop over all dates for which data is available. For each date loop over all runs.
% dailyStats: (day x [year month day nTrials hitRate])
% nDays = size(datesAvailable,1);
% dailyStats = nan(nDays,8);
% dailyTimeReward = nan(nDays,1);
% dailyWeekDay = repmat(char(0),nDays,3);
%for i = 1:nDays
%     y = datesAvailable(i,1);
%     m = datesAvailable(i,2);
%     d = datesAvailable(i,3);
%runs = runsAvailable(runsAvailable(:,1)==y & runsAvailable(:,2)==m & runsAvailable(:,3)==d,4);

    for r = 1:length(~isnan(runsAvailable));   
        
        %sm20170103: start
        %sm20170103: the above testdoes not what it thinks it does:
        %~isnan([1, 2, 3, 3, NaN, NaN]) =   1     1     1     1     0     0
        %length(~isnan([1, 2, 3, 3, NaN, NaN])) = 6
        if isnan(runsAvailable(r))
            display(['Nominally availabe run ', num2str(r), ' has issues, skipping this...']);
            continue
        end
        %sm20170103: end
        
%       fname = [monkeyName(1:3) num2str(y) '-' num2str(m,'%02d') '-' num2str(d,'%02d') '_' num2str(r,'%02d') '.mat'];

        fid=load([dataDirIn filesep fnames{r}]);
        data=fid.trial;
        
        aborted_state=[data.aborted_state];
        %             indx=find(aborted_state==-1|aborted_state==19|aborted_state>2&aborted_state<6);
        %indx=aborted_state==-1|aborted_state>=3;
        %aborted_state=aborted_state(indx);
        nTrials(r) = max([data.n]);   % current 9 column format
        nHits(r)   = sum([data.success]);
        %aborted_abs=abs(aborted_state./aborted_state);
        nInitiated(r) =sum(aborted_state==-1|aborted_state>=3);
        end

 %   end
    % dailyStats: (day x [year month day nTrials hitRate])
    dailyStats = [sum(nTrials) sum(nInitiated) sum(nHits) round(sum(nHits)/sum(nTrials)*100) round(sum(nHits)/sum(nInitiated)*100)];
    [~, dailyWeekDay(1:3)] = weekday(datenum(str2double(dataDirIn(end-7:end-4)),str2double(dataDirIn(end-3:end-2)),str2double(dataDirIn(end-1:end))));
    
%end

% f_name=num2str(starting_date);
% s_d=f_name(end-1:end);
% num_starting_date=str2num(s_d);
% new_num_s_d=num_starting_date+num_starting_date;
% last_two=num2str(new_num_s_d);
% last_two=last_two+1;




fprintf(['\nDaily stats for ' monkeyName ':\n\n']);
fprintf('\tDate		       trials   IT    hits  percent_of_all_trials        percent_of_IT     \n');
fprintf('\t------------------------------------------------------------------------------------\n');
FDate=str2double(dataDirIn(end-7:end));

%for i = 1:size(dailyStats,1)
    fprintf('\t %d  %s  %d %d %d %d %d  \n', FDate, dailyWeekDay,dailyStats(1),dailyStats(2),dailyStats(3),dailyStats(4),dailyStats(5)) ;
%end
%     last_two=str2num(last_two);
%     last_two=last_two+1;
%     last_two=num2str(last_two);
    clear nTrials
    clear nHits
    clear nInitiated
end