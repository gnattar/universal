classdef SineStimulusDelegate < ws.StimulusDelegate
    properties (Constant)
        TypeString='Sine'
        AdditionalParameterNames={'Frequency'};
        AdditionalParameterDisplayNames={'Frequency'};        
        AdditionalParameterDisplayUnitses={'Hz'};        
    end
    
    properties (Dependent=true)
        Frequency
    end
    
    properties (Access=protected)
        Frequency_='10';  % Hz
    end
    
    methods
        function self = SineStimulusDelegate(parent,varargin)
            self=self@ws.StimulusDelegate(parent);
            pvArgs = ws.filterPVArgs(varargin, {'Frequency'}, {});
            propNames = pvArgs(1:2:end);
            propValues = pvArgs(2:2:end);               
            for i = 1:length(propValues)
                self.(propNames{i}) = propValues{i};
            end            
        end
        
        function set.Frequency(self, value)
            test = ws.Stimulus.evaluateSweepExpression(value,1) ;
            if ~isempty(test) && isnumeric(test) && isscalar(test) && isfinite(test) && isreal(test) && test>0 ,
                % if we get here without error, safe to set
                self.Frequency_ = value;
            end                    
%             if ~isempty(self.Parent) ,                            
%                 self.Parent.childMayHaveChanged();
%             end
        end  % function

        function out = get.Frequency(self)
            out=self.Frequency_;
        end
        
%         function set.Frequency(self, value)
%             if ~ws.isASettableValue(value), return, end            
%             self.validatePropArg('Frequency', value);
%             self.Frequency = value;
%         end
    end
    
%     methods (Access=protected)
%         function value=isequalElement(self,other)
%             isEqualAsStimuli=isequalElement@ws.Stimulus(self,other);
%             if ~isEqualAsStimuli ,
%                 value=false;
%                 return
%             end
%             additionalPropertyNamesToCompare={'Frequency'};
%             value=isequalElementHelper(self,other,additionalPropertyNamesToCompare);
%        end
%     end
    
    methods
        function y = calculateCoreSignal(self, stimulus, t, sweepIndexWithinSet) %#ok<INUSL>
            f = ws.Stimulus.evaluateSweepExpression(self.Frequency,sweepIndexWithinSet) ;
            if ~isempty(f) && isnumeric(f) && isscalar(f) && isfinite(f) && isreal(f) && f>0 ,
                y=sin(2*pi*f*t);
            else
                y=zeros(size(t));
            end
        end
        
%         function defineDefaultPropertyAttributes(self)
%             defineDefaultPropertyAttributes@ws.function.StimFunction(self);
%             self.setPropertyAttributeFeatures('Frequency', 'Classes', 'numeric', 'Attributes', {'scalar', 'real', 'finite', 'positive'});
%         end
    end
    
%     methods (Access=protected)
%         function defineDefaultPropertyTags_(self)
%             defineDefaultPropertyTags_@ws.StimulusDelegate(self);
%             self.setPropertyTags('AdditionalParameterNames', 'ExcludeFromFileTypes', {'header'});
%             self.setPropertyTags('AdditionalParameterDisplayNames', 'ExcludeFromFileTypes', {'header'});
%             self.setPropertyTags('AdditionalParameterDisplayUnitses', 'ExcludeFromFileTypes', {'header'});
%         end
%     end
    
    %
    % Implementations of methods needed to be a ws.ValueComparable
    %
    methods
        function value=isequal(self,other)
            % Custom isequal.  Doesn't work for 3D, 4D, etc arrays.
            value=isequalHelper(self,other,'ws.SineStimulusDelegate');
        end                            
    end
    
    methods (Access=protected)
       function value=isequalElement(self,other)
            propertyNamesToCompare={'Frequency'};
            value=isequalElementHelper(self,other,propertyNamesToCompare);
       end
    end
    
    methods (Access=protected)
        function out = getPropertyValue_(self, name)
            out = self.(name);
        end  % function
        
        % Allows access to protected and protected variables from ws.Coding.
        function setPropertyValue_(self, name, value)
            self.(name) = value;
        end  % function
    end
    
end
