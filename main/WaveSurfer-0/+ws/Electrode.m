classdef Electrode < ws.Model % & ws.Mimic 
    
    properties (Constant=true)
        Types = {'Manual' 'Axon Multiclamp' 'Heka EPC' };  % first one is the default amplifier type
        %Modes = {'vc' 'cc'};
    end

    properties (Dependent=true)
        %Parent
        Name
        VoltageMonitorChannelName
        CurrentMonitorChannelName
        VoltageCommandChannelName
        CurrentCommandChannelName
        Mode  % 'vc' or 'cc'
        TestPulseAmplitudeInVC
        TestPulseAmplitudeInCC
        VoltageCommandScaling  % scalar, typically in mV/V
        CurrentMonitorScaling  % scalar, typically in V/pA
        CurrentCommandScaling  % scalar, tpyically in pA/V
        VoltageMonitorScaling  % scalar, typically in V/mV
        VoltageUnits
        CurrentUnits
        TestPulseAmplitude  % for whichever is the current mode
        CommandChannelName
        MonitorChannelName
        CommandScaling
        MonitorScaling
        Type
        IndexWithinType
        IsCommandEnabled
    end
    
    properties (Dependent=true, SetAccess=immutable)  % Hidden so not calc'ed on call to disp()
        CommandUnits
        MonitorUnits
    end
    
    properties (Access=protected)
        %Parent_   % the parent ElectrodeManager object, or empty
        Name_
        VoltageMonitorChannelName_
        CurrentMonitorChannelName_
        VoltageCommandChannelName_
        CurrentCommandChannelName_
        Mode_  % 'vc' or 'cc'
        TestPulseAmplitudeInVC_
        TestPulseAmplitudeInCC_
        VoltageCommandScaling_
        CurrentMonitorScaling_
        CurrentCommandScaling_
        VoltageMonitorScaling_
        VoltageUnits_  % constant for now, may change in future
        CurrentUnits_  % constant for now, may change in future
        TypeIndex_  % the index of the type within Types
        IndexWithinType_
        IsCommandEnabled_
    end
    
    methods        
        function self=Electrode(parent)
            % Set the defaults
            self@ws.Model(parent);
            self.Name_ = '' ;
            self.VoltageMonitorChannelName_ = '';
            self.CurrentMonitorChannelName_ = '';
            self.VoltageCommandChannelName_ = '';
            self.CurrentCommandChannelName_ = '';
            self.Mode_ = 'vc';  % 'vc' or 'cc'
            self.TestPulseAmplitudeInVC_ = 10 ;
            self.TestPulseAmplitudeInCC_ = 10 ;
            self.VoltageCommandScaling_ = 10;  % mV/V
            self.CurrentMonitorScaling_ = 0.01;  % V/pA
            self.CurrentCommandScaling_ = 100;  % pA/V
            self.VoltageMonitorScaling_ = 0.01;  % V/mV
            self.VoltageUnits_ = 'mV' ;  % constant for now, may change in future
            self.CurrentUnits_ = 'pA' ;  % constant for now, may change in future
            self.TypeIndex_ = 1;  % default amplifier type
            self.IndexWithinType_=[];  % e.g. 2 means this is the second electrode of the current type
            self.IsCommandEnabled=true;
            
%             % Process args
%             validPropNames=ws.findPropertiesSuchThat(self,'SetAccess','public');
%             mandatoryPropNames=cell(1,0);
%             pvArgs = ws.filterPVArgs(varargin,validPropNames,mandatoryPropNames);
%             propNamesRaw = pvArgs(1:2:end);
%             propValsRaw = pvArgs(2:2:end);
%             nPVs=length(propValsRaw);  % Use the number of vals in case length(varargin) is odd
%             propNames=propNamesRaw(1:nPVs);
%             propVals=propValsRaw(1:nPVs);            
            
%             % Set the properties
%             for idx = 1:nPVs
%                 self.(propNames{idx}) = propVals{idx};
%             end
            
            % % Notify other parts of the model
            % self.mayHaveChanged();
        end  % function
        
