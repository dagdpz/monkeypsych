function [modified_parameter updated_stepsize] = PEST(parameter_to_modify,parameter_limits,increase_or_decrease,preferred_behaviour,initial_stepsize,stepsize_min)

if preferred_behaviour % preferred behaviour (switch)
    updated_stepsize = initial_stepsize/2;
else % non-preferred behaviour (stay)
    updated_stepsize = initial_stepsize*2;
end
if updated_stepsize < stepsize_min
    updated_stepsize = stepsize_min;
end

if increase_or_decrease
    modified_parameter             = parameter_to_modify + initial_stepsize;
else
    modified_parameter             = parameter_to_modify - initial_stepsize;
end
if modified_parameter<parameter_limits(1)
    updated_stepsize=abs(modified_parameter-parameter_limits(1));
    modified_parameter=parameter_limits(1);
elseif modified_parameter>parameter_limits(2)
    updated_stepsize=abs(modified_parameter-parameter_limits(2));
    modified_parameter=parameter_limits(2);    
end


end

   