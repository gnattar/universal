classdef (Abstract) MCOSFigure < ws.EventSubscriber
    % This is a base class that wraps a handle graphics figure in a proper
    % MCOS object.
    
    properties (Access=protected, Transient=true)
        DegreeOfEnablement_ = 1
            % We want to be able to disable updates, and do it in such a way
            % that it can be called in nested loops, functions, etc and
            % behave in a reasonable way.  So this this an integer that can
            % take on negative values when it has been disabled multiple
            % times without being enabled.  But it is always <= 1.
        NCallsToUpdateWhileDisabled_ = []    
        NCallsToUpdateControlPropertiesWhileDisabled_ = []    
        NCallsToUpdateControlEnablementWhileDisabled_ = []    
        %DegreeOfReadiness_ = 1
    end
    
    properties (Dependent=true, Transient=true)
        AreUpdatesEnabled   % logical scalar; if false, changes in the model should not be reflected in the UI
        %IsReady  % true <=> figure is showing the normal (as opposed to waiting) cursor
    end
    
    properties (Dependent=true, SetAccess=immutable)
        FigureGH  % the figure graphics handle
        Controller  % the controller, an instance of ws.Controller
        Model  % the model        
    end  % properties

    properties (Access=protected)
        FigureGH_  % the figure graphics handle
        Controller_  % the controller, an instance of ws.Controller
        Model_  % the model        
    end  % properties    
    
    methods
        function self=MCOSFigure(model,controller)
            % Note that when this is called, the controller is in a
            % not-completely-initialized state, so it's not safe to do much
            % of anything with it except copy a pointer to it.
            backgroundColor = ws.getDefaultUIControlBackgroundColor() ;
            self.FigureGH_=figure('Units','Pixels', ...
                                  'Color',backgroundColor, ...
                                  'Visible','off', ...
                                  'HandleVisibility','off', ...
                                  'DockControls','off', ...
                                  'CloseRequestFcn',@(source,event)(self.closeRequested(source,event)));
            if exist('model','var')
                self.setModel_(model);
            else
                self.setModel_([]);  % need this to can create an empty array of MCOSFigures
            end
            if exist('controller','var')
                self.Controller_=controller;
            else
                self.Controller_=[];  % need this to can create an empty array of MCOSFigures
            end
        end
        
        function delete(self)
            self.deleteFigureGH();
            self.Controller_=[];
            %self.setModel_([]);
            self.Model_ = [] ;
            %fprintf('here i am doing something\n');
        end

%         function deleteFigureGH(self)
%             if ~isempty(self.FigureGH) && ishghandle(self.FigureGH) ,
%               delete(self.FigureGH);  % delete the HG figure 
%             end
%             self.FigureGH=[];
%         end
        
        function output = get.Model(self)
            output = self.Model_ ;
        end
        
        function output = get.FigureGH(self)
            output = self.FigureGH_ ;
        end
        
        function output = get.Controller(self)
            output = self.Controller_ ;
        end
                
        function setModel_(self,newValue)
            self.willSetModel_();
            self.Model_ = newValue ;            
            self.didSetModel_();
        end
        
        function set.AreUpdatesEnabled(self,newValue)
            %fprintf('MCOSFigure::set.AreUpdatesEnabled()\n');
            %fprintf('  class of self: %s\n',class(self));
            %newValue
            
            if ~( islogical(newValue) && isscalar(newValue) ) ,
                return
            end
        
%             if isa(self,'ws.TestPulserFigure') ,
%                 fprintf('MCOSFigure:set.AreUpdatesEnabled(): At start, self.DegreeOfEnablement_ = %d\n' , ...
%                         self.DegreeOfEnablement_);
%                 fprintf('MCOSFigure:set.AreUpdatesEnabled(): newValue = %d\n' , ...
%                         newValue);
%             end
            
            netValueBefore=self.AreUpdatesEnabled;
            
            newValueAsSign=2*double(newValue)-1;  % [0,1] -> [-1,+1]
            newDegreeOfEnablementRaw=self.DegreeOfEnablement_+newValueAsSign;
            self.DegreeOfEnablement_ = ...
                    ws.fif(newDegreeOfEnablementRaw<=1, ...
                           newDegreeOfEnablementRaw, ...
                           1);
                        
