%
% This will take a series of ephus files with channel "piezo_monitor" and
%  a text file with command z values for an arbitrary piezo device and create
%  a lookup table for voltage-z. 
%
% Format for the text file should be 2 columns, 1st being ephus file# and second
%  being z.
%
% USAGE:
%
%  [voltage z_in_um] = piezo_voltage_um_callibration(ephus_wc, text_file_path)
%
% PARAMS:
%
%   ephus_wc: wildcard for matching ephus files ; order must match text file
%   text_file_path: text file indicating z of each ephus file (# z columns, 
%                   where # is the number of the file matched in wildcard)
%
% RETURNS:
%  
%   voltage: voltage output, as recorded by ephus
%   z_in_um: corresponding vector of z (in microns)
%
function [voltage z_in_um] = piezo_voltage_um_callibration(ephus_wc, text_file_path)
  if (nargin < 2) 
	  help ('piezo_voltage_um_callibration');
		return;
	end

	% --- sanity check --> ephus file list
	flist = dir(ephus_wc);
  z_data = load(text_file_path);

	disp('Please be sure that your ephus files match (listing Z/ephus file):');
	disp('==================================================================');
	for z=1:size(z_data,1)
	  disp([num2str(z_data(z,2)) ' um ; file: ' flist(z_data(z,1)).name]);
	end

	% --- rock n roll
	voltage = nan*zeros(1,size(z_data,1));
	for z=1:size(z_data,1)
	  eph = load( flist(z_data(z,1)).name, '-mat');

		% get channel #
		c_name = {};
		for c=1:length(eph.header.acquirer.acquirer.channels);
		  c_name{c} = eph.header.acquirer.acquirer.channels(c).channelName;
		end
		ci = find(strcmp(c_name,'piezo_monitor'));

    data_vec = eval(['eph.data.acquirer.trace_' num2str(ci)]);;
		[pdf volt] = ksdensity(data_vec);
		[irr idx] = max(pdf);
 
    voltage(z) = volt(idx); 
	end

  % returns ...
	z_in_um = z_data(:,2);
%	plot(z_data(:,2), voltage, 'rx');



	  
