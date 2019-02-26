function concatinate_trial_matfiles(monkey,main_folder)
%concatinate_trial_matfiles('Cor','D:\Data\Cornelius\20160219')
subfolder_dir=dir([main_folder filesep '*' monkey '*']);
subfolder_isdir=[subfolder_dir.isdir];


subfolder_content={subfolder_dir(subfolder_isdir).name};


for dir_index=1:numel(subfolder_content)
    if ~exist([main_folder filesep subfolder_content{dir_index} '.mat'],'file')
        combine_trials_from_single_matfiles(main_folder,subfolder_content{dir_index})
    end
    rmdir([main_folder filesep subfolder_content{dir_index}],'s');
end




function [trial,SETTINGS, task]=combine_trials_from_single_matfiles(folder,subfolder)
subfolder_dir=dir([folder filesep subfolder filesep '*_*.mat']); % checking only for mat files in the specified subfolder
subfolder_content={subfolder_dir.name};
subfolder_content=sort(subfolder_content);

for file_index=1:numel(subfolder_content)
    load([folder filesep subfolder filesep subfolder_content{file_index}]);
    if file_index==numel(subfolder_content) && isempty(current_trial.state)
        break;
    end
    trial(file_index)=current_trial;
end
save([folder filesep subfolder],'SETTINGS','task','trial');