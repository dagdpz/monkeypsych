function answer = MP_inputdlg(matlabversion,varargin)
if matlabversion(1)>=2014
answer = dag_inputdlg(varargin{:});    
else
answer = inputdlg(varargin{:});
end
end
