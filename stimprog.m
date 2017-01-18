function varargout = stimprog(varargin)
%STIMPROG SOFTWARE DEVELOPED BY NORMAN LEE AND ANDREW C. MASON
%(c) 2011
% DEPT. OF BIOLOGICAL SCIENCES 
% UNIVERSITY OF TORONTO SCARBOROUGH


% STIMPROG M-file for stimprog.fig
%      STIMPROG, by itself, creates a new STIMPROG or raises the existing
%      singleton*.
%
%      H = STIMPROG returns the handle to a new STIMPROG or the handle to
%      the existing singleton*.
%
%      STIMPROG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIMPROG.M with the given input arguments.
%
%      STIMPROG('Property','Value',...) creates a new STIMPROG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ballgui2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stimprog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stimprog

% Last Modified by GUIDE v2.5 20-Oct-2011 23:30:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @stimprog_OpeningFcn, ...
    'gui_OutputFcn',  @stimprog_OutputFcn, ...
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


% --- Executes just before stimprog is made visible.
function stimprog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stimprog (see VARARGIN)

global hfig_ballgui
global hfig_nidaqsetup
global hfig_treadmill_setup
global dB_scale
global dB_level

hfig_ballgui.handles = handles;

% Choose default command line output for stimprog
handles.output = hObject;

% set custom close function
set(gcf,'CloseRequestFcn',@my_closefcn)

% initialize stimulus parameters to default calibration file
%set(handles.uipanel_presets, 'SelectionChangeFcn', @uipanel_presets_SelectionChangeFcn);

% Initialize handles data structure
hfig_ballgui.autotrack =0;
hfig_ballgui.stim_index = 1;
hfig_ballgui.stim_index_max = 1;

%---
[FileName,PathName] = uigetfile('*.xlsx','Select the Excel Calibration File');


calibration.ch1.values = xlsread(strcat(PathName,FileName), 'ch1');
calibration.ch2.values = xlsread(strcat(PathName,FileName), 'ch2');
 
hfig_ballgui.ch1.calibration.ref = calibration.ch1.values(1,1);
hfig_ballgui.ch1.calibration.freq = calibration.ch1.values(:,2);
hfig_ballgui.ch1.calibration.atten = calibration.ch1.values(:,3);
 
hfig_ballgui.ch2.calibration.ref = calibration.ch2.values(1,1);
hfig_ballgui.ch2.calibration.freq = calibration.ch2.values(:,2);
hfig_ballgui.ch2.calibration.atten = calibration.ch2.values(:,3);

clear calibration

load('defaultstim.mat');
%---

% defaultstim.mat contains struct "stimsettings" with ref atten, freqs
% calibrated and tdt attenuation settings for each frequency
% only - freq and spl values must be added based on current settings
% Need freq now, spl comes later (?)

% stimsettings(1).freq = hfig_ballgui.caldat.caldat(1).freq(1);
% stimsettings(2).freq = hfig_ballgui.caldat.caldat(2).freq(1);

% handles.caldat = hfig_ballgui.caldat.caldat;
% store caldat in handles
% channel edit buttons hold current stimulus settings

% set(handles.ch1edit_button,'UserData',stimsettings(1));
% set(handles.ch2edit_button,'UserData',stimsettings(2));

% mute buttons hold current attenuator setting - initialize to first
% frequency in default calfile

% set(handles.mute1,'UserData',handles.caldat(1).atten(1));
% set(handles.mute2,'UserData',handles.caldat(2).atten(1));

hfig_ballgui.ch1.current_stimparam = stimsettings(1);
hfig_ballgui.ch2.current_stimparam = stimsettings(2);

set(gcf, 'KeyPressFcn',@My_KeyPressFcn);

%Initialize sound level controls

dB_scale = [0.0045 0.0050 0.0056 0.0063 0.0071 0.0079 0.0089 0.0100 0.0112 0.0126...
            0.0141 0.0158 0.0178 0.0200 0.0224 0.0251 0.0282 0.0316 0.0355 0.0398... 
            0.0447 0.0501 0.0562 0.0631 0.0708 0.0794 0.0891 0.1000 0.1122 0.1259...
            0.1413 0.1585 0.1778 0.1995 0.2239 0.2512 0.2818 0.3162 0.3548 0.3981...
            0.4467 0.5012 0.5623 0.6310 0.7079 0.7943 0.8913 1];
        
dB_level = [47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94];

hfig_ballgui.ch1.level_index = 38;
hfig_ballgui.ch1.level = dB_scale(hfig_ballgui.ch1.level_index);

hfig_ballgui.ch2.level_index = 38;
hfig_ballgui.ch2.level = dB_scale(hfig_ballgui.ch2.level_index);


% Initializing NiDAQ
hfig_nidaqsetup.datacqsrate = [22050 32000 44100 48000 64000 88200 96000 192000 250000 500000];
hfig_nidaqsetup.stimsrate = [22050 32000 44100 48000 64000 88200 96000 192000 250000 500000];

hfig_nidaqsetup.mode = 1; %Start with only sound presentation (nidaq)
hfig_nidaqsetup.datacqsrate_selected = 22050;
hfig_nidaqsetup.datacqsrate_selected_index =1;
hfig_nidaqsetup.stimsrate_selected = 22050;
hfig_nidaqsetup.stimsrate_selected_index =1;
hfig_nidaqsetup.ch1_acq = 0;
hfig_nidaqsetup.ch2_acq = 0;
hfig_nidaqsetup.capture_dur = 1;


hfig_treadmill_setup.status = 0; % treadmill off
hfig_treadmill_setup.capture_dur = 1;
set(handles.ballplot, 'visible', 'off')


%set(handles.preset_panel,'SelectionChangeFcn',@preset_panel_SelectionChangeFcn);

% UIWAIT makes stimprog wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Create new directory for each run of the program.
% Top directory is date-stamp and subdirectories are for each run of the
% program. Sweeps save in separate files within data directory, numbered
% consecutively within matlab sessions (ie numbering doesn't reset unless
% Matlab is closed).

