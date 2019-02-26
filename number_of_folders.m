function [number,starting_date,ending_date]=number_of_folders(path,starting_folder,ending_folder)
starting_date=num2str(starting_folder);
ending_date=num2str(ending_folder);
starting_date=starting_date(end-1:end);
ending_date=ending_date(end-1:end);
starting_folder=str2double(starting_date);
ending_folder=str2double(ending_date);
number=ending_folder-starting_folder+1;
