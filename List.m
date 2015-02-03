classdef List < handle
    %LIST key-value sortable list class
    %   Provides a list that behaves as a queue or a stack. The list is also
    %   sortable on a second paramater value.
    
    properties (SetAccess = private)
        listLength = 0
        idxFirst = 1;
        idxLast = 0;
        keys = cell(1, 1e5);
        values = nan(1, 1e5);
        type
    end
    
    methods
        function obj = List(varargin)
            % constructor for List class.
            % obj = List() : creates a key/value paired list
            % obj = List('keyvalue') : creates a key/value paired  list
            % obj = List('key') : creates a key only list
            obj.type = 'keyvalue';
            if nargin == 1 && ismember(lower(varargin{1}), {'key', 'keyvalue'})
                obj.type = lower(varargin{1});
            end

        end %List
        
        function flag = isempty(obj)
            flag = false;
            if obj.listLength == 0; flag = true; end
        end %isempty
        
        function push(obj, newkey, varargin)
            % add to end of list
            %
            % push(obj, newkey) : for a key only list. newkey can be a
            % single value or a cell array
            %
            % push(obj, newkey, newvalue) : for a key/value paired lsit.
            % newkey is a single value, string, or cell array. newvalue
            % must be numeric, and have the same number of elements as
            % newkey
            %
            
            % input error handling
            if isempty(newkey)
                return
            end
            
            allowableInputs = [iscell(newkey), ischar(newkey), ...
                and(isnumeric(newkey), numel(newkey) > 1) ];
            if ~any(allowableInputs);
                error('Bad Input')
            end
            if size(newkey,1) > size(newkey,2)
                newkey = newkey';
            end
            
            % also check values if given.
            if nargin == 3
                newvalue = varargin{1};
                if strcmp(obj.type, 'key')
                    error('This list is a key only list')
                elseif ~isnumeric(newvalue)
                    error('Values must be numeric')
                elseif length(newvalue) ~= length(newkey)
                    error('Need same number of values as keys')
                elseif size(newvalue,1) > size(newvalue,2)
                    newvalue = newvalue';
                end
            end
            
            % if adding too many values, expand list length
            while (length(newkey) + obj.listLength) > length(obj.keys)
                obj.keys = [obj.keys, cell(1, length(obj.keys))];
                if strcmp(obj.type, 'keyvalue')
                    obj.values = [obj.values, nan(1, length(obj.values))];
                end
            end
            
            % add new keys (and values) to the list
            idx = obj.idxLast + (1:length(newkey));
            if iscell(newkey); obj.keys(idx) = newkey;
            else obj.keys{idx} = newkey; 
            end
            
            if nargin == 3
                obj.values(idx) = newvalue;
            end
            obj.listLength = obj.listLength + length(newkey);
            obj.idxLast = obj.idxLast + length(newkey);
        end %push
        
        function [key, varargout] = pop(obj)
            % remove from end of list - FILO
            key = obj.keys{obj.idxLast};
            obj.keys{obj.idxLast} = [];
            switch obj.type
                case 'key'
                    if nargout == 2; error('list doesn''t have values'); end
                case 'keyvalue'
                    if nargout == 2; 
                        varargout{1} = obj.values(obj.idxLast); 
                    else warning('Key/value list, but not returning value');
                    end
                    obj.values(obj.idxLast) = [];
            end
            obj.listLength = obj.listLength - 1; 
            obj.idxLast = obj.idxLast - 1;
        end %pop
        
        function [key, varargout] = pull(obj)
            % remove from beginning of list - FIFO
            %key = obj.keys{1};
            %obj.keys(1) = [];
            key = obj.keys{obj.idxFirst};
            switch obj.type
                case 'key'
                    if nargout == 2; error('list doesn''t have values'); end
                case 'keyvalue'
                    if nargout == 2; 
                        varargout{1} = obj.values(obj.idxFirst); 
                    else warning('Key/value list, but not returning value');
                    end
            end
            obj.listLength = obj.listLength - 1; 
            obj.idxFirst = obj.idxFirst + 1;
        end %pull
        
        function sort(obj)
            % sort in ascending order by the values
            idxUsed = obj.idxFirst:obj.idxLast;
            [obj.values(idxUsed), idx] = sort(obj.values(idxUsed));
            obj.keys(idxUsed) = obj.keys((obj.idxFirst-1) + idx);
            %obj.values(idxUsed) = obj.values((obj.idxFirst-1) + idx);
            %error('Note yet defined')
        end %sort
        
    end
    
end