data_dir = datestr(now,29);
persistent xnum;
xnum = 1;
xnums = strcat('exp',num2str(xnum),'.mat');
data_file = strcat(data_dir,'\',xnums);
dummy = [];
if ~isdir(data_dir),
    mkdir(data_dir);
%     xnums = 'exp1.mat';
    data_file = strcat(data_dir,'\',xnums);
    save(data_file,'dummy');
else
    while exist(strcat(data_dir,'\',xnums)) == 2,
        xnum = xnum + 1;
        xnums = strcat('exp',num2str(xnum),'.mat');
        data_file = strcat(data_dir,'\',xnums);
    end
end
% set(handles.savefile_edit,'String',data_dir);
    save(data_file,'dummy');
set(handles.savefile_edit,'String',data_file);

hfig_ballgui.current_exp = data_file
% Set up TDT attenuators
 Dnum=1;
 CD='USB';
 
 try    
 zBus = actxcontrol('ZBUS.x',[5 5 26 26]);
 hfig_ballgui.TDT.zBus = zBus;
 
 handles.zbus = zBus;
 if invoke(zBus, 'ConnectZBUS','USB')
     hfig_ballgui.TDT.status = 1;
     e='Zbus connected'
 else
     hfig_ballgui.TDT.status = -1;
     e='Unable to connect Zbus'
     
 end
 
 PA5x1=actxcontrol('PA5.x',[5 5 26 26]); 
 hfig_ballgui.TDT.PA5x1 = PA5x1;
 
 handles.pa5x1 = PA5x1;
 
  
 %Connects to PA5 #1 via USB
  if invoke(PA5x1,'ConnectPA5',CD,1) % == -1
      e='PA5_1 connected'
      
      update_TDTatten(1,hfig_ballgui)
 else
      e= 'PA5_1 Unable to connect'
 end


 
 PA5x2=actxcontrol('PA5.x',[5 5 26 26]);
 hfig_ballgui.TDT.PA5x2 = PA5x2;

 handles.pa5x2 = PA5x2;



%Connects to PA5 #2 via USB
 if invoke(PA5x2,'ConnectPA5',CD,2) % == -1
     e='PA5_2 connected'
     
     update_TDTatten(2,hfig_ballgui)
 else
     e='PA5_2 Unable to connect'
 end
 
 
 end

set(handles.uipanel_ch_switch, 'visible', 'off')

%set default of autotrack (off)
hfig_ballgui.autotrack = 0;
set(handles.menu_autotrack_status, 'label', 'Autotrack OFF')


% Update handles structure
hfig_ballgui.handles = handles;
fhandles_update = @update_channel_summary;
hfig_ballgui.handles.fhandles = fhandles_update;

hfig_ballgui.ch1append = 0;
hfig_ballgui.ch2append = 0;

set(handles.pushbutton_remove, 'enable', 'off');

guidata(hObject, handles);
% 
% setappdata(0, 'stimprog', gcf);
% setappdata(gcf, 'h_ballplot,


% --- Outputs from this function are returned to the command line.
function varargout = stimprog_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in go_button.
function go_button_Callback(hObject, eventdata, handles)
% hObject    handle to go_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui

last_trace=struct('ch1params',{},'ch2params',{},'trace',{});

dat = stimulate(handles);

% set up for saving a trace
last_trace(1).ch1params = hfig_ballgui.ch1.current_stimparam;
last_trace(1).ch2params = hfig_ballgui.ch2.current_stimparam;

if hfig_ballgui.ch1.level ==0 
    last_trace(1).ch1params.spl = 'mute';
else
    last_trace(1).ch1params.spl = get_spl(1, hfig_ballgui);
end

if hfig_ballgui.ch2.level ==0
    last_trace(1).ch2params.spl = 'mute';
else    
    last_trace(1).ch2params.spl = get_spl(2, hfig_ballgui);
end

last_trace(1).trace = dat;


set(handles.save_button,'Enable','on');
set(handles.save_button,'UserData',last_trace)
set(handles.save_button,'String','Save last');

% --- Executes on button press in ch1up.
function ch1up_Callback(hObject, eventdata, handles)
% hObject    handle to ch1up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui
global dB_scale


if hfig_ballgui.TDT.status == 1
    new_atten = invoke(hfig_ballgui.TDT.PA5x1,'GetAtten') - 3;
    
    if new_atten < 5.0
        new_atten = new_atten + 3;
    end
    
    if (get(handles.mute1, 'Value') ==0)
        invoke(hfig_ballgui.TDT.PA5x1, 'SetAtten', new_atten);
        get_spl(1,hfig_ballgui)
    end
else
    current_level_index = hfig_ballgui.ch1.level_index;

    if current_level_index <= 47
        current_level_index = current_level_index +1;
        hfig_ballgui.ch1.level = dB_scale(current_level_index);
        hfig_ballgui.ch1.level_index = current_level_index;
        %hfig_ballgui.ch1.spl = dB_scale(current_level_index);
        %set(hfig_stimulator.text_ch1_level, 'String', num2str(dB_level(hfig_stimulator.ch1_level_index)));
    end
end

update_channel_summary(handles, 1);



% --- Executes on button press in ch1dn.
function ch1dn_Callback(hObject, eventdata, handles)
% hObject    handle to ch1dn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui
global dB_scale
%global dB_level


if hfig_ballgui.TDT.status == 1
    new_atten = invoke(hfig_ballgui.TDT.PA5x1,'GetAtten') + 3;
    
    if new_atten >99.9
        new_atten = new_atten - 3;
    end
    
    if (get(handles.mute1, 'Value') ==0)
        invoke(hfig_ballgui.TDT.PA5x1, 'SetAtten', new_atten);
        get_spl(1,hfig_ballgui)
    end
else
    
    current_level_index = hfig_ballgui.ch1.level_index;
    
    if current_level_index >= 2
        current_level_index = current_level_index -1;
        hfig_ballgui.ch1.level = dB_scale(current_level_index);
        hfig_ballgui.ch1.level_index = current_level_index;
        %hfig_ballgui.ch1.spl = dB_scale(current_level_index);
    end
end

update_channel_summary(handles,1);

% --- Executes on button press in ch1hi.
function ch1hi_Callback(hObject, eventdata, handles)
% hObject    handle to ch1hi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui

    ch1pars = hfig_ballgui.ch1.current_stimparam;

    current_freq = ch1pars.freq;
    new_freq_ind = find(hfig_ballgui.ch1.calibration.freq == current_freq) + 1;
    
    if new_freq_ind > length(hfig_ballgui.ch1.calibration.freq)
        new_freq_ind = 1;
    end
    
    new_freq = hfig_ballgui.ch1.calibration.freq(new_freq_ind);

    hfig_ballgui.ch1.current_stimparam.freq = new_freq;
    update_TDTatten(1,hfig_ballgui);
    
    hfig_ballgui.ch1.current_stimparam.signal = pulse_train(hfig_ballgui.ch1.current_stimparam);

update_channel_summary(handles,1);


% --- Executes on button press in ch1lo.
function ch1lo_Callback(hObject, eventdata, handles)
% hObject    handle to ch1lo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui

    ch1pars = hfig_ballgui.ch1.current_stimparam;

    current_freq = ch1pars.freq;
    new_freq_ind = find(hfig_ballgui.ch1.calibration.freq == current_freq) - 1;
    
    if new_freq_ind <= 0
        new_freq_ind = length(hfig_ballgui.ch1.calibration.freq);
    end
    
    new_freq = hfig_ballgui.ch1.calibration.freq(new_freq_ind);

    hfig_ballgui.ch1.current_stimparam.freq = new_freq;
    update_TDTatten(1,hfig_ballgui);
    
    hfig_ballgui.ch1.current_stimparam.signal = pulse_train(hfig_ballgui.ch1.current_stimparam);

update_channel_summary(handles,1);



% --- Executes on button press in mute1.
function mute1_Callback(hObject, eventdata, handles)
% hObject    handle to mute1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global hfig_ballgui
global dB_scale
global dB_level


ch1pars = hfig_ballgui.ch1.current_stimparam;

if hfig_ballgui.TDT.status == 1
    

    if get(handles.mute1, 'Value') == 1
        hfig_ballgui.ch1.current_TDTAtten = invoke(hfig_ballgui.TDT.PA5x1, 'GetAtten');
        invoke(hfig_ballgui.TDT.PA5x1, 'SetAtten', 120);
    
        set(handles.ch1up, 'enable', 'off');
        set(handles.ch1dn, 'enable', 'off');
        set(hObject, 'String', 'x');
        
        set(handles.ch1summary,'String', sprintf('Ch1\nFreq = %0.5g\nSPL = %s',...
            ch1pars.freq, 'mute'));
    else
        invoke(hfig_ballgui.TDT.PA5x1, 'SetAtten', hfig_ballgui.ch1.current_TDTAtten);
    
        set(handles.ch1up, 'enable', 'on');
        set(handles.ch1dn, 'enable', 'on');
        set(hObject, 'String', 'o');
        
        spl = get_spl(1,hfig_ballgui);
    
        set(handles.ch1summary,'String', sprintf('Ch1\nFreq = %0.5g\nSPL = %0.5gdB',...
            ch1pars.freq, spl));
    end
    
elseif hfig_ballgui.TDT.status == -1
    if get(handles.mute1, 'Value') == 1
        hfig_ballgui.ch1.level = 0;
    
        set(handles.ch1up, 'enable', 'off');
        set(handles.ch1dn, 'enable', 'off');
        set(hObject, 'String', 'x');
        
        set(handles.ch1summary,'String', sprintf('Ch1\nFreq = %0.5g\nSPL = %s',...
            ch1pars.freq, 'mute'));

    else
        hfig_ballgui.ch1.level = dB_scale(hfig_ballgui.ch1.level_index);
    
        set(handles.ch1up, 'enable', 'on');
        set(handles.ch1dn, 'enable', 'on');
        set(hObject, 'String', 'o');
    
        set(handles.ch1summary,'String', sprintf('Ch1\nFreq = %0.5g\nSPL = %0.5gdB',...
            ch1pars.freq, dB_level(hfig_ballgui.ch1.level_index)));
    end
end


% --- Executes on button press in ch1edit_button.
function ch1edit_button_Callback(hObject, eventdata, handles)
% hObject    handle to ch1edit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% newch1pars = stimedit(1,get(handles.chan1plot,'UserData'));

global hfig_ballgui
global hfig_stimedit

%ch2pars = get(handles.ch2edit_button,'UserData');
%[new_pars calfile] = ...
 %   stimedit(1,get(handles.ch1edit_button,'UserData'),...
  %      get(handles.cal1txt,'String'),get(handles.figure1,'Position'));

[new_pars calfile] = ...
    stimedit(1,hfig_ballgui.ch1.current_stimparam,...
        get(handles.cal1txt,'String'),get(handles.figure1,'Position'));

new_pars = hfig_stimedit.ch1;

if hfig_stimedit.stimulus_type ~=2;
    if hfig_stimedit.ch1.noise ==1
        set(handles.ch1lo, 'Enable', 'off');
        set(handles.ch1hi, 'Enable', 'off');
    else
        set(handles.ch1lo, 'Enable', 'on');
        set(handles.ch1hi, 'Enable', 'on');
    end
end

%load(calfile);
%handles.caldat(1) = caldat(1);
% store new parameters for channel1
%set(handles.ch1edit_button,'UserData', new_pars);
hfig_ballgui.ch1.current_stimparam = new_pars;


% get current parameters for channel2
% set channel2 total duration to match channel1, but preserve signs of
% duration values (to allow different lag values)


%ch2pars.totdur = sign(ch2pars.totdur) * abs(new_pars.totdur);

%set(handles.ch2edit_button,'UserData', ch2pars);
update_channel_summary(handles,0);
set(handles.cal1txt,'String',calfile);
guidata(hObject, handles);

% --- Executes on button press in ch2edit_button.
function ch2edit_button_Callback(hObject, eventdata, handles)
% hObject    handle to ch2edit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% newch2pars = stimedit(2,get(handles.chan2plot,'UserData'));

global hfig_ballgui
global hfig_stimedit

%ch1pars = get(handles.ch1edit_button,'UserData');
%[new_pars calfile] = ...
 %   stimedit(2,get(handles.ch2edit_button,'UserData'),...
  %  get(handles.cal2txt,'String'),get(handles.figure1,'Position'));

[new_pars calfile] = ...
    stimedit(2,hfig_ballgui.ch2.current_stimparam,...
        get(handles.cal2txt,'String'),get(handles.figure1,'Position'));

new_pars = hfig_stimedit.ch2;  
  
load(calfile);
handles.caldat(2) = caldat(2);
%set(handles.ch2edit_button,'UserData', new_pars);
% get current parameters for channel1
% set channel2 total duration to match channel1, but preserve signs of
% duration values (to allow different lag values)
%ch1pars.totdur = sign(ch1pars.totdur) * abs(new_pars.totdur);

if hfig_stimedit.stimulus_type ~=2;
    if hfig_stimedit.ch2.noise ==1
        set(handles.ch2lo, 'Enable', 'off');
        set(handles.ch2hi, 'Enable', 'off');
    else
        set(handles.ch2lo, 'Enable', 'on');
        set(handles.ch2hi, 'Enable', 'on');
    end
end


hfig_ballgui.ch2.current_stimparam = new_pars;


%set(handles.ch1edit_button,'UserData', ch1pars);
update_channel_summary(handles,0);
set(handles.cal2txt,'String',calfile);
guidata(hObject, handles);


% --- Executes on button press in ch2up.
function ch2up_Callback(hObject, eventdata, handles)
% hObject    handle to ch2up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui
global dB_scale

if hfig_ballgui.TDT.status == 1
    new_atten = invoke(hfig_ballgui.TDT.PA5x2,'GetAtten') - 3;
    
    if new_atten < 5.0
        new_atten = new_atten + 3;
    end
    
    if (get(handles.mute2, 'Value') ==0)
        invoke(hfig_ballgui.TDT.PA5x2, 'SetAtten', new_atten);
        get_spl(2,hfig_ballgui)
    end
else

    current_level_index = hfig_ballgui.ch2.level_index;

    if current_level_index <= 47
        current_level_index = current_level_index +1;
        hfig_ballgui.ch2.level = dB_scale(current_level_index);
        hfig_ballgui.ch2.level_index = current_level_index;
        %hfig_ballgui.ch2.spl = dB_scale(current_level_index);
        %set(hfig_stimulator.text_ch1_level, 'String', num2str(dB_level(hfig_stimulator.ch1_level_index)));
    end
    
end

update_channel_summary(handles,2);


% --- Executes on button press in ch2dn.
function ch2dn_Callback(hObject, eventdata, handles)
% hObject    handle to ch2dn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui
global dB_scale
%global dB_level


if hfig_ballgui.TDT.status == 1
    new_atten = invoke(hfig_ballgui.TDT.PA5x2,'GetAtten') + 3;
    
    if new_atten >99.9
        new_atten = new_atten - 3;
    end
    
    if (get(handles.mute2, 'Value') ==0)
        invoke(hfig_ballgui.TDT.PA5x2, 'SetAtten', new_atten);
        get_spl(2,hfig_ballgui)
    end
else
    current_level_index = hfig_ballgui.ch2.level_index;

    if current_level_index >= 2
        current_level_index = current_level_index -1;
        hfig_ballgui.ch2.level = dB_scale(current_level_index);
        hfig_ballgui.ch2.level_index = current_level_index;
        %hfig_ballgui.ch2.spl = dB_scale(current_level_index);
        %set(hfig_stimulator.text_ch1_level, 'String', num2str(dB_level(hfig_stimulator.ch1_level_index)));
    end

end
update_channel_summary(handles,2);



% --- Executes on button press in ch2hi.
function ch2hi_Callback(hObject, eventdata, handles)
% hObject    handle to ch2hi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui

  ch2pars = hfig_ballgui.ch2.current_stimparam;

    current_freq = ch2pars.freq;
    new_freq_ind = find(hfig_ballgui.ch2.calibration.freq == current_freq) + 1;
    
    if new_freq_ind > length(hfig_ballgui.ch2.calibration.freq)
        new_freq_ind = 1;
    end
    
    new_freq = hfig_ballgui.ch2.calibration.freq(new_freq_ind);

    hfig_ballgui.ch2.current_stimparam.freq = new_freq;
    update_TDTatten(2,hfig_ballgui);
    
    hfig_ballgui.ch2.current_stimparam.signal = pulse_train(hfig_ballgui.ch2.current_stimparam);


update_channel_summary(handles,2);


% --- Executes on button press in ch2lo.
function ch2lo_Callback(hObject, eventdata, handles)
% hObject    handle to ch2lo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui

    ch2pars = hfig_ballgui.ch2.current_stimparam;
    
    current_freq = ch2pars.freq;
    new_freq_ind = find(hfig_ballgui.ch2.calibration.freq == current_freq) - 1;
    
    if new_freq_ind <= 0
        new_freq_ind = length(hfig_ballgui.ch2.calibration.freq);
    end
    
    new_freq = hfig_ballgui.ch2.calibration.freq(new_freq_ind);

    hfig_ballgui.ch2.current_stimparam.freq = new_freq;
    update_TDTatten(2,hfig_ballgui);
    
    hfig_ballgui.ch2.current_stimparam.signal = pulse_train(hfig_ballgui.ch2.current_stimparam);

update_channel_summary(handles,2);


% --- Executes on button press in mute2.
function mute2_Callback(hObject, eventdata, handles)
% hObject    handle to mute2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global hfig_ballgui
global dB_scale
global dB_level


ch2pars = hfig_ballgui.ch2.current_stimparam;

if hfig_ballgui.TDT.status == 1
    
current_PA5x2_val = invoke(hfig_ballgui.TDT.PA5x2, 'GetAtten');

    if get(handles.mute2, 'Value') == 1
        hfig_ballgui.ch2.current_TDTAtten = invoke(hfig_ballgui.TDT.PA5x2, 'GetAtten');
        invoke(hfig_ballgui.TDT.PA5x2, 'SetAtten', 120);
    
        set(handles.ch2up, 'enable', 'off');
        set(handles.ch2dn, 'enable', 'off');
        set(hObject, 'String', 'x');
        
        set(handles.ch2summary,'String', sprintf('Ch2\nFreq = %0.5g\nSPL = %s',...
            ch2pars.freq, 'mute'));
    else
        invoke(hfig_ballgui.TDT.PA5x2, 'SetAtten', hfig_ballgui.ch2.current_TDTAtten);   
    
        set(handles.ch2up, 'enable', 'on');
        set(handles.ch2dn, 'enable', 'on');
        set(hObject, 'String', 'o');
        
        spl = get_spl(2,hfig_ballgui);
    
        set(handles.ch2summary,'String', sprintf('Ch2\nFreq = %0.5g\nSPL = %0.5gdB',...
            ch2pars.freq, spl));
    end
    
elseif hfig_ballgui.TDT.status == -1
    if get(handles.mute2, 'Value') == 1
        hfig_ballgui.ch2.level = 0;
    
        set(handles.ch2up, 'enable', 'off');
        set(handles.ch2dn, 'enable', 'off');
        set(hObject, 'String', 'x');
        
        set(handles.ch2summary,'String', sprintf('Ch2\nFreq = %0.5g\nSPL = %s',...
            ch2pars.freq, 'mute'));

    else
        hfig_ballgui.ch2.level = dB_scale(hfig_ballgui.ch2.level_index);
    
        set(handles.ch2up, 'enable', 'on');
        set(handles.ch2dn, 'enable', 'on');
        set(hObject, 'String', 'o');
    
        set(handles.ch2summary,'String', sprintf('Ch2\nFreq = %0.5g\nSPL = %0.5gdB',...
            ch2pars.freq, dB_level(hfig_ballgui.ch2.level_index)));
    end
end



function savefile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to savefile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% persistent data_dir;
%
% if isempty(data_dir),
data_dir = (get(hObject,'String'));
if ~isdir(data_dir),
    mkdir(data_dir);
else
    set(hObject,'String','!!BAD NAME!!');
end
% end


% --- Executes during object creation, after setting all properties.
function savefile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savefile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function update_channel_summary(handles,chan)
% Updates the text fields displaying frequency & intensity for each channel

global hfig_ballgui
global dB_level

%set(handles.ch1summary,'UserData',handles.caldat(1));
%set(handles.ch2summary,'UserData',handles.caldat(2));

switch chan,
    case 0
        %ch1pars=get(handles.ch1edit_button,'UserData');
        
        ch1pars = hfig_ballgui.ch1.current_stimparam;
        dB_level_val = get_spl(1,hfig_ballgui);
%             current_atten = invoke(hfig_ballgui.TDT.PA5x1, 'getAtten');
%             ref_atten = hfig_ballgui.caldat.caldat(1).atten(find(hfig_ballgui.caldat.caldat(1).freq == ch1pars.freq)); %set to the calibrated attenuation setting for each frequency
%             diff_atten = current_atten - ref_atten;
            
%             dB_level_val = hfig_ballgui.caldat.caldat(1).ref - diff_atten;
%             hfig_ballgui.ch1.dB_level_val = dB_level_val;
        
        set(handles.ch1summary,'String', sprintf('Ch1\nFreq = %0.5g\nSPL = %0.5gdB',...
            ch1pars.freq, dB_level_val));
        plot_wfm(1,handles);
        
        set(handles.edit_ch1_delay, 'string', num2str(ch1pars.delay));
       
        %ch2pars=get(handles.ch2edit_button,'UserData');
        ch2pars = hfig_ballgui.ch2.current_stimparam;
        dB_level_val = get_spl(2,hfig_ballgui);
        
%             current_atten = invoke(hfig_ballgui.TDT.PA5x2, 'getAtten');
%             ref_atten = hfig_ballgui.caldat.caldat(2).atten(find(hfig_ballgui.caldat.caldat(2).freq == ch2pars.freq)); %set to the calibrated attenuation setting for each frequency
%             diff_atten = current_atten - ref_atten;
%             
%             dB_level_val = hfig_ballgui.caldat.caldat(2).ref - diff_atten;
%             hfig_ballgui.ch2.dB_level_val = dB_level_val;
        
        set(handles.ch2summary,'String', sprintf('Ch2\nFreq = %0.5g\nSPL = %0.5gdB',...
            ch2pars.freq, dB_level_val));
        plot_wfm(2,handles);
        
        set(handles.edit_ch2_delay, 'string', num2str(ch2pars.delay));

    case 1
        
        ch1pars = hfig_ballgui.ch1.current_stimparam;
        dB_level_val = get_spl(1,hfig_ballgui);
        
        
%         if hfig_ballgui.TDT.status == 1
%             current_atten = invoke(hfig_ballgui.TDT.PA5x1, 'getAtten');
%             ref_atten = hfig_ballgui.caldat.caldat(1).atten(find(hfig_ballgui.caldat.caldat(1).freq == ch1pars.freq)); %set to the calibrated attenuation setting for each frequency
%             diff_atten = current_atten - ref_atten;
%             
%             dB_level_val = hfig_ballgui.caldat.caldat(1).ref - diff_atten;
%             hfig_ballgui.ch1.dB_level_val = dB_level_val;
%         else
%             dB_level_val = dB_level(hfig_ballgui.ch1.level_index);
%             hfig_ballgui.ch1.dB_level_val = dB_level_val;
%         end
       
        set(handles.ch1summary,'String', sprintf('Ch1\nFreq = %0.5g\nSPL = %0.5gdB',...
            ch1pars.freq,dB_level_val));
        plot_wfm(1,handles);
        
        set(handles.edit_ch1_delay, 'string', num2str(ch1pars.delay));

    case 2
       
        ch2pars = hfig_ballgui.ch2.current_stimparam;
        dB_level_val = get_spl(2,hfig_ballgui);
%         if hfig_ballgui.TDT.status == 1
%             current_atten = invoke(hfig_ballgui.TDT.PA5x2, 'getAtten');
%             ref_atten = hfig_ballgui.caldat.caldat(2).atten(find(hfig_ballgui.caldat.caldat(2).freq == ch2pars.freq)); %set to the calibrated attenuation setting for each frequency
%             diff_atten = current_atten - ref_atten;
%             
%             dB_level_val = hfig_ballgui.caldat.caldat(2).ref - diff_atten;
%             hfig_ballgui.ch2.dB_level_val = dB_level_val;
%         else
%             dB_level_val = dB_level(hfig_ballgui.ch2.level_index);
%             hfig_ballgui.ch2.dB_level_val = dB_level_val;
%         end
%         
        set(handles.ch2summary,'String', sprintf('Ch2\nFreq = %0.5g\nSPL = %0.5gdB',...
            ch2pars.freq,dB_level_val));
        plot_wfm(2,handles);
        
        set(handles.edit_ch2_delay, 'string', num2str(ch2pars.delay));

end

guidata(handles.ch1summary, handles);

% ------------------------------------------------
function plot_wfm(chan,handles)

global hfig_ballgui
global hfig_nidaqsetup

if hfig_nidaqsetup.mode == 0;
    srate = hfig_ballgui.ch1.current_stimparam.stimsrate;
else
    srate = hfig_ballgui.ch1.current_stimparam.stimsrate;
end


switch chan
    case 1
        axes(handles.chan1plot);
        
        if hfig_ballgui.ch1append == 0
            %hfig_ballgui.ch1.current_stimparam.signal = pulse_train(hfig_ballgui.ch1.current_stimparam);             
            plot((1:length(hfig_ballgui.ch1.current_stimparam.signal))/(srate/1000),hfig_ballgui.ch1.current_stimparam.signal);
        else
            plot((1:length(hfig_ballgui.ch1.current_stimparam.signal))/(srate/1000),hfig_ballgui.ch1.current_stimparam.signal);
        end
        %          axis off
        
        h = gca;
        %set(h, 'xlim', [0 2000]);
        
    case 2
        axes(handles.chan2plot);
        
        if hfig_ballgui.ch2append == 0
            %hfig_ballgui.ch2.current_stimparam.signal = pulse_train(hfig_ballgui.ch2.current_stimparam);
            plot((1:length(hfig_ballgui.ch2.current_stimparam.signal))/(srate/1000),hfig_ballgui.ch2.current_stimparam.signal,'r');
        else
            plot((1:length(hfig_ballgui.ch2.current_stimparam.signal))/(srate/1000),hfig_ballgui.ch2.current_stimparam.signal,'r');
        end
        %          axis off
        
        h = gca;
        %set(h, 'xlim', [0 2000]);

end

% ------------------------------------------------
function spl = get_spl(chan,handles)
global hfig_ballgui
global dB_level

switch chan
    case 1
        if hfig_ballgui.TDT.status == 1
            ch1pars = hfig_ballgui.ch1.current_stimparam;        
            f = ch1pars.freq(1);
            atten_for_ref = hfig_ballgui.ch1.calibration.atten(find(hfig_ballgui.ch1.calibration.freq ==f));
            
%             invoke(hfig_ballgui.TDT.PA5x1, 'SetAtten', atten_for_ref);
            
            ref = hfig_ballgui.ch1.calibration.ref;        
            atten_now = invoke(hfig_ballgui.TDT.PA5x1, 'GetAtten');
            
            diff_atten = atten_for_ref - atten_now;
            spl = ref + diff_atten;
        else
            spl = dB_level(hfig_ballgui.ch1.level_index); 
        end
    case 2
        if hfig_ballgui.TDT.status == 1
            ch2pars = hfig_ballgui.ch2.current_stimparam;        
            f = ch2pars.freq(1);
            atten_for_ref = hfig_ballgui.ch2.calibration.atten(find(hfig_ballgui.ch2.calibration.freq ==f));

%             invoke(hfig_ballgui.TDT.PA5x2, 'SetAtten', atten_for_ref);
            
            ref = hfig_ballgui.ch2.calibration.ref;        
            atten_now = invoke(hfig_ballgui.TDT.PA5x2, 'GetAtten');
            
            diff_atten = atten_for_ref - atten_now;
            spl = ref + diff_atten;
        else
            spl = dB_level(hfig_ballgui.ch2.level_index);
        end
         
end




%------------------------------------------------------------------------

% --- Executes on key press over figure1 with no controls selected.
function My_KeyPressFcn(src,eventdata)

handles = guidata(src);
switch get(src,'CurrentKey')
    % channel 1 controls
    case 'insert'
        if get(handles.mute1,'Value'),
            set(handles.mute1,'Value',0);
        else
            set(handles.mute1,'Value',1);
        end
        mute1_Callback(handles.mute1,eventdata,handles);
    case 'rightarrow'
        ch1hi_Callback(handles.ch1hi,eventdata,handles);
    case 'leftarrow'
        ch1lo_Callback(handles.ch1lo,eventdata,handles);
    case 'uparrow'
        ch1up_Callback(handles.ch1up,eventdata,handles);
    case 'downarrow'
        ch1dn_Callback(handles.ch1dn,eventdata,handles);
        % channel 2 controls
    case 'pageup'
        if get(handles.mute2,'Value'),
            set(handles.mute2,'Value',0);
        else
            set(handles.mute2,'Value',1);
        end
        mute2_Callback(handles.mute2,eventdata,handles);
    case 'pagedown'
        ch2hi_Callback(handles.ch2hi,eventdata,handles);
    case 'delete'
        ch2lo_Callback(handles.ch2lo,eventdata,handles);
    case 'home'
        ch2up_Callback(handles.ch2up,eventdata,handles);
    case 'end'
        ch2dn_Callback(handles.ch2dn,eventdata,handles);
    case 'space'
        go_button_Callback(handles.go_button,eventdata,handles);
    case 'y'
        save_button_Callback(handles.save_button,eventdata,handles);

end


%----------------------------------------------
function dat = stimulate(handles)

global hfig_ballgui
global hfig_nidaqsetup
global hfig_treadmill_setup


if hfig_nidaqsetup.mode == 0;
    srate = 44100;
    set(hfig_ballgui.ao,'SampleRate',srate);
else
    srate = hfig_ballgui.ch1.current_stimparam.stimsrate;
    set(hfig_ballgui.ao,'SampleRate',srate);
end
 
silence = [];

 Ch1_onset_delay = hfig_ballgui.ch1.current_stimparam.delay;
 Ch2_onset_delay = hfig_ballgui.ch2.current_stimparam.delay;
 
 Ch1_signal = hfig_ballgui.ch1.current_stimparam.signal;
 Ch2_signal = hfig_ballgui.ch2.current_stimparam.signal;

 

% Create silent buffers to adjust for timing between Ch1 and Ch2

sig1_silence_pts = round(Ch1_onset_delay * srate/1000);
sig2_silence_pts = round(Ch2_onset_delay * srate/1000);

sig1_silence = [zeros(1,sig1_silence_pts)];
sig2_silence = [zeros(1,sig2_silence_pts)];

if Ch1_onset_delay ~=0
    Ch1_signal = [sig1_silence, Ch1_signal];
elseif Ch2_onset_delay~=0
    Ch2_signal= [sig2_silence, Ch2_signal];
end


 if length(Ch1_signal) > length(Ch2_signal)
    diff = length(Ch1_signal) - length(Ch2_signal);
    silence = zeros(1, diff);
    Ch2_signal= [Ch2_signal, silence];
 elseif length(Ch2_signal) >length(Ch1_signal)
    diff = length(Ch2_signal) - length(Ch1_signal);
    silence = zeros(1,diff);
    Ch1_signal= [Ch1_signal, silence];
 end

      
% Reads Ch1 and Ch2 sound levels

if hfig_ballgui.TDT.status == -1; % sound level controlled by software and not tdt

   
    if isfield(hfig_ballgui.ch1.current_stimparam, 'filename') == 0    
     if hfig_ballgui.ch1.current_stimparam.revph ==1
         Ch1_signal = -Ch1_signal;
     end
    end
    
    
    if isfield(hfig_ballgui.ch2.current_stimparam, 'filename') == 0    
     if hfig_ballgui.ch2.current_stimparam.revph ==1
         Ch2_signal = -Ch2_signal;
     end
    end
    
    ch1_playback = Ch1_signal;
    ch2_playback = Ch2_signal;
    
    ch1_playback = ch1_playback* hfig_ballgui.ch1.level;
    ch2_playback = ch2_playback* hfig_ballgui.ch2.level;
    
else
    if isfield(hfig_ballgui.ch1.current_stimparam, 'filename') == 0    
     if hfig_ballgui.ch1.current_stimparam.revph ==1
         Ch1_signal = -Ch1_signal;
     end
    end
    
    
    if isfield(hfig_ballgui.ch2.current_stimparam, 'filename') == 0    
     if hfig_ballgui.ch2.current_stimparam.revph ==1
         Ch2_signal = -Ch2_signal;
     end
    end
    ch1_playback = Ch1_signal;
    ch2_playback = Ch2_signal;
    
    %do nothing because levels are set with attenuator controls
    
    %function here to check for equal acoustic output
    
end


if hfig_nidaqsetup.mode == 2; %capture on with nidaq
    
    hfig_treadmill_setup.status = 0;
    
    [row col] = size(ch1_playback);
    
    if col > 1
        ch1_playback = ch1_playback';
        ch2_playback = ch2_playback';
    end
     
    %--------------------------
    putdata(hfig_ballgui.ao,[ch1_playback, ch2_playback]);
    set(handles.go_button, 'Enable', 'off');

    start([hfig_ballgui.ao, hfig_ballgui.ai]);
    %--------------------------

    trigger([hfig_ballgui.ao, hfig_ballgui.ai]);
    

    [data,time] = getdata(hfig_ballgui.ai);
    stop([hfig_ballgui.ao, hfig_ballgui.ai]);
    set(handles.go_button, 'Enable', 'on');
    
    dat.time = time;
    dat.data = data;
    axes(handles.ch1datacq);
    plot(time, data(:,1));
    
    
    axes(handles.ch2datacq);
    plot(time, data(:,2));
    pause(1)

elseif hfig_nidaqsetup.mode == 1; %capture off. Stimulus presentation with nidaq
    
    [row col] = size(ch1_playback);
    
    if col > 1
        ch1_playback = ch1_playback';
        ch2_playback = ch2_playback';
    end
    
    
    playback_time = round(length(ch1_playback)/srate);
    %--------------------------
    putdata(hfig_ballgui.ao,[ch1_playback ch2_playback]);
    set(handles.go_button, 'Enable', 'off');
    %--------------------------
    
    if hfig_treadmill_setup.status == 1; % using treadmill
    
        set(handles.ballplot, 'visible', 'on');
        set(hfig_ballgui.ao,'TriggerType','Hwdigital');
        set(hfig_ballgui.ao, 'HwDigitalTriggerSource', 'PFI0');
        set(hfig_ballgui.ao, 'TriggerCondition', 'PositiveEdge');
        start(hfig_ballgui.ao);
        
    %--------------------------
    fopen(hfig_treadmill_setup.serial_interface);
    fwrite(hfig_treadmill_setup.serial_interface,255)
    %--------------------------

    ba = 0;

        while ba < hfig_treadmill_setup.npts,
            ba = hfig_treadmill_setup.serial_interface.BytesAvailable;
        end

        try
            poop = fread(hfig_treadmill_setup.serial_interface,...
                hfig_treadmill_setup.serial_interface.BytesAvailable);
                 if poop(1)==0 && poop(2)==0,
                     poop=poop(3:end);
                 end      
         
             x=5*(poop(find(poop==1)+1)-128);%/255;
             y=5*(poop(find(poop==0)+1)-128);%/255;
     
             fix = length(x)-length(y);
 
             x = x(1:end-fix);
        end

    fwrite(hfig_treadmill_setup.serial_interface,254)
    fclose(hfig_treadmill_setup.serial_interface);
    
    stop(hfig_ballgui.ao)
    set(handles.go_button, 'Enable', 'on');
    %---------------
    cx = cumsum(x);
    cy = cumsum(y);
    %---------------
    
    cum_x = -cx;
    cum_x = cum_x/796.89; % Every 796 units per real cm of movement
    cum_y = cy;
    cum_y = cum_y/778.21;
    [th hfig_ballgui.autotrack.current_rho] = cart2pol(cum_x, cum_y);
    
    set(handles.text_dist, 'String', num2str(hfig_ballgui.autotrack.current_rho));

    update_TDTatten(1,hfig_ballgui);
    
    axes(handles.ballplot);
    plot(cum_x,cum_y,'.');
    maxdat=max(abs([cx; cy]));
    if ~maxdat, maxdat = 1;, end
        set(handles.ballplot,'xlim',[-maxdat maxdat],'ylim',[-maxdat maxdat])%,'visible','off')
    drawnow

    dat = [x y];
    
    else
        
        start(hfig_ballgui.ao);
        wait(hfig_ballgui.ao,playback_time + 5);
        stop(hfig_ballgui.ao);
        set(handles.go_button, 'Enable', 'on');
    
    
    cla(handles.ch1datacq)
    cla(handles.ch2datacq)
    dat = [];
    
    end
    
else %using winsound
    %--------------------------
    
    if hfig_treadmill_setup.status == 1;

    %--------------------------
    fopen(hfig_treadmill_setup.serial_interface);
    fwrite(hfig_treadmill_setup.serial_interface,255)
    %--------------------------

    ba = 0;

        while ba < hfig_treadmill_setup.npts,
            ba = hfig_treadmill_setup.serial_interface.BytesAvailable;
        end

        try
            poop = fread(hfig_treadmill_setup.serial_interface,...
                hfig_treadmill_setup.serial_interface.BytesAvailable);
                if poop(1)==0 && poop(2)==0,
                    poop=poop(3:end);
                end      
        
            x=5*(poop(find(poop==1)+1)-128);%/255;
            y=5*(poop(find(poop==0)+1)-128);%/255;
    
            fix = length(x)-length(y);

            x = x(1:end-fix);
        end

        fwrite(hfig_treadmill_setup.serial_interface,254)

        fclose(hfig_treadmill_setup.serial_interface);
    end
    
        
    [row col] = size(ch1_playback);
    
    if col > 1
        ch1_playback = ch1_playback';
        ch2_playback = ch2_playback';
    end
    
    putdata(hfig_ballgui.ao,[ch1_playback ch2_playback]);
    set(handles.go_button, 'Enable', 'off');
    start(hfig_ballgui.ao);
    wait(hfig_ballgui.ao,60);
    set(handles.go_button, 'Enable', 'on');
    stop(hfig_ballgui.ao);
    
    %--------------------------
    
    cla(handles.ch1datacq)
    cla(handles.ch2datacq)
    x = randperm(100)';
    
    dat = [x];
    
end

% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui
global dB_level


persistent sweeps;
if isempty(sweeps), sweeps = 1; end

% filename with path
% fname = strcat('trace_',strcat(num2str(sweeps),'.mat'));
% data = strcat('trace_',num2str(sweeps));
v = genvarname(strcat('trace_',num2str(sweeps)),who);
data = get(hObject,'UserData');
data.stimID = hfig_ballgui.filenames{hfig_ballgui.selected_index};
eval([v '= data;';]);
% stimname = strcat('stim_',num2str(sweeps));
dirname = get(handles.savefile_edit,'String');
% fullname = strcat(strcat(dirname,'\'),fname);
fullname = get(handles.savefile_edit,'String');

% data trace and stimulus parameters
ch1pars= hfig_ballgui.ch1.current_stimparam;
ch2pars= hfig_ballgui.ch2.current_stimparam;

% record current stimulus level for each channel
ch1pars.spl = data.ch1params.spl;
ch2pars.spl = data.ch2params.spl;
%ch1pars.spl = get_spl(1,handles);
%ch2pars.spl = get_spl(2,handles);
%stim = [ch1pars ch2pars];

save(fullname,v,'-append');

path = strcat(cd,'\', hfig_ballgui.current_exp);

saved_exp = whos('-file', path);

current_trace_saved = saved_exp(length(saved_exp)).name;
set(handles.trace_info, 'String', current_trace_saved);
sweeps = sweeps + 1;
set(hObject,'String','...');
set(hObject,'Enable','off');




% ------------------------------------------------------------------------

function my_closefcn(src,evnt)
delete(instrfind);
closereq

% ------------------------------------------------------------------------


% --- Executes on button press in save_stim.
function save_stim_Callback(hObject, eventdata, handles)
% hObject    handle to save_stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui

i = 0;

% keep running count of saved stim settings
persistent stimnum;
if isempty(stimnum), stimnum = 1; end
% create filename with path to save stim settings
fname = strcat('stimsave_',strcat(num2str(stimnum),'.mat'));
dirname = get(handles.savefile_edit,'String');
fullname = strcat(strcat(dirname,'\'),fname);

ch1pars = hfig_ballgui.ch1.current_stimparam;
ch2pars = hfig_ballgui.ch2.current_stimparam;


%checks if fields are matching between the two channels
        
ch1pars = orderfields(ch1pars);
ch2pars = orderfields(ch2pars);
        

fn1= fieldnames(ch1pars);
fn2= fieldnames(ch2pars);

[missing_field, i1, i2] = setxor(fn1,fn2);

for i = 1:length(i1)
    ch2pars.(char(fn1(i1(i)))) = [];
end

for j = 1:length(i2)
    ch1pars.(char(fn2(i2(j)))) = [];
end

ch1pars = orderfields(ch1pars);
ch2pars = orderfields(ch2pars);

stimsettings = [ch1pars ch2pars];

uisave('stimsettings',fullname);

stimnum = stimnum + 1;

% --- Executes on button press in plot_stimuli.
function plot_stimuli_Callback(hObject, eventdata, handles)
% hObject    handle to plot_stimuli (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui
global hfig_nidaqsetup

if hfig_nidaqsetup.mode == 0;
    srate = 44100;
else
    srate = hfig_ballgui.ch1.current_stimparam.stimsrate;
end
 
silence = [];

 Ch1_onset_delay = hfig_ballgui.ch1.current_stimparam.delay;
 Ch2_onset_delay = hfig_ballgui.ch2.current_stimparam.delay;
 
 Ch1_signal = hfig_ballgui.ch1.current_stimparam.signal;
 Ch2_signal = hfig_ballgui.ch2.current_stimparam.signal;

 

% Create silent buffers to adjust for timing between Ch1 and Ch2

sig1_silence_pts = round(Ch1_onset_delay * srate/1000);
sig2_silence_pts = round(Ch2_onset_delay * srate/1000);

sig1_silence = [zeros(1,sig1_silence_pts)];
sig2_silence = [zeros(1,sig2_silence_pts)];

if Ch1_onset_delay ~=0
    Ch1_signal = [sig1_silence, Ch1_signal];
elseif Ch2_onset_delay~=0
    Ch2_signal= [sig2_silence, Ch2_signal];
end


 if length(Ch1_signal) > length(Ch2_signal)
    diff = length(Ch1_signal) - length(Ch2_signal);
    silence = zeros(1, diff);
    Ch2_signal= [Ch2_signal, silence];
 elseif length(Ch2_signal) >length(Ch1_signal)
    diff = length(Ch2_signal) - length(Ch1_signal);
    silence = zeros(1,diff);
    Ch1_signal= [Ch1_signal, silence];
 end

      
% Reads Ch1 and Ch2 sound levels

if hfig_nidaqsetup.mode == 0; % sound level controlled by software and not tdt
    ch1_playback = Ch1_signal* hfig_ballgui.ch1.level;
    ch2_playback = Ch2_signal* hfig_ballgui.ch2.level;
   
    if isfield(hfig_ballgui.ch1.current_stimparam, 'filename') == 0    
     if hfig_ballgui.ch1.current_stimparam.revph ==1
         Ch1_signal = -Ch1_signal;
     end
    end
    
    
    if isfield(hfig_ballgui.ch2.current_stimparam, 'filename') == 0    
     if hfig_ballgui.ch1.current_stimparam.revph ==1
         Ch2_signal = -Ch2_signal;
     end
    end
    
else
    
    if isfield(hfig_ballgui.ch1.current_stimparam, 'filename') == 0    
     if hfig_ballgui.ch1.current_stimparam.revph ==1
         Ch1_signal = -Ch1_signal;
     end
    end
    
    
    if isfield(hfig_ballgui.ch2.current_stimparam, 'filename') == 0    
     if hfig_ballgui.ch1.current_stimparam.revph ==1
         Ch2_signal = -Ch2_signal;
     end
    end
    
    ch1_playback = Ch1_signal;
    ch2_playback = Ch2_signal;
    
    %do nothing because levels are set with attenuator controls
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Ch1_time = 1/srate:1/srate:length(Ch1_signal)/srate;
Ch2_time = 1/srate:1/srate:length(Ch2_signal)/srate;


% [Ch1_time] = 0:(1000*length(Ch1_signal)/srate)/length(Ch1_signal):(1000*length(Ch1_signal)/srate);
% [Ch1_time] = Ch1_time(1:length(Ch1_signal));
%     
% [Ch2_time] = 0:(1000*length(Ch2_signal)/srate)/length(Ch2_signal):(1000*length(Ch2_signal)/srate);
% [Ch2_time] = Ch2_time(1:length(Ch2_signal));


figure();
subplot(2,1,1)

plot(Ch1_time, ch1_playback);
hold on
subplot(2,1,2)
plot(Ch2_time, ch2_playback, 'r');



% --- Executes on selection change in listbox_stimuli.
function listbox_stimuli_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_stimuli (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_stimuli contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_stimuli

global hfig_ballgui

hfig_ballgui.selected_index = get(handles.listbox_stimuli, 'Value');

hfig_ballgui.ch1.current_stimparam = hfig_ballgui.stimulus_group{hfig_ballgui.selected_index}(1);
update_TDTatten(1,hfig_ballgui);
update_TDTatten(2,hfig_ballgui);
hfig_ballgui.ch2.current_stimparam = hfig_ballgui.stimulus_group{hfig_ballgui.selected_index}(2);
% hfig_ballgui.ch2.current_stimparam.delay = 0.01;
% set(handles.edit_ch2_delay, 'String', '0.01')

update_TDTatten(2,hfig_ballgui);

if isfield(hfig_ballgui.ch1.current_stimparam, 'filename') == 1
    set(handles.ch1lo, 'Enable', 'off');
    set(handles.ch1hi, 'Enable', 'off');
else
    set(handles.ch1lo, 'Enable', 'on');
    set(handles.ch1hi, 'Enable', 'on');
end

if isfield(hfig_ballgui.ch2.current_stimparam, 'filename') == 1
    set(handles.ch2lo, 'Enable', 'off');
    set(handles.ch2hi, 'Enable', 'off');
else
    set(handles.ch2lo, 'Enable', 'on');
    set(handles.ch2hi, 'Enable', 'on');
end


update_channel_summary(handles,1);
update_channel_summary(handles,2);
%handles = update_info(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox_stimuli_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_stimuli (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_load_stimset_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_stimset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui

%retrieve GUI data, i.e. the handles structure
handles = guidata(hObject);

current_directory = cd;

dname = uigetdir(cd);
files = dir(fullfile(dname,'*.mat'));

% load *.mat stim files
% need to work on improving memory usuage here
% have file names loaded in the listbox but not the files themselves.
% files are to be loaded through a selection call back.

for i = 1:length(dir(fullfile(dname, '*.mat')))
    load(strcat(dname,'\',files(i).name));
    
    hfig_ballgui.stim_index = hfig_ballgui.stim_index_max;
    
    % Saves name of opened file into a struct called stim_filename
    hfig_ballgui.filenames(hfig_ballgui.stim_index) = cellstr(files(i).name);
    
    % Retrieves stimuli parameters from file and stores in stimulus group
    % Displays name of files in listbox
    
    hfig_ballgui.stimulus_group{hfig_ballgui.stim_index} = stimsettings;
    set(handles.listbox_stimuli,  'String', hfig_ballgui.filenames, ...
                                  'Value', hfig_ballgui.stim_index);                                        

    % Increments index for listbox
    hfig_ballgui.stim_index_max = hfig_ballgui.stim_index_max + 1;
end

set(handles.pushbutton_remove, 'enable', 'on');

listbox_stimuli_Callback(hObject, [], handles);

% Update handles data structure
guidata(hObject, handles);
    



% --------------------------------------------------------------------
function menu_device_Callback(hObject, eventdata, handles)
% hObject    handle to menu_device (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_nidaq_Callback(hObject, eventdata, handles)
% hObject    handle to menu_nidaq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui
global hfig_nidaqsetup

nidaqsetup;


% --------------------------------------------------------------------
function menu_winsound_Callback(hObject, eventdata, handles)
% hObject    handle to menu_winsound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui
global hfig_nidaqsetup

hfig_nidaqsetup.mode = 0; 

srate = 44100;

hfig_ballgui.ao = analogoutput('winsound');
addchannel(hfig_ballgui.ao,1:2);
set(hfig_ballgui.ao,'SampleRate',srate);
set(hfig_ballgui.ao,'TriggerType', 'Immediate');

function edit_ch2_delay_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ch2_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ch2_delay as text
%        str2double(get(hObject,'String')) returns contents of edit_ch2_delay as a double

global hfig_ballgui

hfig_ballgui.ch2.current_stimparam.delay = str2num(get(hObject, 'String'));


% --- Executes during object creation, after setting all properties.
function edit_ch2_delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ch2_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ch1_delay_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ch1_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ch1_delay as text
%        str2double(get(hObject,'String')) returns contents of edit_ch1_delay as a double

global hfig_ballgui

hfig_ballgui.ch1.current_stimparam.delay = str2num(get(hObject, 'String'));


% --- Executes during object creation, after setting all properties.
function edit_ch1_delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ch1_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_remove.
function pushbutton_remove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui

handles = guidata(hObject);

if hfig_ballgui.stim_index ~=0;
    ind = get(handles.listbox_stimuli, 'value');

    hfig_ballgui.stimulus_group = hfig_ballgui.stimulus_group(setdiff(1:length(hfig_ballgui.stimulus_group),ind));
    hfig_ballgui.filenames = hfig_ballgui.filenames(setdiff(1:length(hfig_ballgui.filenames),ind));
    
    set(handles.listbox_stimuli, 'String',...
        hfig_ballgui.filenames, 'value', 1);
           

    hfig_ballgui.stim_index = hfig_ballgui.stim_index -1;
    hfig_ballgui.stim_index_max = hfig_ballgui.stim_index_max -1;
    
    if hfig_ballgui.stim_index ==0;
        set(handles.pushbutton_remove, 'enable', 'off');
    end

    cla(handles.chan1plot);
    cla(handles.chan2plot);
end

% 
function update_TDTatten(chan,handles)

global hfig_ballgui

%sound_dur = 250;

 if hfig_ballgui.TDT.status ==1
 switch chan
     case 1
         if hfig_ballgui.autotrack ==1
             
             if  and(hfig_ballgui.autotrack.current_rho > 1, hfig_ballgui.autotrack.ub ~= 1)
                 new_atten = invoke(hfig_ballgui.TDT.PA5x1,'GetAtten') + 3;
                 invoke(hfig_ballgui.TDT.PA5x1, 'SetAtten', new_atten);
                 spl = get_spl(1, hfig_ballgui);
                 set(handles.text_threshold_spl, 'text', num2str(spl));
                 
                 %increases count for first iteration of the autotrack
                 hfig_ballgui.autotrack.count = hfig_ballgui.autotrack.count +1;
             else
                 if hfig_ballgui.autotrack.count == 0
                     new_atten = invoke(hfig_ballgui.TDT.PA5x1,'GetAtten') - 3;
                     invoke(hfig_ballgui.TDT.PA5x1, 'SetAtten', new_atten);
                 else
                     hfig_ballgui.autotrack.ub = 1; % animal and stopped once
                     new_atten = invoke(hfig_ballgui.TDT.PA5x1,'GetAtten') + 1;
                     invoke(hfig_ballgui.TDT.PA5x1, 'SetAtten', new_atten);
                     
                     spl = get_spl(1, hfig_ballgui);
                     set(handles.text_threshold_spl, 'text', num2str(spl));
                 end
             end
         else
             current_freq = hfig_ballgui.ch1.current_stimparam.freq;
             ind = find(hfig_ballgui.ch1.calibration.freq == current_freq);
             atten = hfig_ballgui.ch1.calibration.atten(ind) + 12;
             invoke(hfig_ballgui.TDT.PA5x1, 'SetAtten', atten);
         
         
%          ch1 = hfig_ballgui.ch1.current_stimparam;
%          ch1_sound_dur = round(ch1.pdur * ch1.pnum);
        
             dB_adjust = 0; % abs(20*log10(ch1_sound_dur/sound_dur));
             atten_now = invoke(hfig_ballgui.TDT.PA5x1, 'GetAtten');
        
%             if ch1_sound_dur < sound_dur
%                 invoke(hfig_ballgui.TDT.PA5x1, 'SetAtten', atten_now - dB_adjust);
%             elseif ch1_sound_dur > sound_dur
%                 invoke(hfig_ballgui.TDT.PA5x1, 'SetAtten', atten_now + dB_adjust);
%             end
         end
     case 2
         if hfig_ballgui.autotrack ==1
         else
             
             current_freq = hfig_ballgui.ch2.current_stimparam.freq;
             ind = find(hfig_ballgui.ch2.calibration.freq == current_freq);
             atten = hfig_ballgui.ch2.calibration.atten(ind) + 12;
             invoke(hfig_ballgui.TDT.PA5x2, 'SetAtten', atten);
         
         
%          ch2 = hfig_ballgui.ch2.current_stimparam;
%          ch2_sound_dur = ch2.pdur * ch2.pnum;
        
             dB_adjust = 0; %abs(20*log10(ch2_sound_dur/sound_dur));
             atten_now = invoke(hfig_ballgui.TDT.PA5x2, 'GetAtten');
        
%             if ch2_sound_dur < sound_dur
%                 invoke(hfig_ballgui.TDT.PA5x2, 'SetAtten', atten_now - dB_adjust);
%             elseif ch2_sound_dur > sound_dur
%                 invoke(hfig_ballgui.TDT.PA5x2, 'SetAtten', atten_now + dB_adjust);
%             end
         end
 end
end
% 
% spl = ref + (atten_for_ref - atten_now);

% --- Executes on button press in togglebutton_continuous.
function togglebutton_continuous_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_continuous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton_continuous

global hfig_ballgui

toggle_state = get(handles.togglebutton_continuous, 'value');

if toggle_state == 1
    if length(hfig_ballgui.ch1.current_stimparam.signal) > length(hfig_ballgui.ch2.current_stimparam.signal)
        stimdur = (length(hfig_ballgui.ch1.current_stimparam.signal)/hfig_ballgui.ch1.current_stimparam.stimsrate) + 1;
    else
        stimdur = (length(hfig_ballgui.ch2.current_stimparam.signal)/hfig_ballgui.ch2.current_stimparam.stimsrate) + 1;
    end
        
    hfig_ballgui.timerobj = timer('TimerFcn', {@go_button_Callback, handles}, 'ExecutionMode', 'fixedRate', 'Period', stimdur );
    start(hfig_ballgui.timerobj);
else
    stop(hfig_ballgui.timerobj);
    delete(hfig_ballgui.timerobj);
    clear hfig_ballgui.timerobj
end

guidata(hObject, handles);



% --------------------------------------------------------------------
function menu_treadmill_Callback(hObject, eventdata, handles)
% hObject    handle to menu_treadmill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_treadmill_setup
global hfig_ballgui

handles = guidata(hObject);

if hfig_treadmill_setup.status == 1;
    set(handles.ch1datacq, 'visible', 'off');
    set(handles.ch2datacq, 'visible', 'off');
    set(handles.ballplot, 'visible', 'on');
else
    set(handles.ch1datacq, 'visible', 'on');
    set(handles.ch2datacq, 'visible', 'on');
    set(handles.ballplot, 'visible', 'off');
end

hfig_ballgui.handles = handles;
treadmillsetup;



% --- Executes on button press in pushbutton_avg.
function pushbutton_avg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui

k = 0;
dat = [];

last_trace=struct('ch1params',{},'ch2params',{},'trace',{});

if hfig_nidaqsetup.mode == 2
    for k = 1:20
        set(handles.pushbutton_avg, 'string', num2str(20-k))
        pause(1) % 1 second pause
        temp = stimulate(handles);
        dat.time = temp.time;
        dat.data = [dat.data temp];
    end
    
    avg_dat = mean(dat.data')';
    
else
    for k = 1:20
        set(handles.pushbutton_avg, 'string', num2str(20-k))
        pause(1) % 1 second pause
        dat = [dat stimulate(handles)];
    end
    
    avg_dat = mean(dat')';
    
end



% set up for saving a trace
last_trace(1).ch1params = hfig_ballgui.ch1.current_stimparam;
last_trace(1).ch2params = hfig_ballgui.ch2.current_stimparam;

if hfig_ballgui.ch1.level ==0 
    last_trace(1).ch1params.spl = 'mute';
else
    last_trace(1).ch1params.spl = get_spl(1, hfig_ballgui);
end

if hfig_ballgui.ch2.level ==0
    last_trace(1).ch2params.spl = 'mute';
else    
    last_trace(1).ch2params.spl = get_spl(2, hfig_ballgui);
end

last_trace(1).trace = dat;
last_trace(1).avg_trace = avg_dat;

set(handles.save_button,'Enable','on')
set(handles.save_button,'UserData',last_trace)
set(handles.save_button,'String','Save last')
set(handles.pushbutton_avg, 'String', '5 response avg')


% --- Executes when selected object is changed in uipanel_mode.
function uipanel_ch_switch_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_mode 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui

ch_select = get(handles.uipanel_ch_switch, 'SelectedObject');

switch get(ch_select, 'Tag') 
    case 'radiobutton_pm2_0'
        hfig_ballgui.TDT.pm2relay_chan = 0; % ch1 stimulus put through pm2relay index 0
        %do something
        invoke(hfig_ballgui.TDT.RP2, 'SetTagVal', 'ch_num', 0);
        invoke(hfig_ballgui.TDT.RP2, 'SetTagVal', 'ch_num', 0);
        invoke(hfig_ballgui.TDT.RP2, 'SetTagVal', 'ch_num', 0);
        hfig_ballgui.TDT.zBus.zBusTrigA(0,0,5)
    case 'radiobutton_pm2_1'
        hfig_ballgui.TDT.pm2relay_chan = 1; % ch1 stimulus put through pm2relay index 1
        invoke(hfig_ballgui.TDT.RP2, 'SetTagVal', 'ch_num', 1);
        invoke(hfig_ballgui.TDT.RP2, 'SetTagVal', 'ch_num', 1);
        invoke(hfig_ballgui.TDT.RP2, 'SetTagVal', 'ch_num', 1);
        hfig_ballgui.TDT.zBus.zBusTrigA(0,0,5)
        %do something
end


% --------------------------------------------------------------------
function menu_tdt_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function menu_pm2relay_Callback(hObject, eventdata, handles)
% hObject    handle to menu_pm2relay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% global hfig_ballgui
% 
% CD = 'USB';
% 
% PM2Relay_Status = get(handles.menu_pm2relay, 'label');
% 
% if  strcmp(PM2Relay_Status, 'PM2Relay ON') == 1 % TDT PMRelay is off
%     set(handles.uipanel_ch_switch, 'visible', 'on')
%     set(handles.menu_pm2relay, 'label', 'PM2Relay OFF')
%     
%     % load rvds circuit
%     circ_name = 'pm2relay_switch.rcx';
%     invoke(hfig_ballgui.TDT.zBus,'zBusSync',3);
% 
%     %Circuit_Path = circ_name;
%     hfig_ballgui.TDT.RP2=actxcontrol('RPco.x',[5 5 26 26]);
%     
% 
%     invoke(hfig_ballgui.TDT.RP2,'ConnectRP2',CD,1); %connects RP2 via USB or Xbus given the proper device number
%     invoke(hfig_ballgui.TDT.RP2,'LoadCOF',circ_name); % Loads circuit'
%     invoke(hfig_ballgui.TDT.RP2,'Run'); %Starts Circuit'
%     Status=double((invoke(hfig_ballgui.TDT.RP2,'GetStatus')));%converts value to bin'
% 
%     if bitget(Status,1)==0;%checks for errors in starting circuit'
%         er='Error connecting to RP2_2 (output)'
%     elseif bitget(Status,2)==0; %checks for connection'
%         er='Error loading circuit'
%     elseif bitget(Status,3)==0
%         er='error running circuit'
%     else  
%         er='Output circuit loaded and running'
%     end
%     
% else
%     set(handles.uipanel_ch_switch, 'visible', 'off')
%     set(handles.menu_pm2relay, 'label', 'PM2Relay ON')
% end


% --------------------------------------------------------------------
function menu_autotrack_Callback(hObject, eventdata, handles)
% hObject    handle to menu_autotrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_autotrack_status_Callback(hObject, eventdata, handles)
% hObject    handle to menu_autotrack_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_ballgui

if hfig_ballgui.autotrack == 0
    hfig_ballgui.autotrack = 1;
    hfig_ballgui.autotrack.count = 0;
    hfig_ballgui.autotrack.ub = 0;
    set(handles.menu_autotrack_status, 'label', 'Autotrack OFF');
else
    hfig_ballgui.autotrack = 0;
    hfig_ballgui.autotrack.count = 0;
    set(handles.menu_autotrack_status, 'label', 'Autotrack ON');
end

    
