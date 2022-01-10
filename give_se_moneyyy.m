function give_se_moneyyy(runpath)

% get performance for bonus calculation

%% which money

perfect_95 = 10;
isok_90 = 7;
solala_85 = 4;

%% path
where = dir(runpath);
where = where(~ismember({where.name},{'.' '..'}));

%%
perf = struct();

for r = 1:length(where)
    
    runpath_run = [runpath filesep where(r).name];
    
    load(runpath_run);
%    trial(end) = [];
    gudgemacht = sum ([trial.success]);
    wieviel = length([trial.success]);
    performance = gudgemacht/wieviel*100;
    
    perf(r).run = r;
    perf(r).gudgemacht = gudgemacht;
    perf(r).wieviel = wieviel;
    perf(r).performance = gudgemacht/wieviel * 100;
    
        if performance >= 94
            perf(r).getrich = perfect_95;
            
        elseif performance >= 89
            perf(r).getrich = isok_90;
            
        elseif performance >= 84
            perf(r).getrich = solala_85;
            
        end
      
end


r = r +1;

perf(r).run = 99;
perf(r).gudgemacht =    sum([perf.gudgemacht]);
perf(r).wieviel =       sum([perf.wieviel]);
perf(r).performance =  sum([perf.gudgemacht]) / sum([perf.wieviel]) * 100;

if perf(r).performance >= 95
    perf(r).getrich = perfect_95;
    
elseif perf(r).performance >= 90
    perf(r).getrich = isok_90;
    
elseif perf(r).performance >= 85
    perf(r).getrich = solala_85;
    
end

disp('Am I rich?');
struct2table(perf)

