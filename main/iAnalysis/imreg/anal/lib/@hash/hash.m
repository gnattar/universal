%
% SP Oct 2011
%
% This defines a class for hashes -- i.e., key-value pairs.  
%  Uses underlying cell objects to store both string keys and
%  completely arbitrary values.
%
classdef hash < handle
  % Properties
  properties 
	  % basic
		keys = {};
		values = {};
  end

	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor
		%
    function obj = hash(newKeys, newValues) 
		  % empty?
			if (nargin == 0)
			elseif(nargin == 2) % just ID
			  obj.keys = newKeys;
				obj.values = newValues;
			end
		end

		%
		% copy method -- duplicate is returned
		%
		function cobj = copy(obj)
		  cobj = hash(obj.keys, obj.values);
		end

		% 
		% get method -- returns value given key
		%
		function value = get(obj, key)
		  value = [];
			if (obj.ismember(key))
			  value = obj.values{obj.getIndex(key)};
			else
			  disp(['hash.get::field ' key ' not member of hash.']);
			end
		end

    %
		% adds if not present, sets if present.
		%
		function obj = setOrAdd(obj, key, value)
			if (obj.ismember(key))
			  idx = obj.getIndex(key);
				obj.values{idx} = value;
			else
				obj.add(key,value);
			end
		end

		%
		% sets the value field for a given key
		%
		function obj = set(obj, key, value)
			if (obj.ismember(key))
			  idx = obj.getIndex(key);
				obj.values{idx} = value;
			else
			  disp(['hash.set::field ' key ' not member of hash.']);
			end
		end

		%
		% returns length
		%
		function len = length(obj)
		  len = length(obj.keys);
		end

		%
		% displays key-value pairs (if possible)
		%
		function disp(obj)
		  if (~isempty(obj.keys))
				for k=1:length(obj.keys)
					if (isnumeric(obj.values{k}))
            if (length(size(obj.values{k})) == 1)
						  disp([obj.keys{k} '::' num2str(obj.values{k})]);
            else
						  if (max(size(obj.values{k})) > 1)
                disp([obj.keys{k} '::' num2str(size(obj.values{k})) ' sized matrix']);
							else
                disp([obj.keys{k} '::' num2str(obj.values{k})]);
							end
            end
					else
						disp([obj.keys{k} '::' obj.values{k}]);
					end
				end
  		else
			  disp('Hash object.  Fields: ');
			  disp(' ');
				disp(fieldnames(obj));
			end
		end


    %
		% gets index within hash of the key/value pair, given key.  Returns 0
		%  if not found.
		%
		function idx = getIndex(obj, key)
		  idx = find(strcmp(key,obj.keys));
			if (length(idx) == 0) ; idx = 0; end
		end

		%
		% Returns true if the key is a member, false otherwise
		%
		function tf = ismember(obj, key)
		  tf = 0;
		  idx = obj.getIndex(key);
			if (idx > 0) ; tf = 1; end
		end

		%
		% add method -- adds key/value pair, provided non-redundant
		%
		function obj = add(obj, key,value)
			if (obj.ismember(key))
			  disp(['hash.add::field ' key ' already member of hash.  Try using a new key name.']);
			else
				obj.keys{length(obj.keys)+1} = key;
				obj.values{length(obj.values)+1} = value;
			end
		end

		%
		% rename a given key
		%
		function obj = rename(obj, oldKey, newKey)
			if (obj.ismember(newKey))
			  disp(['hash.rename::field ' newKey ' already member of hash.  Try using a new key name.']);
			else
			  idx = obj.getIndex(oldKey);
				obj.keys{idx} = newKey;
			end
    end

		%
		% remove -- removes key/value pair given key
		%
		function obj = remove(obj, key)
		  if (~obj.ismember(key))
			  disp(['hash.remove::field ' key ' is not in the hash object.  Cannot remove.']);
			else
			  idx = obj.getIndex(key);
				keepIdx = setdiff(1:length(obj.keys), idx);
				obj.keys = obj.keys(keepIdx);
				obj.values = obj.values(keepIdx);
			end
		end

	end

  % Methods -- set/get/basic variable manipulation stuff
	methods 
	end
end

