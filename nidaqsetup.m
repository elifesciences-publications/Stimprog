function varargout = nidaqsetup(varargin)
% NIDAQSETUP M-file for nidaqsetup.fig
%      NIDAQSETUP, by itself, creates a new NIDAQSETUP or raises the existing
%      singleton*.
%
%      H = NIDAQSETUP returns the handle to a new NIDAQSETUP or the handle to
%      the existing singleton*.
%
%      NIDAQSETUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NIDAQSETUP.M with the given input arguments.
%
%      NIDAQSETUP('Property','Value',...) creates a new NIDAQSETUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nidaqsetup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nidaqsetup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nidaqsetup

% Last Modified by GUIDE v2.5 22-Jun-2011 11:18:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nidaqsetup_OpeningFcn, ...
                   'gui_OutputFcn',  @nidaqsetup_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before nidaqsetup is made visible.
function nidaqsetup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nidaqsetup (see VARARGIN)

global hfig_nidaqsetup
global hfig_ballgui

% Choose default command line output for nidaqsetup
handles.output = hObject;

logo_axis = gca;
nidaqlogo = imread('nidaqlogo.jpg');
image(nidaqlogo);
axis off
axis image

%routine to check which nidaq device is available

try 
hh = daqhwinfo('nidaq');
dev = hh.InstalledBoardIds;
hfig_nidaqsetup.deviceID = char(dev);
end

 if hfig_nidaqsetup.mode == 0 % winsound used for sound presentation only
     hfig_nidaqsetup.mode =1;
 end
 
 if hfig_nidaqsetup.mode ==1 %Capure off
     set(handles.uipanel_datacq, 'visible', 'off')
     mode_index = 2;
     try
     delete(hfig_ballgui.ao);
     end
 elseif hfig_nidaqsetup.mode ==2 %Capture on
     set(handles.uipanel_datacq, 'visible', 'on')
     mode_index = 1;
     try
     delete(hfig_ballgui.ao);
     delete(hfig_ballgui.ai);
     end
 end

    set(handles.text_stimsrate_val, 'string', hfig_ballgui.ch1.current_stimparam.stimsrate);
    set(handles.popupmenu_datcapsrate, 'string', hfig_nidaqsetup.datacqsrate);
    
    %set(handles.text_stimsrate_val, 'value', hfig_nidaqsetup.stimsrate_selected_index);
    set(handles.popupmenu_datcapsrate, 'value',hfig_nidaqsetup.datacqsrate_selected_index);
    set(handles.checkbox_ch1, 'value', hfig_nidaqsetup.ch1_acq);
    set(handles.checkbox_ch2, 'value', hfig_nidaqsetup.ch2_acq);
    set(handles.edit_duration, 'String', num2str(hfig_nidaqsetup.capture_dur));
    
    radiobuttons = get(handles.uipanel_mode, 'children');
    set(handles.uipanel_mode, 'SelectedObject', radiobuttons(mode_index));
    
% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);

% UIWAIT makes nidaqsetup wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = nidaqsetup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);


% --- Executes on selection change in popupmenu_datcapsrate.
function popupmenu_datcapsrate_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_datcapsrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_datcapsrate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_datcapsrate

global hfig_nidaqsetup

hfig_nidaqsetup.datacqsrate_selected_index = get(handles.popupmenu_datcapsrate,'Value');
datcapsrate = str2num(get(handles.popupmenu_datcapsrate,'String'));

hfig_nidaqsetup.datacqsrate_selected = datcapsrate(hfig_nidaqsetup.datacqsrate_selected_index);

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function popupmenu_datcapsrate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_datcapsrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_stimsrate.
function popupmenu_stimsrate_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_stimsrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_stimsrate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_stimsrate

global hfig_nidaqsetup

hfig_nidaqsetup.stimsrate_selected_index = get(handles.popupmenu_stimsrate,'Value');
stimsrate = str2num(get(handles.popupmenu_stimsrate,'String'));

hfig_nidaqsetup.stimsrate_selected = stimsrate(hfig_nidaqsetup.stimsrate_selected_index);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_stimsrate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_stimsrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_ch1.
function checkbox_ch1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ch1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ch1

global hfig_nidaqsetup

hfig_nidaqsetup.ch1_acq = get(handles.checkbox_ch1, 'value');



% --- Executes on button press in checkbox_ch2.
function checkbox_ch2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ch2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ch2

global hfig_nidaqsetup

hfig_nidaqsetup.ch2_acq = get(handles.checkbox_ch2, 'value');


function edit_duration_Callback(hObject, eventdata, handles)
% hObject    handle to edit_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_duration as text
%        str2double(get(hObject,'String')) returns contents of edit_duration as a double

global hfig_nidaqsetup

hfig_nidaqsetup.capture_dur = str2num(get(handles.edit_duration, 'String'));


% --- Executes during object creation, after setting all properties.
function edit_duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_done.
function pushbutton_done_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_nidaqsetup
global hfig_ballgui

datacqsrate = hfig_nidaqsetup.datacqsrate_selected;

if hfig_nidaqsetup.mode ==2 %stimulus presenation and capture
    
    %stimulus presentation
    
    hfig_ballgui.ao = analogoutput('nidaq', hfig_nidaqsetup.deviceID);
    addchannel(hfig_ballgui.ao,0:1);
    
    set(hfig_ballgui.ao,'TriggerType','Manual');
