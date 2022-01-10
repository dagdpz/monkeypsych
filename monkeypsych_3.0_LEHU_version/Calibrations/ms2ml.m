function desired = ms2ml(known, date_sheet, toplot, ml2ms)
%  date_of_calibration setup voltage
%  ms2ml(.12,'20131106_2_6_5_V',1,1)
%  20131106_1_6_5_V  20131106_2_6_5_V  20131108_1_11_6_V  20131108_2_11_3_V 20140410_2_11_3_V

if nargin < 3,
    toplot = 0;
end
if nargin < 4,
    ml2ms = 0;
end

cal_date = num2str(date_sheet);
ms_cal = xlsread('Calibration.xlsx', cal_date, 'B3:P3');
ml_cal = xlsread('Calibration.xlsx', cal_date, 'B7:P7');
p = polyfit(ms_cal,ml_cal,1); % linear calibration

if ml2ms, 
    idx_cal = find(known == ml_cal);
    if ~isempty(idx_cal),
        desired = ms_cal(idx_cal);
    else
        desired = (known - p(2))/p(1);
    end
else % ms2ml, default
    idx_cal = find(known == ms_cal);
    if ~isempty(idx_cal),
        desired = ml_cal(idx_cal);
    else
        desired = p(1)*known + p(2);
    end
end

if desired < 0, desired = 0; end;

if toplot,
    plot(ms_cal,ml_cal,'o'); hold on;
    refline(p(1),p(2));
    if ml2ms
    plot(desired,known,'ro');
    else
        plot(known,desired,'ro');
    end
     title(sprintf('Cal for %s p(1):%.4f p(2):%.4f',num2str(cal_date),p(1),p(2)));
end



