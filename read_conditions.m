function conditions = read_conditions(filepath)

conditions = dlmread(filepath,'\t',1,0);
