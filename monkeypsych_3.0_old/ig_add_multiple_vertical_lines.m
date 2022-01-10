function ig_add_multiple_vertical_lines(vertical_lines_x,varargin)

ylim = get(gca,'Ylim');


line(kron(vertical_lines_x,[1 1 1]),repmat([ylim NaN],1,length(vertical_lines_x)),varargin{:});