%             if isa(self,'ws.TestPulserFigure') ,
%                 fprintf('MCOSFigure:set.AreUpdatesEnabled(): After update, self.DegreeOfEnablement_ = %d\n' , ...
%                         self.DegreeOfEnablement_);
%             end
            
            netValueAfter=self.AreUpdatesEnabled;
            
%             if isa(self,'ws.TestPulserFigure') ,
%                 fprintf('MCOSFigure.update(): self.DegreeOfEnablement_= %d\n',self.DegreeOfEnablement_);
%             end

            
            if netValueAfter && ~netValueBefore ,
                % Updates have just been enabled
                if self.NCallsToUpdateWhileDisabled_>0
                    self.updateImplementation_();
                elseif self.NCallsToUpdateControlPropertiesWhileDisabled_>0
                    self.updateControlPropertiesImplementation_();
                elseif self.NCallsToUpdateControlEnablementWhileDisabled_>0
                    self.updateControlEnablementImplementation_();
                end
                self.NCallsToUpdateWhileDisabled_=[];
                self.NCallsToUpdateControlPropertiesWhileDisabled_=[];
                self.NCallsToUpdateControlEnablementWhileDisabled_=[];
            elseif ~netValueAfter && netValueBefore ,
                % Updates have just been disabled
                self.NCallsToUpdateWhileDisabled_=0;
                self.NCallsToUpdateControlPropertiesWhileDisabled_=0;
                self.NCallsToUpdateControlEnablementWhileDisabled_=0;
            end            
        end  % function

        function value=get.AreUpdatesEnabled(self)
            %fprintf('MCOSFigure:get.AreUpdatesEnabled(): self.DegreeOfEnablement_ = %d\n' , ...
            %        self.DegreeOfEnablement_);
            value=(self.DegreeOfEnablement_>0);
        end
        
        function set(self,propName,value)
            if strcmpi(propName,'Visible') && islogical(value) && isscalar(value) ,
                % special case to deal with Visible, which seems to
                % sometimes be a boolean
                if value,
                    set(self.FigureGH_,'Visible','on');
                else
                    set(self.FigureGH_,'Visible','off');
                end
            else
                set(self.FigureGH_,propName,value);
            end
        end
        
        function value=get(self,propName)
            value=get(self.FigureGH_,propName);
        end
        
        function update(self,varargin)
            % Called when the caller wants the figure to fully re-sync with the
            % model, from scratch.  This may cause the figure to be
            % resized, but this is always done in such a way that the
            % upper-righthand corner stays in the same place.
            if self.AreUpdatesEnabled ,
                self.updateImplementation_();
            else
                self.NCallsToUpdateWhileDisabled_=self.NCallsToUpdateWhileDisabled_+1;
            end
        end
        
        function updateControlProperties(self,varargin)
            % Called when caller wants the control properties (Properties besides enablement, that is.) to re-sync
            % with the model, but doesn't need to update the controls that are in existance, or change the positions of the controls.
            if self.AreUpdatesEnabled ,
                self.updateControlPropertiesImplementation_();
            else
                self.NCallsToUpdateControlPropertiesWhileDisabled_=self.NCallsToUpdateControlPropertiesWhileDisabled_+1;
            end
        end
        
        function updateControlEnablement(self,varargin)
            % Called when caller only needs to update the
            % enablement/disablment of the controls, given the model state.
            if self.AreUpdatesEnabled ,
                self.updateControlEnablementImplementation_();
            else
                self.NCallsToUpdateControlEnablementWhileDisabled_=self.NCallsToUpdateControlEnablementWhileDisabled_+1;
            end            
        end
        