%         function out = get.Parent(self)
%             out=self.Parent_;
%         end  % function
        
        function out = get.Name(self)
            out=self.Name_;
        end  % function
        
        function out = get.VoltageMonitorChannelName(self)
            out=self.VoltageMonitorChannelName_;
        end  % function
        
        function out = get.CurrentMonitorChannelName(self)
            out=self.CurrentMonitorChannelName_;
        end  % function
        
        function out = get.VoltageCommandChannelName(self)
            out=self.VoltageCommandChannelName_;
        end  % function
        
        function out = get.CurrentCommandChannelName(self)
            out=self.CurrentCommandChannelName_;
        end  % function
        
        function out = get.Mode(self)
            out=self.Mode_;
        end  % function

%         function set.Parent(self,newValue)
%             if isa(newValue,'ws.ElectrodeManager')
%                 self.Parent_=newValue;
%             end
%             self.mayHaveChanged('Parent');
%         end  % function
        
        function set.Name(self,newValue)
            if ischar(newValue)
                self.Name_=newValue;
            end
            self.mayHaveChanged('Name');
        end  % function
        
        function set.VoltageMonitorChannelName(self,newValue)
            if ~ischar(newValue)
                return
            end
            self.VoltageMonitorChannelName_=newValue;
            self.mayHaveChanged('VoltageMonitorChannelName');
        end  % function
        
        function set.VoltageCommandChannelName(self,newValue)
            if ischar(newValue)
                self.VoltageCommandChannelName_=newValue;
            end
            self.mayHaveChanged('VoltageCommandChannelName');
        end  % function

        function set.CurrentMonitorChannelName(self,newValue)
            if ischar(newValue)
                self.CurrentMonitorChannelName_=newValue;
            end
            self.mayHaveChanged('CurrentMonitorChannelName');
        end  % function
        
        function set.CurrentCommandChannelName(self,newValue)
            if ischar(newValue)
                self.CurrentCommandChannelName_=newValue;
            end
            self.mayHaveChanged('CurrentCommandChannelName');
        end  % function
        
        function didSetAnalogInputChannelName(self, oldValue, newValue)
            if isequal(self.VoltageMonitorChannelName, oldValue) ,
                self.VoltageMonitorChannelName = newValue ;
            elseif isequal(self.CurrentMonitorChannelName, oldValue) ,
                self.CurrentMonitorChannelName =  newValue ;
            end
        end        
        
        function didSetAnalogOutputChannelName(self, oldValue, newValue)
            if isequal(self.VoltageCommandChannelName, oldValue) ,
                self.VoltageCommandChannelName = newValue ;
            elseif isequal(self.CurrentCommandChannelName, oldValue) ,
                self.CurrentCommandChannelName =  newValue ;
            end
        end        
        
        function set.Mode(self,newValue)
            % Want subclasses to be able to override, so we indirect
            self.setMode_(newValue);
        end  % function
        
        function out = get.CommandChannelName(self)
            if isequal(self.Mode,'vc') ,
                out = self.VoltageCommandChannelName;
            else
                out = self.CurrentCommandChannelName;
            end
        end  % function
        
        function set.CommandChannelName(self,newValue)
            if isequal(self.Mode,'vc') ,
                self.VoltageCommandChannelName=newValue;
            else
                self.CurrentCommandChannelName=newValue;
            end
            %self.mayHaveChanged();
        end  % function
        
        function out = get.MonitorChannelName(self)
            if isequal(self.Mode,'vc') ,
                out = self.CurrentMonitorChannelName;
            else
                out = self.VoltageMonitorChannelName;
            end
        end  % function
        
        function set.MonitorChannelName(self,newValue)
            if isequal(self.Mode,'vc') ,
                self.CurrentMonitorChannelName=newValue;
            else
                self.VoltageMonitorChannelName=newValue;
            end
            %self.mayHaveChanged();
        end  % function
        
        function out = get.VoltageUnits(self)
            out = self.VoltageUnits_;
        end  % function

        function out = get.CurrentUnits(self)
            out = self.CurrentUnits_;
        end  % function

        function out = get.CommandUnits(self) 
            if isequal(self.Mode,'vc') ,
                out = self.VoltageUnits;
            else
                out = self.CurrentUnits;
            end
        end  % function
        
        function out = get.MonitorUnits(self)
            if isequal(self.Mode,'vc') ,
                out = self.CurrentUnits;
            else
                out = self.VoltageUnits;
            end
        end
        
        function out = get.CommandScaling(self)
            if isequal(self.Mode,'vc') ,
                out = self.VoltageCommandScaling;
            else
                out = self.CurrentCommandScaling;
            end
        end
        
        function set.CommandScaling(self, newValue)
            if isequal(self.Mode,'vc') ,
                self.VoltageCommandScaling=newValue;
            else
                self.CurrentCommandScaling=newValue;
            end
        end
        
        function out = get.MonitorScaling(self)
            if isequal(self.Mode,'vc') ,
                out = self.CurrentMonitorScaling;
            else
                out = self.VoltageMonitorScaling;
            end
        end
        
        function set.MonitorScaling(self, newValue)
            if isequal(self.Mode,'vc') ,
                self.CurrentMonitorScaling=newValue;
            else
                self.VoltageMonitorScaling=newValue;
            end
        end

        function set.CurrentMonitorScaling(self, newValue)
            % Want subclasses to be able to override, so we indirect
            self.setCurrentMonitorScaling_(newValue);
        end
        
        function set.VoltageMonitorScaling(self, newValue)
            % Want subclasses to be able to override, so we indirect
            self.setVoltageMonitorScaling_(newValue);
        end
        
        function set.CurrentCommandScaling(self, newValue)
            % Want subclasses to be able to override, so we indirect
            self.setCurrentCommandScaling_(newValue);
        end
        
        function set.VoltageCommandScaling(self, newValue)
            % Want subclasses to be able to override, so we indirect
            self.setVoltageCommandScaling_(newValue);
        end
        
        function set.IsCommandEnabled(self, newValue)
            % Want subclasses to be able to override, so we indirect
            self.setIsCommandEnabled_(newValue);
        end
        
        function result = get.VoltageCommandScaling(self)