%     set(hfig_ballgui.ao, 'HwDigitalTriggerSource', 'PFI0');
    set(hfig_ballgui.ao, 'TriggerCondition', 'PositiveEdge');
    set(hfig_ballgui.ao.channel(1:2), 'OutputRange', [-10 10]);
    set(hfig_ballgui.ao.channel(1:2), 'UnitsRange', [-10 10]);
    
    %data capture

    dat_cap_dur = datacqsrate * hfig_nidaqsetup.capture_dur;
    hfig_ballgui.ai = analoginput('nidaq', hfig_nidaqsetup.deviceID);
    
    if and(hfig_nidaqsetup.ch1_acq ==1, hfig_nidaqsetup.ch2_acq ==1)
    
        addchannel(hfig_ballgui.ai,0:1);
        set(hfig_ballgui.ai,'SampleRate',datacqsrate);
        % set(hfig_ballgui.ai,'TriggerType','Hwdigital');
        % set(hfig_ballgui.ai, 'HwDigitalTriggerSource', 'PFI0');
        set(hfig_ballgui.ai, 'SamplesPerTrigger', dat_cap_dur);
        set(hfig_ballgui.ai, 'TriggerType', 'Manual');
        % set(hfig_ballgui.ai, 'TriggerCondition', 'PositiveEdge');
        set(hfig_ballgui.ai.channel(1),'SensorRange',[-10 10]);
        set(hfig_ballgui.ai.channel(1),'InputRange',[-10 10 ]);
        set(hfig_ballgui.ai.channel(1),'UnitsRange',[-10 10 ]);

        set(hfig_ballgui.ai.channel(2),'SensorRange',[-10 10]);
        set(hfig_ballgui.ai.channel(2),'InputRange',[-10 10 ]);
        set(hfig_ballgui.ai.channel(2),'UnitsRange',[-10 10 ]);
    
    elseif and(hfig_nidaqsetup.ch1_acq ==1, hfig_nidaqsetup.ch2_acq ==0)
        
        addchannel(hfig_ballgui.ai,0);
        set(hfig_ballgui.ai,'SampleRate',datacqsrate);
        % set(hfig_ballgui.ai,'TriggerType','Hwdigital');
        % set(hfig_ballgui.ai, 'HwDigitalTriggerSource', 'PFI0');
        set(hfig_ballgui.ai, 'SamplesPerTrigger', dat_cap_dur);
        set(hfig_ballgui.ai, 'TriggerType', 'Immediate');
        % set(hfig_ballgui.ai, 'TriggerCondition', 'PositiveEdge');
        set(hfig_ballgui.ai.channel(1),'SensorRange',[-10 10]);
        set(hfig_ballgui.ai.channel(1),'InputRange',[-10 10 ]);
        set(hfig_ballgui.ai.channel(1),'UnitsRange',[-10 10 ]);
    
    elseif and(hfig_nidaqsetup.ch1_acq ==0, hfig_nidaqsetup.ch2_acq==1)
        
        addchannel(hfig_ballgui.ai,1);
        set(hfig_ballgui.ai,'SampleRate',datacqsrate);
        % set(hfig_ballgui.ai,'TriggerType','Hwdigital');
        % set(hfig_ballgui.ai, 'HwDigitalTriggerSource', 'PFI0');
        set(hfig_ballgui.ai, 'SamplesPerTrigger', dat_cap_dur);
        set(hfig_ballgui.ai, 'TriggerType', 'Manual');
        % set(hfig_ballgui.ai, 'TriggerCondition', 'PositiveEdge');
        set(hfig_ballgui.ai.channel(1),'SensorRange',[-10 10]);
        set(hfig_ballgui.ai.channel(1),'InputRange',[-10 10 ]);
        set(hfig_ballgui.ai.channel(1),'UnitsRange',[-10 10 ]);
    end
        
        
     
elseif hfig_nidaqsetup.mode ==1 %stimulus presentation only
    
    hfig_ballgui.ao = analogoutput('nidaq', hfig_nidaqsetup.deviceID);
    addchannel(hfig_ballgui.ao,0:1);

    set(hfig_ballgui.ao,'TriggerType','Immediate');
%     set(hfig_ballgui.ao, 'HwDigitalTriggerSource', 'PFI0');
    set(hfig_ballgui.ao, 'TriggerCondition', 'PositiveEdge');
    set(hfig_ballgui.ao.channel(1:2), 'OutputRange', [-10 10]);
    set(hfig_ballgui.ao.channel(1:2), 'UnitsRange', [-10 10]);
end

guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
% else
    % The GUI is no longer waiting, just close it
%     delete(handles.figure1);
% end

% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" - do uiresume if we get it
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end


% --- Executes when selected object is changed in uipanel_mode.
function uipanel_mode_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_mode 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

global hfig_nidaqsetup

mode = get(handles.uipanel_mode, 'SelectedObject');

switch get(mode, 'Tag') 
    case 'radiobutton_stim'
        hfig_nidaqsetup.mode = 1; % Only stimulation
        set(handles.uipanel_datacq, 'visible', 'off')
    case 'radiobutton_stimcap'
        hfig_nidaqsetup.mode = 2; % Stimulation with capture
        set(handles.uipanel_datacq, 'visible', 'on')
end