%         function changeReadiness(self,delta)
%             import ws.*
% 
%             if ~( isnumeric(delta) && isscalar(delta) && (delta==-1 || delta==0 || delta==+1 || (isinf(delta) && delta>0) ) ),
%                 return
%             end
%                     
%             isReadyBefore=self.IsReady;
%             
%             newDegreeOfReadinessRaw=self.DegreeOfReadiness_+delta;
%             self.DegreeOfReadiness_ = ...
%                     fif(newDegreeOfReadinessRaw<=1, ...
%                         newDegreeOfReadinessRaw, ...
%                         1);
%                         
%             isReadyAfter=self.IsReady;
%             
%             if isReadyAfter && ~isReadyBefore ,
%                 % Change cursor to normal
%                 set(self.FigureGH_,'pointer','arrow');
%                 drawnow('update');
%             elseif ~isReadyAfter && isReadyBefore ,
%                 % Change cursor to hourglass
%                 set(self.FigureGH_,'pointer','watch');
%                 drawnow('update');
%             end            
%         end  % function        
%         
%         function value=get.IsReady(self)
%             value=(self.DegreeOfReadiness_>0);
%         end       
        
        function updateReadiness(self,varargin)
            self.updateReadinessImplementation_();
        end

        function positionUpperLeftRelativeToOtherUpperRight(self, other, offset)
            % Positions the upper left corner of the figure relative to the upper
            % *right* corner of the other figure.  offset is 2x1, with the 1st
            % element the number of pixels from the right side of the other figure,
            % the 2nd the number of pixels from the top of the other figure.

            ws.positionFigureUpperLeftRelativeToFigureUpperRightBang(self.FigureGH_, other.FigureGH, offset) ;
        end
    end  % public methods

    methods (Access=protected)
        createFixedControls_(self)
            % In subclass, this should create all the controls that persist
            % throughout the lifetime of the figure.
        
        function updateControlsInExistance_(self)  %#ok<MANU>
            % In subclass, this should make sure the non-fixed controls in
            % existance are synced with the model state, deleting
            % inappropriate ones and creating appropriate ones as needed.
            
            % This default implementation does nothing, and is appropriate
            % only if all the controls are fixed.
        end
        
        updateControlPropertiesImplementation_(self) 
            % In subclass, this should make sure the properties of the
            % controls (besides Position and Enable) are in-sync with the
            % model.  It can assume that all the controls that should
            % exist, do exist.
        
        updateControlEnablementImplementation_(self) 
            % In subclass, this should make sure the Enable property of
            % each control is in-sync with the model.  It can assume that
            % all the controls that should exist, do exist.
        
        figureSize=layoutFixedControls_(self) 
            % In subclass, this should make sure all the positions of the
            % fixed controls are appropriate given the current model state.
        
        function figureSizeModified=layoutNonfixedControls_(self,figureSize)  %#ok<INUSL>
            % In subclass, this should make sure all the positions of the
            % non-fixed controls are appropriate given the current model state.
            % It can safely assume that all the non-fixed controls already
            % exist
            figureSizeModified=figureSize;  % this is appropriate if there are no nonfixed controls
        end
        
        function layout_(self)
            % This method should make sure all the controls are sized and placed
            % appropraitely given the current model state.
            
            % This implementation should work in most cases, but can be overridden by
            % subclasses if needed.
            figureSize=self.layoutFixedControls_();
            figureSizeModified=self.layoutNonfixedControls_(figureSize);
            ws.resizeLeavingUpperLeftFixedBang(self.FigureGH_,figureSizeModified);            
        end
        
        function updateImplementation_(self)
            % This method should make sure the figure is fully synched with the
            % model state after it is called.  This includes existance,
            % placement, sizing, enablement, and properties of each control, and
            % of the figure itself.

            % This implementation should work in most cases, but can be overridden by
            % subclasses if needed.
            self.updateControlsInExistance_();
            self.updateControlPropertiesImplementation_();
            self.updateControlEnablementImplementation_();
            self.layout_();
        end
        
        function updateReadinessImplementation_(self)
            if isempty(self.Model_) 
                pointerValue = 'arrow';
            else
                if isvalid(self.Model_) ,
                    if self.Model_.IsReady ,
                        pointerValue = 'arrow';
                    else
                        pointerValue = 'watch';
                    end
                else
                    pointerValue = 'arrow';
                end
            end
            set(self.FigureGH_,'pointer',pointerValue);
            %fprintf('drawnow(''update'')\n');
            drawnow('update');
        end
    end
    
    methods (Access=protected)
        function setIsVisible_(self, newValue)
            if ~isempty(self.FigureGH_) && ishghandle(self.FigureGH_) ,
                set(self.FigureGH_, 'Visible', ws.onIff(newValue));
            end
        end  % function
    end  % methods
    
    methods
        function show(self)
            self.setIsVisible_(true);
        end  % function       
    end  % methods    

    methods
        function hide(self)
            self.setIsVisible_(false);
        end  % function       
    end  % methods    
    
    methods
        function raise(self)
            self.hide() ;
            self.show() ;  
              % This above turns out to work really well for bringing
              % figures to the front.  You don't even see the figure hide
              % and then show b/c of the buffering of graphics commands in
              % Matlab (I assume that's why...)
              
            % This code below is unreliable.  It leads to weird behavior where hidden windows (that are not self.FigureGH_) get shown, 
            % and then their close button stops working, and madness
            % ensues.
%             figureGHs=allchild(0);  % ws.MCOSFigure defaults to figures having HandleVisibility=='off'
%             % sometimes figureGHs is a col vector, which seems odd...
%             if iscolumn(figureGHs) ,
%                 figureGHs = figureGHs' ;
%             end
%             isMe=(figureGHs==self.FigureGH_);
%             i=find(isMe,1);
%             if isempty(i) ,
%                 % do nothing
%             else
%                 otherRootChildren=figureGHs(~isMe);
%                 newRootChildren=[self.FigureGH_ otherRootChildren];
%                 set(0,'Children',newRootChildren);
%             end
        end  % function       
    end  % methods
    
    methods (Access = protected)
        function updateGuidata_(self)
            % Set up the figure guidata the way it would be if this were a
            % GUIDE UI, or close enough to fool a ws.most.Controller.
            handles=ws.MCOSFigure.updateGuidataHelper_(struct(),self.FigureGH_);
            % Add a pointer to self to the figure guidata
            handles.FigureObject=self;
            % commit to the guidata
            guidata(self.FigureGH_,handles);
        end  % function        
    end  % protected methods block
    
    methods (Access=protected)
        function willSetModel_(self)
            % This can be overridden if the figure wants something special to
            % happen just before the model is set
            self.unsubscribeFromAll();
        end
        
        function didSetModel_(self) 
            % This can be overridden if the figure wants something special to
            % happen just after the model is set
            model=self.Model_;
            if ~isempty(model) && isvalid(model) ,
                model.subscribeMe(self,'UpdateReadiness','','updateReadiness');
            end
        end
    end   
    
    methods (Static=true)
        function handles=updateGuidataHelper_(handles,containerGH)
            % For a figure or uipanel graphics handle, containerGH, adds
            % fields to the scalar structure handle, one per control in
            % containerGH.  The field name is equal to the Tag of the child
            % control.  If the child control is a uipanel, recursively adds
            % fields for the controls within the panel.  The resulting
            % struct is returned in handles.
            childControlGHs=get(containerGH,'Children');
            nChildren=length(childControlGHs);
            for i=1:nChildren ,
                childControlGH=childControlGHs(i);
                tag=get(childControlGH,'Tag');
                handles.(tag)=childControlGH;
                % If a uipanel, recurse
                if isequal(get(childControlGH,'Type'),'uipanel') ,
                    handles=ws.MCOSFigure.updateGuidataHelper_(handles,childControlGH);
                end
            end
            % Add the container itself
            tag=get(containerGH,'Tag');
            handles.(tag)=containerGH;
        end  % function        
    end  % protected methods block
    
    methods (Access = protected)
        function setHGTagsToPropertyNames_(self)
            % For each object property, if it's an HG object, set the tag
            % based on the property name, and set other HG object properties that can be
            % set systematically.
            mc=metaclass(self);
            propertyNames={mc.PropertyList.Name};
            for i=1:length(propertyNames) ,
                propertyName=propertyNames{i};
                propertyThing=self.(propertyName);
                if ~isempty(propertyThing) && all(ishghandle(propertyThing)) && ~(isscalar(propertyThing) && isequal(get(propertyThing,'Type'),'figure')) ,
                    % Set Tag
                    set(propertyThing,'Tag',propertyName);                    
                end
            end
        end  % function        
    end  % protected methods block
    
    methods
        function closeRequested(self,source,event)            
            if isempty(self.Controller_) ,
                self.deleteFigureGH();
            else
                self.Controller_.windowCloseRequested(source,event);
            end
        end  % function       
    end  % methods    
    
    methods
        function deleteFigureGH(self)   
            % This causes the figure HG object to be deleted, with no ifs
            % ands or buts
            if ~isempty(self.FigureGH_) && ishghandle(self.FigureGH_) ,
                delete(self.FigureGH_);
            end
            self.FigureGH_ = [] ;
        end  % function       
    end  % methods    
    
    methods
        function controlActuated(self,controlName,source,event,varargin)
            % This makes it so that we don't have all these implicit
            % references to the controller in the closures attached to HG
            % object callbacks.  It also means we can just do nothing if
            % the Controller is invalid, instead of erroring.
            if isempty(self.Controller_) || ~isvalid(self.Controller_) ,
                % do nothing
            else
                self.Controller_.controlActuated(controlName,source,event,varargin{:});
            end
        end  % function       
    end  % methods
    
    methods
        function constrainPositionToMonitors(self, monitorPositions)
            % For each monitor, calculate the translation needed to get the
            % figure onto it.

            % get the figure's OuterPosition
            %dbstack
            figureOuterPosition = get(self.FigureGH, 'OuterPosition') ;
            figurePosition = get(self.FigureGH, 'Position') ;
            %monitorPositions
            
            % define some local functions we'll need
            function translation = translationToFit2D(offset, sz, screenOffset, screenSize)
                xTranslation = translationToFit1D(offset(1), sz(1), screenOffset(1), screenSize(1)) ;
                yTranslation = translationToFit1D(offset(2), sz(2), screenOffset(2), screenSize(2)) ;
                translation = [xTranslation yTranslation] ;
            end

            function translation = translationToFit1D(offset, sz, screenOffset, screenSize)
                % Calculate a translation that will get a thing of size size at offset
                % offset onto a screen at offset screenOffset, of size screenSize.  All
                % args are *scalars*, as is the returned value
                topOffset = offset + sz ;  % or right offset, really
                screenTop = screenOffset+screenSize ;
                if offset < screenOffset ,
                    newOffset = screenOffset ;
                    translation =  newOffset - offset ;
                elseif topOffset > screenTop ,
                    newOffset = screenTop - sz ;
                    translation =  newOffset - offset ;
                else
                    translation = 0 ;
                end
            end
            
            % Get the offset, size of the figure
            figureOuterOffset = figureOuterPosition(1:2) ;
            figureOuterSize = figureOuterPosition(3:4) ;
            figureOffset = figurePosition(1:2) ;
            figureSize = figurePosition(3:4) ;
            
            % Compute the translation needed to get the figure onto each of
            % the monitors
            nMonitors = size(monitorPositions, 1) ;
            figureTranslationForEachMonitor = zeros(nMonitors,2) ;
            for i = 1:nMonitors ,
                monitorPosition = monitorPositions(i,:) ;
                monitorOffset = monitorPosition(1:2) ;
                monitorSize = monitorPosition(3:4) ;
                figureTranslationForThisMonitor = translationToFit2D(figureOuterOffset, figureOuterSize, monitorOffset, monitorSize) ;
                figureTranslationForEachMonitor(i,:) = figureTranslationForThisMonitor ;
            end

            % Calculate the magnitude of the translation for each monitor
            sizeOfFigureTranslationForEachMonitor = hypot(figureTranslationForEachMonitor(:,1), figureTranslationForEachMonitor(:,2)) ;
            
            % Pick the smallest translation that gets the figure onto
            % *some* monitor
            [~,indexOfSmallestFigureTranslation] = min(sizeOfFigureTranslationForEachMonitor) ;
            if isempty(indexOfSmallestFigureTranslation) ,
                figureTranslation = [0 0] ;
            else
                figureTranslation = figureTranslationForEachMonitor(indexOfSmallestFigureTranslation,:) ;
            end        

            % Compute the new position
            newFigurePosition = [figureOffset+figureTranslation figureSize] ;  
              % Apply the translation to the Position, not the
              % OuterPosition, as this seems to be more reliable.  Setting
              % the OuterPosition causes the layouts to get messed up
              % sometimes.  (Maybe setting the 'OuterSize' is the problem?)
            
            % Set it
            set(self.FigureGH, 'Position', newFigurePosition) ;
        end  % function        
    end  % public methods block
    
end  % classdef