%             electrodeManager=self.Parent_;
%             ephys=electrodeManager.Parent;
%             wavesurferModel=ephys.Parent;
%             result=wavesurferModel.Stimulus.channelScaleFromName(channelName);
            result=self.VoltageCommandScaling_;
        end
        
        function result = get.CurrentCommandScaling(self)
%             channelName=self.CurrentCommandChannelName;
%             electrodeManager=self.Parent_;
%             ephys=electrodeManager.Parent;
%             wavesurferModel=ephys.Parent;
%             result=wavesurferModel.Stimulus.channelScaleFromName(channelName);
            result=self.CurrentCommandScaling_;
        end
        
        function result = get.VoltageMonitorScaling(self)
%             channelName=self.VoltageMonitorChannelName;
%             electrodeManager=self.Parent_;
%             ephys=electrodeManager.Parent;
%             wavesurferModel=ephys.Parent;
%             result=wavesurferModel.Acquisition.channelScaleFromName(channelName);
            result=self.VoltageMonitorScaling_;
        end
        
        function result = get.CurrentMonitorScaling(self)
%             channelName=self.CurrentMonitorChannelName;
%             electrodeManager=self.Parent_;
%             ephys=electrodeManager.Parent;
%             wavesurferModel=ephys.Parent;
%             result=wavesurferModel.Acquisition.channelScaleFromName(channelName);
            result=self.CurrentMonitorScaling_;
        end
        
        function result = get.IsCommandEnabled(self)
            if isequal(self.Type,'Manual') ,
                result=true;
            else
                result = self.IsCommandEnabled_;
            end
        end
        
        function result = get.TestPulseAmplitudeInVC(self)
            result=self.TestPulseAmplitudeInVC_;
        end
        
        function result = get.TestPulseAmplitudeInCC(self)
            result=self.TestPulseAmplitudeInCC_;
        end
        
        function set.TestPulseAmplitudeInVC(self,newThang)
            if isnumeric(newThang) && isscalar(newThang) ,
                self.TestPulseAmplitudeInVC_= double(newThang);
            end
            self.mayHaveChanged('TestPulseAmplitudeInVC');
        end
        
        function set.TestPulseAmplitudeInCC(self,newThang)
            if isnumeric(newThang) && isscalar(newThang) ,
                self.TestPulseAmplitudeInCC_= double(newThang);
            end
            self.mayHaveChanged('TestPulseAmplitudeInCC');
        end  % function
        
        function result = get.TestPulseAmplitude(self)
            if isequal(self.Mode,'cc')
                result=self.TestPulseAmplitudeInCC;
            else
                result=self.TestPulseAmplitudeInVC;
            end
        end  % function
        
        function set.TestPulseAmplitude(self,newValue)
            if isequal(self.Mode,'cc')
                self.TestPulseAmplitudeInCC=newValue;
            else
                self.TestPulseAmplitudeInVC=newValue;
            end
        end  % function
        
        function result=isTestPulsable(self)
            % In order to be test-pulse-able, the command and monitor
            % channel names for the current mode have to refer to valid
            % active channels.
            
            result=false;
            
            % If either the command or monitor channel is unspecified,
            % return false
            commandChannelName=self.CommandChannelName;
            if isempty(commandChannelName) ,
                return
            end

            monitorChannelName=self.MonitorChannelName;
            if isempty(monitorChannelName) ,
                return
            end            

            % Need to trace back our ancestry to find other objects to
            % query.  If we can't do that, we can't test pulse.
            electrodeManager=self.Parent_;
            if isempty(electrodeManager) ,
                return
            end
            
            ephys=electrodeManager.Parent;
            if isempty(ephys) ,
                return
            end
            
            wavesurferModel=ephys.Parent;
            if isempty(wavesurferModel) ,
                return
            end

            acquisition=wavesurferModel.Acquisition;
            if isempty(acquisition) ,
                return
            end

            stimulus=wavesurferModel.Stimulation;            
            if isempty(stimulus) ,
                return
            end
            
            % If we get here, it means that we have been able to find all
            % the other objects we depend upon for this method
            
            acquisitionChannelNames=acquisition.ActiveChannelNames;
            stimulusChannelNames=stimulus.AnalogChannelNames;

            % Finally, compute the result!
            result=any(strcmp(commandChannelName,stimulusChannelNames)) && ...
                   any(strcmp(monitorChannelName,acquisitionChannelNames));
               % this will be false if either acquisitionChannelNames or
               % stimulusChannelNames is empty
        end  % function
        
