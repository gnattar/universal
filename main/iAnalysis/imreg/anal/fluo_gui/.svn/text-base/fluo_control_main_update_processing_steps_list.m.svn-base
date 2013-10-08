%
% deals with updating processor step list in fluo_control_main
%
function fluo_control_main_update_processing_steps_list()
  global glovars;

  % get selected step
  sps = get(glovars.fluo_control_main.processing_steps_list, 'Value');

	% repopulate the strings
	for s=1:length(glovars.processor_step)
	  fs{s} = glovars.processor_step(s).name;
		if (s == glovars.current_processor_step) ; fs{s} = [fs{s} '*'] ; end
	end

  % if selected step > number of steps left (due to, e.g., deletion), set to max
	if (sps > length(glovars.processor_step))
	  sps = length(glovars.processor_step);
	end
  
	set(glovars.fluo_control_main.processing_steps_list, 'Value', sps);
	set(glovars.fluo_control_main.processing_steps_list, 'String', fs);
