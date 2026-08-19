function s = s_per_ml(known,date_sheet,n_trials)
% AUDV 20130218
% s = s_per_hit(50,1000), I wanna give to my monkey 50ml over 1000 trials.

ms_cal = xlsread('Calibration.xlsx', num2str(date_sheet), 'B3:P3');
ml_cal = xlsread('Calibration.xlsx', num2str(date_sheet), 'B7:P7');
p = polyfit(ms_cal,ml_cal,1);
s = ((known - p(2))/p(1)/n_trials)/1000;
if known <= 0, s = 0; end
end