%         function s=encodeSettings(self)
%             % Note that this only gets public properties
%             s=struct();
%             s.Name=self.Name;
%             s.Type=self.Type;
%             s.IndexWithinType=self.IndexWithinType;
%             s.Mode=self.Mode;
%             s.VoltageCommandChannelName=self.VoltageCommandChannelName;
%             s.CurrentMonitorChannelName=self.CurrentMonitorChannelName;
%             s.CurrentCommandChannelName=self.CurrentCommandChannelName;
%             s.VoltageMonitorChannelName=self.VoltageMonitorChannelName;
%             s.TestPulseAmplitudeInVC=self.TestPulseAmplitudeInVC.getRepresentation();
%             s.TestPulseAmplitudeInCC=self.TestPulseAmplitudeInCC.getRepresentation();            
%             s.VoltageCommandScaling=self.VoltageCommandScaling;
%             s.CurrentMonitorScaling=self.CurrentMonitorScaling;
%             s.CurrentCommandScaling=self.CurrentCommandScaling;
%             s.VoltageMonitorScaling=self.VoltageMonitorScaling;
%             s.IsCommandEnabled=self.IsCommandEnabled;
%         end  % function
%         
%         function restoreSettings(self, s)
%             % Note that currently this only sets public properties, with
%             % all that that implies.
%             self.Name=s.Name;
%             self.Type=s.Type;
%             self.IndexWithinType=s.IndexWithinType;
%             self.Mode=s.Mode;
%             self.VoltageCommandChannelName=s.VoltageCommandChannelName;
%             self.CurrentMonitorChannelName=s.CurrentMonitorChannelName;
%             self.CurrentCommandChannelName=s.CurrentCommandChannelName;
%             self.VoltageMonitorChannelName=s.VoltageMonitorChannelName;
%             self.TestPulseAmplitudeInVC=ws.DoubleString(s.TestPulseAmplitudeInVC);
%             self.TestPulseAmplitudeInCC=ws.DoubleString(s.TestPulseAmplitudeInCC);
%             self.VoltageCommandScaling=s.VoltageCommandScaling;
%             self.CurrentMonitorScaling=s.CurrentMonitorScaling;
%             self.CurrentCommandScaling=s.CurrentCommandScaling;
%             self.VoltageMonitorScaling=s.VoltageMonitorScaling;
%             self.IsCommandEnabled=s.IsCommandEnabled;            
%         end  % function
        
        function mimic(self, other)
            % Note that currently this only sets public properties, with
            % all that that implies.
            
%             % Disable broadcasts for speed
%             self.disableBroadcasts();
            
% %             self.Name=other.Name;
% %             self.IndexWithinType=other.IndexWithinType;
% %             self.Mode=other.Mode;
% %             self.VoltageCommandChannelName=other.VoltageCommandChannelName;
% %             self.CurrentMonitorChannelName=other.CurrentMonitorChannelName;
% %             self.CurrentCommandChannelName=other.CurrentCommandChannelName;
% %             self.VoltageMonitorChannelName=other.VoltageMonitorChannelName;
% %             self.TestPulseAmplitudeInVC=other.TestPulseAmplitudeInVC;
% %             self.TestPulseAmplitudeInCC=other.TestPulseAmplitudeInCC;
% %             self.VoltageCommandScaling=other.VoltageCommandScaling;
% %             self.CurrentMonitorScaling=other.CurrentMonitorScaling;
% %             self.CurrentCommandScaling=other.CurrentCommandScaling;
% %             self.VoltageMonitorScaling=other.VoltageMonitorScaling;
% %             self.IsCommandEnabled=other.IsCommandEnabled;
% %             self.Type=other.Type;
            %disp('in Electrode, mimic before mayhavechanged');


            
            self.Name_=other.Name;
            self.IndexWithinType_=other.IndexWithinType;
            self.Mode_=other.Mode;
            self.VoltageCommandChannelName_=other.VoltageCommandChannelName;
            self.CurrentMonitorChannelName_=other.CurrentMonitorChannelName;
            self.CurrentCommandChannelName_=other.CurrentCommandChannelName;
            self.VoltageMonitorChannelName_=other.VoltageMonitorChannelName;
            self.TestPulseAmplitudeInVC_=other.TestPulseAmplitudeInVC;
            self.TestPulseAmplitudeInCC_=other.TestPulseAmplitudeInCC;
            self.VoltageCommandScaling_=other.VoltageCommandScaling;
            self.CurrentMonitorScaling_=other.CurrentMonitorScaling;
            self.CurrentCommandScaling_=other.CurrentCommandScaling;
            self.VoltageMonitorScaling_=other.VoltageMonitorScaling;
            self.IsCommandEnabled_=other.IsCommandEnabled;
            self.setType_(other.Type);
            self.mayHaveChanged(); % Want to call it once, argument doesn't matter
       %     self.mayHaveChanged('Name');
       %     self.mayHaveChanged('IndexWithinType');
       %     self.mayHaveChanged({'Name', 'IndexWithinType', 'Mode', 'VoltageCommandChannelName', ...
%                 'CurrentMonitorChannelName', 'CurrentCommandChannelName', 'VoltageMonitorChannelName',...
%                 'TestPulseAmplitudeInVC', 'TestPulseAmplitudeInCC', 'VoltageCommandScaling',...
%                  'CurrentMonitorScaling', 'CurrentCommandScaling', 'VoltageMonitorScaling', 'IsCommandEnabled','Type'});
             
%              % Re-enable broadcasts
%              self.enableBroadcastsMaybe();
%     
%              % Broadcast update
%              self.broadcast('Update');
        end  % function

%         function other=copyGivenParent(self,parent)  % We base this on mimic(), which we need anyway.  Note that we don't inherit from ws.Copyable
%             className=class(self);
%             other=feval(className,parent);
%             other.mimic(self);
%         end  % function
        
        function set.Type(self,newValue)
            isMatch=strcmp(newValue,self.Types);
            newTypeIndex=find(isMatch,1);
            if ~isempty(newTypeIndex) ,
                % Some trode types can't do 'i_equals_zero' mode, so check for that
                % and change to 'cc' if needed
                newType=self.Types{newTypeIndex};
                mode=self.Mode;
                if ~ws.Electrode.isModeAllowedForType(mode,newType) ,
                    newMode = ws.Electrode.findClosestAllowedModeForType(mode,newType) ;
                    self.Mode = newMode;
                end                
                % Actually change the type index
                self.TypeIndex_=newTypeIndex;
                % Set IndexWithinType_ as needed
                if isequal(newValue,'Manual') ,
                    self.IndexWithinType_=[];
                else
                    if isempty(self.IndexWithinType_) ,
                        self.IndexWithinType_=1;
                    end
                end
            end                       
            self.mayHaveChanged('Type');
        end  % function
        
        function value=get.Type(self)
            value=self.Types{self.TypeIndex_};
        end  % function
        
        function set.IndexWithinType(self,newValue)
            if isnumeric(newValue) && isscalar(newValue) && round(newValue)==newValue && newValue>0 && ~isequal(self.Type,'Manual') ,
                self.IndexWithinType_=newValue;
            end            
            self.mayHaveChanged('IndexWithinType');
        end  % function
        
        function value=get.IndexWithinType(self)
            value=self.IndexWithinType_;
        end  % function
        
        function setModeAndScalings(self,newMode,newCurrentMonitorScaling,newVoltageMonitorScaling,newCurrentCommandScaling,newVoltageCommandScaling,...
                                    newIsCommandEnabled)
            doNotify=false;
            self.setMode_(newMode,doNotify);
            self.setCurrentMonitorScaling_(newCurrentMonitorScaling,doNotify);
            self.setVoltageMonitorScaling_(newVoltageMonitorScaling,doNotify);
            self.setCurrentCommandScaling_(newCurrentCommandScaling,doNotify);
            self.setIsCommandEnabled_(newIsCommandEnabled,doNotify);
            doNotify=true;
            self.setVoltageCommandScaling_(newVoltageCommandScaling,doNotify);            
        end  % function
        
        function result=whichCommandOrMonitor(self,commandOrMonitor)
            % commandOrMonitor should be either 'Command' or 'Monitor'.
            % If commandOrMonitor is 'Monitor', and the current electrode
            % is 'vc', then the result is 'CurrentMonitor', for example.
            mode=self.Mode;
            if isequal(mode,'cc') ,
                if isequal(commandOrMonitor,'Command') ,                                    
                    result='CurrentCommand';
                else
                    result='VoltageMonitor';
                end                                    
            else
                if isequal(commandOrMonitor,'Command') ,                                    
                    result='VoltageCommand';
                else
                    result='CurrentMonitorRealized';
                end                                    
            end            
        end  % function
        
        function result=isNamedMonitorChannelManaged(self,channelName)
            if isempty(channelName)
                result=false;
            else
                managedChannelNames=[{self.CurrentMonitorChannelName_} ...
                                     {self.VoltageMonitorChannelName_}];
                result=any(strcmp(channelName,managedChannelNames));
            end
        end
        
        function result=isNamedCommandChannelManaged(self,channelName)
            if isempty(channelName)
                result=false;
            else
                managedChannelNames=[{self.CurrentCommandChannelName_} ...
                                     {self.VoltageCommandChannelName_}];
                result=any(strcmp(channelName,managedChannelNames)); 
            end
        end
        
        function result=getMonitorScalingByName(self,channelName)
            % Get the scaling for the named monitor channel dictated by
            % this electrode.  If the named channel is both the current and
            % voltage monitor name, use the mode to break the tie.
            managedChannelNames=[{self.CurrentMonitorChannelName_} ...
                                 {self.VoltageMonitorChannelName_}];
            isMatch=strcmp(channelName,managedChannelNames);
            scales=[self.CurrentMonitorScaling_ ...
                    self.VoltageMonitorScaling_];
            matchingScales=scales(isMatch);
            if length(matchingScales)>1 ,
                if isequal(self.Mode_,'vc') ,
                    result=matchingScales(1);
                else
                    result=matchingScales(2);
                end
            else
                result=matchingScales;
            end
        end
        
        function result=getCommandScalingByName(self,channelName)
            % Get the scaling for the named command channel dictated by
            % this electrode.  If the named channel is both the current and
            % voltage command name, use the mode to break the tie.
            managedChannelNames=[{self.CurrentCommandChannelName_} ...
                                 {self.VoltageCommandChannelName_}];
            isMatch=strcmp(channelName,managedChannelNames);
            scales=[self.CurrentCommandScaling_ ...
                    self.VoltageCommandScaling_];
            matchingScales=scales(isMatch);
            if length(matchingScales)>1 ,
                if isequal(self.Mode_,'vc') ,
                    result=matchingScales(2);
                else
                    result=matchingScales(1);
                end
            else
                result=matchingScales;
            end
        end
        
        function result=getMonitorUnitsByName(self,channelName)
            % Get the scaling for the named monitor channel dictated by
            % this electrode.  If the named channel is both the current and
            % voltage monitor name, use the mode to break the tie.
            managedChannelNames=[{self.CurrentMonitorChannelName_} ...
                                 {self.VoltageMonitorChannelName_}];
            isMatch=strcmp(channelName,managedChannelNames);
            units={self.CurrentUnits_ ...
                   self.VoltageUnits_};
            matchingUnits=units(isMatch);
            if length(matchingUnits)>1 ,
                if isequal(self.Mode_,'vc') ,
                    result=matchingUnits{1};
                else
                    result=matchingUnits{2};
                end
            else
                result=matchingUnits{1};
            end
        end
        
        function result = getCommandUnitByName(self,channelName)
            % Get the scaling for the named command channel dictated by
            % this electrode.  If the named channel is both the current and
            % voltage command name, use the mode to break the tie.
            managedChannelNames=[{self.CurrentCommandChannelName_} ...
                                 {self.VoltageCommandChannelName_}];
            isMatch=strcmp(channelName,managedChannelNames);
            units={self.CurrentUnits_ ...
                   self.VoltageUnits_};
            matchingUnits=units(isMatch);
            if length(matchingUnits)>1 ,
                if isequal(self.Mode_,'vc') ,
                    result=matchingUnits{2};
                else
                    result=matchingUnits{1};
                end
            else
                result=matchingUnits{1};
            end
        end
        
        function debug(self) %#ok<MANU>
            keyboard
        end
        
        function modes = getAllowedModes(self)
            modes=ws.Electrode.allowedModesForType(self.Type);
        end
        
        function result = getIsInACCMode(self)
            result = isequal(self.Mode_,'cc') || isequal(self.Mode_,'i_equals_zero') ;
        end

        function result = getIsInAVCMode(self)
            result = isequal(self.Mode_,'vc') ;
        end
        
    end  % public methods block
    
    methods (Access = protected)
        function setMode_(self,newValue,doNotify)
            if nargin<3 ,
                doNotify=true;
            end
            if ~isempty(newValue) ,  % empty sometimes used to signal that mode is unknown
                allowedModes=self.getAllowedModes();
                isMatch=cellfun(@(mode)(isequal(mode,newValue)),allowedModes);            
                if any(isMatch) ,
                    self.Mode_ = newValue;
                end
            end
            if doNotify,
                 self.mayHaveChanged('Mode');
            end
        end  % function
        
        function setVoltageMonitorScaling_(self,newValue,doNotify)
            if nargin<3 ,
                doNotify=true;
            end
            if isscalar(newValue) && isfinite(newValue) ,  % need isfinite() check b/c smart amps use this as "unknown" value
                self.VoltageMonitorScaling_=newValue;
            end
            if doNotify,
                self.mayHaveChanged('VoltageMonitorScaling');
            end
        end
        
        function setCurrentCommandScaling_(self, newValue,doNotify)
            if nargin<3 ,
                doNotify=true;
            end
            if isscalar(newValue) && isfinite(newValue) ,  % need isfinite() check b/c smart amps use this as "unknown" value
                self.CurrentCommandScaling_=newValue;
            end
            if doNotify,
                self.mayHaveChanged('CurrentCommandScaling');
            end
        end
        
        function setVoltageCommandScaling_(self, newValue,doNotify)
            if nargin<3 ,
                doNotify=true;
            end
            if isscalar(newValue) && isfinite(newValue) ,  % need isfinite() check b/c smart amps use this as "unknown" value
                self.VoltageCommandScaling_=newValue;
            end
            if doNotify,
                self.mayHaveChanged('VoltageCommandScaling');
            end
        end
        
        function setCurrentMonitorScaling_(self, newValue,doNotify)
            if nargin<3 ,
                doNotify=true;
            end
            if isscalar(newValue) && isfinite(newValue) ,  % need isfinite() check b/c smart amps use this as "unknown" value
                self.CurrentMonitorScaling_=newValue;
            end
            if doNotify,
                self.mayHaveChanged('CurrentMonitorScaling');
            end
        end
        
        function setIsCommandEnabled_(self, newValue,doNotify)
            if nargin<3 ,
                doNotify=true;
            end
            if islogical(newValue) && isscalar(newValue) ,
                % This property is always true for manual trodes
                if ~isequal(self.Type,'Manual') ,
                    self.IsCommandEnabled_=newValue;
                end
            end
            if doNotify,
                self.mayHaveChanged('IsCommandEnabled');
            end
        end
        
        function setType_(self,newValue)
            isMatch=strcmp(newValue,self.Types);
            newTypeIndex=find(isMatch,1);
            if ~isempty(newTypeIndex) ,
                % Some trode types can't do 'i_equals_zero' mode, so check for that
                % and change to 'cc' if needed
                newType=self.Types{newTypeIndex};
                mode=self.Mode;
                if ~ws.Electrode.isModeAllowedForType(mode,newType) ,
                    newMode = ws.Electrode.findClosestAllowedModeForType(mode,newType) ;
                    self.Mode = newMode;
                end                
                % Actually change the type index
                self.TypeIndex_=newTypeIndex;
                % Set IndexWithinType_ as needed
                if isequal(newValue,'Manual') ,
                    self.IndexWithinType_=[];
                else
                    if isempty(self.IndexWithinType_) ,
                        self.IndexWithinType_=1;
                    end
                end
            end                       
        end  % function
    end  % protected methods block
    
    methods (Access=protected)
        function mayHaveChanged(self,propertyName)
            electrodeManager=self.Parent_;
            if isempty(electrodeManager) || ~isvalid(electrodeManager) ,
                return
            end
            if ~exist('propertyName','var') ,
                propertyName='';
            end
            electrodeManager.electrodeMayHaveChanged(self,propertyName);
        end
    end
    
    methods (Access = protected)
        function out = getPropertyValue_(self, name)
            % By default this behaves as expected - allowing access to public properties.
            % If a Coding subclass wants to encode private/protected variables, or do
            % some other kind of transformation on encoding, this method can be overridden.
            out = self.(name);
        end
        
        function setPropertyValue_(self, name, value)
            % By default this behaves as expected - allowing access to public properties.
            % If a Coding subclass wants to decode private/protected variables, or do
            % some other kind of transformation on decoding, this method can be overridden.
            self.(name) = value;
        end
    end  % protected methods
    
    methods (Static)
        function modes=allowedModesForType(type)
            switch type ,
                case 'Axon Multiclamp' ,
                    modes={'vc' 'cc' 'i_equals_zero'};
                otherwise
                    modes={'vc' 'cc'};
            end
        end
        
        function result=isModeAllowedForType(mode,type)
            allowedModes=ws.Electrode.allowedModesForType(type);
            result=any(strcmp(mode,allowedModes));
        end
        
        function mode=findClosestAllowedModeForType(desiredMode,type)
            switch type ,
                case 'Axon Multiclamp' ,
                    mode=desiredMode;
                otherwise
                    if isequal(desiredMode,'i_equals_zero') ,
                        mode='cc';
                    else
                        mode=desiredMode;
                    end
            end
        end        
    end  % static methods

%     methods (Access=protected)        
%         function defineDefaultPropertyTags_(self)
%             defineDefaultPropertyTags_@ws.Model(self);
%             self.setPropertyTags('Parent', 'ExcludeFromFileTypes', {'header'});
%         end
%     end
    
%     properties (Hidden, SetAccess=protected)
%         mdlPropAttributes = struct();        
%         mdlHeaderExcludeProps = {};
%     end
    
end  % classdef
