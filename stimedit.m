function varargout = stimedit(varargin)
% STIMEDIT M-file for stimedit.fig
%      STIMEDIT, by itself, creates a new STIMEDIT or raises the existing
%      singleton*.
%
%      H = STIMEDIT returns the handle to a new STIMEDIT or the handle to
%      the existing singleton*.
%
%      STIMEDIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIMEDIT.M with the given input arguments.
%
%      STIMEDIT('Property','Value',...) creates a new STIMEDIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stimedit_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stimedit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stimedit

% Last Modified by GUIDE v2.5 13-May-2011 10:56:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stimedit_OpeningFcn, ...
                   'gui_OutputFcn',  @stimedit_OutputFcn, ...
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


% --- Executes just before stimedit is made visible.
function stimedit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stimedit (see VARARGIN)

% Choose default command line output for stimedit
%  handles.output = hObject;
% handles.output = varargin{2};
% Update handles structure

global hfig_stimedit
global hfig_ballgui


hfig_stimedit = [];
guidata(hObject, handles);

hfig_stimedit.ch1append = 0;
hfig_stimedit.ch2append = 0;

hfig_stimedit.append_signal = [];
hfig_stimedit.new_signal = [];

hfig_stimedit.ch1_include_silence = 0;
hfig_stimedit.ch2_include_silence = 0;

hfig_stimedit.stimsrate = [22050 32000 44100 48000 64000 88200 96000 192000 250000 500000];


% Get current stimulus parameters from struct argument
if (nargin > 3),
    
    if varargin{1}==1,
        hfig_stimedit.current_chan = 1;
        set(handles.title,'String','Channel 1 Settings');
        set(hObject,'Color',[0.379 0.487 0.702]);
        mainpos = varargin{4};
        set(hObject,'Position',[mainpos(1)-2 mainpos(2)-2 60.3333 53.8125]);
    elseif varargin{1}==2,
        hfig_stimedit.current_chan = 2;
        set(handles.title,'String','Channel 2 Settings');
        set(hObject,'Color',[0.702 0.314 0.191]);
        mainpos = varargin{4};
        set(hObject,'Position',[mainpos(1)+126 mainpos(2)-2 60.3333 53.8125]);
    end


    if isfield(varargin{2},'pdur') ==1; % stimprog generated stimuli
    
    hfig_stimedit.stimulus_type = 1;
        
    set(handles.freq_edit,  'String', num2str(varargin{2}.freq));
    set(handles.pdur_edit,  'String', num2str(varargin{2}.pdur));
    set(handles.ipi_edit,  'String', num2str(varargin{2}.ipi));
    set(handles.ramp_edit,  'String', num2str(varargin{2}.ramp));
    set(handles.pnum_edit,  'String', num2str(varargin{2}.pnum));
    set(handles.rev_phase,  'Value', varargin{2}.revph);
    set(handles.noise,  'Value', varargin{2}.noise);
    set(handles.chrpnum_edit,  'String', num2str(varargin{2}.chrpnum));
    set(handles.ici_edit, 'String', num2str(varargin{2}.ici));
    set(handles.popupmenu_stimsrate, 'Enable', 'on');
    set(handles.popupmenu_stimsrate, 'String', hfig_stimedit.stimsrate);
           
        if hfig_stimedit.current_chan ==1
            hfig_stimedit.ch1.freq = varargin{2}.freq;
            hfig_stimedit.ch1.pdur = varargin{2}.pdur;
            hfig_stimedit.ch1.ipi = varargin{2}.ipi;
            hfig_stimedit.ch1.ramp = varargin{2}.ramp;
            hfig_stimedit.ch1.pnum = varargin{2}.pnum;
            hfig_stimedit.ch1.revph = varargin{2}.revph;
            hfig_stimedit.ch1.noise = varargin{2}.noise;
            hfig_stimedit.ch1.chrpnum = varargin{2}.chrpnum;
            hfig_stimedit.ch1.ici = varargin{2}.ici;
            hfig_stimedit.ch1.delay = varargin{2}.delay;
            hfig_stimedit.ch1.signal = varargin{2}.signal;
            hfig_stimedit.ch1.stimsrate = varargin{2}.stimsrate;
            
            ind_stimsrate = find(hfig_stimedit.ch1.stimsrate == hfig_stimedit.stimsrate);
            set(handles.popupmenu_stimsrate, 'value', ind_stimsrate);
        
            if hfig_stimedit.ch1.chrpnum > 1
                set(handles.ici_edit, 'Enable', 'On');
            end
        
            if hfig_stimedit.ch1.noise ==1
                set(handles.rev_phase, 'Enable', 'off');
                set(handles.freq_edit, 'Enable', 'off');
            end
        
                   
        else
            
            hfig_stimedit.ch2.freq = varargin{2}.freq;
            hfig_stimedit.ch2.pdur = varargin{2}.pdur;
            hfig_stimedit.ch2.ipi = varargin{2}.ipi;
            hfig_stimedit.ch2.ramp = varargin{2}.ramp;
            hfig_stimedit.ch2.pnum = varargin{2}.pnum;
            hfig_stimedit.ch2.revph = varargin{2}.revph;
            hfig_stimedit.ch2.noise = varargin{2}.noise;
            hfig_stimedit.ch2.chrpnum = varargin{2}.chrpnum;
            hfig_stimedit.ch2.ici = varargin{2}.ici;
            hfig_stimedit.ch2.delay = varargin{2}.delay;
            hfig_stimedit.ch2.signal = varargin{2}.signal;
            hfig_stimedit.ch2.stimsrate = varargin{2}.stimsrate;
            
            ind_stimsrate = find(hfig_stimedit.ch2.stimsrate == hfig_stimedit.stimsrate);
            set(handles.popupmenu_stimsrate, 'value', ind_stimsrate);
            
        
            if hfig_stimedit.ch2.chrpnum > 1
                set(handles.ici_edit, 'Enable', 'On');
            end
        
            if hfig_stimedit.ch2.noise ==1
                set(handles.rev_phase, 'Enable', 'off');
                set(handles.freq_edit, 'Enable', 'off');
            end  
        
        end
           
        handles.output = varargin{2};
        guidata(hObject, handles);
    else
    
    hfig_stimedit.stimulus_type = 2; % imported wav
    
    if hfig_stimedit.current_chan ==1
        hfig_stimedit.imported_wav = hfig_ballgui.ch1.current_stimparam;
    else
        hfig_stimedit.imported_wav = hfig_ballgui.ch2.current_stimparam;
    end
    
    set(handles.freq_edit,  'String', num2str(0));
    set(handles.pdur_edit,  'String', num2str(0));
    set(handles.ipi_edit,  'String', num2str(0));
    set(handles.ramp_edit,  'String', num2str(0));
    set(handles.pnum_edit,  'String', num2str(0));
    set(handles.rev_phase,  'Value', 0);
    set(handles.noise,  'Value', 0);
    set(handles.chrpnum_edit,  'String', num2str(0));
    set(handles.ici_edit, 'String', num2str(0));
    
    handles.output.freq = hfig_stimedit.imported_wav.freq;
    handles.output.pdur = 0;
    handles.ouput.ipi = 0;
    handles.output.ramp = 0;
    handles.output.pnum = 0;
    handles.output.rev_phase = 0;
    handles.output.noise = 0;
    handles.output.chrpnum = 0;
    handles.output.ici = 0;
    set(handles.popupmenu_stimsrate, 'Enable', 'off');
    
    end
end
    
% Populate the listbox
load_listbox(pwd,handles,varargin{3});
% Return figure handle as first output argument

s = get(handles.title,'String');
set(handles.title,'UserData',str2num(s(regexp(s,'\d')))); % extract channel number from figure title

% UIWAIT makes stimedit wait for user response (see UIRESUME)
 uiwait(handles.figure1);
 


% --- Outputs from this function are returned to the command line.
function varargout = stimedit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = get(handles.calfile_list,'UserData');

% The figure can be deleted now
delete(handles.figure1);


function pdur_edit_Callback(hObject, eventdata, handles)
% hObject    handle to pdur_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pdur_edit as text
%        str2double(get(hObject,'String')) returns contents of pdur_edit as a double

global hfig_stimedit

if hfig_stimedit.current_chan ==1
    hfig_stimedit.ch1.pdur = str2num(get(hObject,'String'));
else
    hfig_stimedit.ch2.pdur = str2num(get(hObject,'String'));
end

handles.output.pdur = str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pdur_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pdur_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ipi_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ipi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ipi_edit as text
%        str2double(get(hObject,'String')) returns contents of ipi_edit as a double

global hfig_stimedit

if hfig_stimedit.current_chan ==1
    hfig_stimedit.ch1.ipi = str2num(get(hObject,'String'));
else
    hfig_stimedit.ch2.ipi = str2num(get(hObject,'String'));
end

handles.output.ipi = str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ipi_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ipi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ramp_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ramp_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ramp_edit as text
%        str2double(get(hObject,'String')) returns contents of ramp_edit as a double

global hfig_stimedit

if hfig_stimedit.current_chan ==1
    hfig_stimedit.ch1.ramp = str2num(get(hObject,'String'));
else
    hfig_stimedit.ch2.ramp = str2num(get(hObject,'String'));
end
handles.output.ramp = str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ramp_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ramp_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pnum_edit_Callback(hObject, eventdata, handles)
% hObject    handle to pnum_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pnum_edit as text
%        str2double(get(hObject,'String')) returns contents of pnum_edit as a double

global hfig_stimedit

if hfig_stimedit.current_chan ==1                  
    hfig_stimedit.ch1.pnum = str2num(get(hObject,'String'));
    
    if (get(handles.noise, 'Value'))==1 && hfig_stimedit.ch1.pnum <1
        set(handles.pnum_edit, 'String', '1')
        hfig_stimedit.ch1.pnum = 1;
    end
        
            
    
else
    hfig_stimedit.ch2.pnum = str2num(get(hObject,'String'));
    
    if (get(handles.noise, 'Value'))==1 && hfig_stimedit.ch2.pnum <1
        set(handles.pnum_edit, 'String', '1')
        hfig_stimedit.ch2.pnum = 1;
    end
        
    
    
end

handles.output.pnum = str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pnum_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pnum_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rev_phase.
function rev_phase_Callback(hObject, eventdata, handles)
% hObject    handle to rev_phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rev_phase

global hfig_stimedit

if hfig_stimedit.current_chan ==1
    hfig_stimedit.ch1.revph = get(hObject,'Value');
else
    hfig_stimedit.ch2.revph = get(hObject,'Value');
end

handles.output.revph = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in done_button.
function done_button_Callback(hObject, eventdata, handles)
% hObject    handle to done_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_stimedit
global hfig_ballgui


if hfig_stimedit.current_chan ==1
    if hfig_stimedit.stimulus_type == 2
        hfig_stimedit.ch1 = [];
        hfig_stimedit.ch1.freq = hfig_stimedit.imported_wav.freq;
        hfig_stimedit.ch1.pdur = 0;
        hfig_stimedit.ch1.ipi = 0;
        hfig_stimedit.ch1.ramp = 0;
        hfig_stimedit.ch1.pnum = 0;
        hfig_stimedit.ch1.revph = 0;
        hfig_stimedit.ch1.noise = 0;
        hfig_stimedit.ch1.chrpnum = 0;
        hfig_stimedit.ch1.ici = 0;
        hfig_stimedit.ch1.delay = hfig_stimedit.imported_wav.delay;
        hfig_stimedit.ch1.signal = hfig_stimedit.imported_wav.signal;
        hfig_stimedit.ch1.stimsrate = hfig_stimedit.imported_wav.stimsrate;       
        hfig_stimedit.ch1.filename = hfig_stimedit.imported_wav.filename;
        
        
        hfig_ballgui.ch1.current_stimparam = hfig_stimedit.ch1;

    else   
        if hfig_stimedit.ch1append == 0;
            %hfig_stimedit.ch1.revph = 0;
            %hfig_stimedit.ch1.noise = 0;
            hfig_stimedit.ch1.appended_signal = [];
            hfig_stimedit.ch1.rand_ipi = 0;
            %hfig_stimedit.ch1.ici = 0;
            %hfig_stimedit.ch1.delay = 0;
            
            pt = pulse_train(hfig_stimedit.ch1);
            hfig_stimedit.ch1.signal = pt;
        
            %calls function from ballgui2 by using function handles
            %hfig_ballgui.handles.fhandles(hfig_ballgui.handles,1)
        else
            hfig_stimedit.ch1.signal = hfig_stimedit.new_signal;
            hfig_ballgui.ch1.current_stimparam.signal = hfig_stimedit.new_signal;
        end
    end
    
else
    
    if hfig_stimedit.stimulus_type == 2
        hfig_stimedit.ch2 = [];        
        hfig_stimedit.ch2.freq = hfig_stimedit.imported_wav.freq;
        hfig_stimedit.ch2.pdur = 0;
        hfig_stimedit.ch2.ipi = 0;
        hfig_stimedit.ch2.ramp = 0;
        hfig_stimedit.ch2.pnum = 0;
        hfig_stimedit.ch2.revph = 0;
        hfig_stimedit.ch2.noise = 0;
        hfig_stimedit.ch2.chrpnum = 0;
        hfig_stimedit.ch2.ici = 0;
        hfig_stimedit.ch2.delay = hfig_stimedit.imported_wav.delay;
        hfig_stimedit.ch2.signal = hfig_stimedit.imported_wav.signal;
        hfig_stimedit.ch2.stimsrate = hfig_stimedit.imported_wav.stimsrate;       
        hfig_stimedit.ch2.filename = hfig_stimedit.imported_wav.filename;
        
        hfig_ballgui.ch2.current_stimparam = hfig_stimedit.ch2;
    else
        if hfig_stimedit.ch2append == 0;
            %hfig_stimedit.ch2.revph = 0;
            %hfig_stimedit.ch2.noise = 0;
            hfig_stimedit.ch2.appended_signal = [];
            hfig_stimedit.ch2.rand_ipi = 0;
            %hfig_stimedit.ch2.ici = 0;
            %hfig_stimedit.ch2.delay =0;
            
            pt = pulse_train(hfig_stimedit.ch2);
            hfig_stimedit.ch2.signal = pt;
        
            %hfig_ballgui.handles.fhandles(hfig_ballgui.handles,2)
        else
            hfig_stimedit.ch2.signal = hfig_stimedit.new_signal;
            hfig_ballgui.ch2.current_stimparam.signal = hfig_stimedit.new_signal;
        end
    end
      
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


% --- Executes on selection change in calfile_list.
function calfile_list_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to calfile_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns calfile_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from calfile_list
    index_selected = get(handles.calfile_list,'Value');
    file_list = get(handles.calfile_list,'String');
    filename = file_list{index_selected};
    set(handles.calfile_list,'UserData',filename);
    
    % update frequency to match new calfile
    load_freqlist(get(handles.title,'UserData'),handles);
    index = get(handles.freqlist,'Value');
    flist = cellstr(get(handles.freqlist,'String'));
    handles.output(1) = str2num(flist{index});
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function calfile_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calfile_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------
% Read the current directory and sort the names
% ------------------------------------------------------------
function load_listbox(dir_path,handles,currentcal)
cd (dir_path)
% dir_struct = dir(dir_path);
dir_struct = dir('*cal.mat');
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = sorted_index;
guidata(handles.figure1,handles);
for ii = 1:length(sorted_names),
    temp(ii) = strcmp(currentcal,sorted_names{ii});
end
ti = find(temp);
set(handles.calfile_list,'String',handles.file_names,...
	'Value',ti);
filelist=get(handles.calfile_list,'String');
set(handles.calfile_list,'UserData',filelist{ti});





% --- Executes on selection change in freqlist.
function freqlist_Callback(hObject, eventdata, handles)
% hObject    handle to freqlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns freqlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from freqlist
% load_freqlist(get(handles.title,'UserData'),handles);

% global hfig_stimedit
% global hfig_ballgui
% 
% 
% index = get(handles.freqlist,'Value');
% flist = cellstr(get(handles.freqlist,'String'));
% flistnum = str2num(get(handles.freqlist, 'String'));
% 
% if hfig_stimedit.current_chan ==1
%     hfig_stimedit.ch1.freq = flistnum(index);
%     hfig_ballgui.ch1.current_stimparam.freq = flistnum(index);
% else
%     hfig_stimedit.ch2.freq = flistnum(index);
%     hfig_ballgui.ch2.current_stimparam.freq = flistnum(index);
% end
% 
% 
% %handles.output(1) = str2num(flist{index});
% 
% guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function freqlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% function load_freqlist(chan,handles)
% % load frequency list for current cal file
% index_selected = get(handles.calfile_list,'Value');
% file_list = get(handles.calfile_list,'String');
% filename = file_list{index_selected};
% load(filename);
% set(handles.freqlist,'String',num2str(caldat(chan).freq'));
% 
% % set current selection in list to match current frequency
% indf = find(caldat(chan).freq==handles.current_freq);
% if indf,
%     set(handles.freqlist,'Value',indf);
% else
%     set(handles.freqlist,'Value',1);
% end
% % guidata(handles.figure1, handles);


function chrpnum_edit_Callback(hObject, eventdata, handles)
% hObject    handle to chrpnum_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chrpnum_edit as text
%        str2double(get(hObject,'String')) returns contents of chrpnum_edit as a double

global hfig_stimedit

if hfig_stimedit.current_chan ==1
    hfig_stimedit.ch1.chrpnum = str2num(get(hObject,'String'));
    
    if hfig_stimedit.ch1.chrpnum >1
        set(handles.ici_edit, 'Enable', 'On');
    else
        set(handles.ici_edit, 'Enable', 'Off');
    end
    
else
    hfig_stimedit.ch2.chrpnum = str2num(get(hObject,'String'));
    
    if hfig_stimedit.ch2.chrpnum >1
        set(handles.ici_edit, 'Enable', 'On');
    else
        set(handles.ici_edit, 'Enable', 'Off');
    end
    
end

handles.output.chrpnum = get(hObject,'Value');
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function chrpnum_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chrpnum_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ici_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ici_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ici_edit as text
%        str2double(get(hObject,'String')) returns contents of ici_edit as a double

global hfig_stimedit

if hfig_stimedit.current_chan ==1
    hfig_stimedit.ch1.ici = str2num(get(hObject,'String'));
else
    hfig_stimedit.ch2.ici = str2num(get(hObject,'String'));
end

handles.output.ici = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ici_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ici_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function delay_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delay_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in noise.
function noise_Callback(hObject, eventdata, handles)
% hObject    handle to noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of noise
global hfig_stimedit
global hfig_ballgui

% index = get(handles.freqlist,'Value');
% flist = cellstr(get(handles.freqlist,'String'));
% flistnum = str2num(get(handles.freqlist, 'String'));
ch1_freq = hfig_ballgui.ch1.current_stimparam.freq;
ch2_freq = hfig_ballgui.ch2.current_stimparam.freq;

if hfig_stimedit.current_chan ==1
    hfig_stimedit.ch1.noise = get(hObject,'Value');
    
    if hfig_stimedit.ch1.noise ==1 %checked
        set(handles.freq_edit,'Enable', 'off');
        set(handles.rev_phase, 'Enable', 'off');
        %hfig_stimedit.ch1.freq = 0;
        hfig_stimedit.ch1.revph = 0;
        hfig_ballgui.ch1.current_stimparam.freq = 0;
    else
        set(handles.freq_edit,'Enable', 'on');
        set(handles.rev_phase, 'Enable', 'on');
        %hfig_stimedit.ch1.noise = 0;
        hfig_stimedit.ch1.freq = ch1_freq;
        hfig_ballgui.ch1.current_stimparam.freq = ch1_freq;
    end
        
else
    hfig_stimedit.ch2.noise = get(hObject,'Value');
    
    if hfig_stimedit.ch2.noise ==1 %checked
        set(handles.freq_edit,'Enable', 'off');
        set(handles.rev_phase, 'Enable', 'off');
        %hfig_stimedit.ch2.freq = 0;
        hfig_stimedit.ch2.revph = 0;
        hfig_ballgui.ch2.current_stimparam.freq = 0;
    else
        set(handles.freq_edit,'Enable', 'on');
        set(handles.rev_phase, 'Enable', 'on');
        %hfig_stimedit.ch2.noise = 0;
        hfig_stimedit.ch2.freq = ch2_freq;
        hfig_ballgui.ch2.current_stimparam.freq = ch2_freq;
    end
end

handles.output.noise = get(hObject,'Value');
guidata(hObject, handles);




% --- Executes on button press in append.
function append_Callback(hObject, eventdata, handles)
% hObject    handle to append (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if get(handles.append, 'value') == 0
        set(handles.append, 'string', 'appd before');        
    else
        set(handles.append, 'string','appd after');        
    end

guidata(hObject, handles);  

    


% --- Executes on button press in use_append.
function use_append_Callback(hObject, eventdata, handles)
% hObject    handle to use_append (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_append

global hfig_stimedit
global hfig_ballgui

if hfig_stimedit.current_chan ==1
    hfig_stimedit.ch1append = get(hObject,'Value');
    hfig_ballgui.ch1append = hfig_stimedit.ch1append;
    
else
    hfig_stimedit.ch2append = get(hObject,'Value');
    hfig_ballgui.ch2append = hfig_stimedit.ch2append;
end
      
   
% --- Executes on button press in clear_append.
function clear_append_Callback(hObject, eventdata, handles)
% hObject    handle to clear_append (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_stimedit

if hfig_stimedit.current_chan == 1
    hfig_stimedit.ch1.new_signal = [];
else
    hfig_stimedit.ch2.new_signal = [];
    
end



% --- Executes on button press in silence.
function silence_Callback(hObject, eventdata, handles)
% hObject    handle to silence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of silence

global hfig_stimedit

if hfig_stimedit.current_chan == 1
    if get(hObject, 'value') == 1
        hfig_stimedit.ch1_include_silence = 1;
        
        set(handles.edit_silence, 'Enable', 'on');
              
        set(handles.rev_phase, 'Enable', 'off');
        set(handles.noise, 'Enable', 'off');
        
        set(handles.freq_edit,'Enable', 'off');
        set(handles.pdur_edit, 'Enable', 'off');
        set(handles.ipi_edit, 'Enable', 'off');
        set(handles.ramp_edit, 'Enable', 'off');
        set(handles.pnum_edit, 'Enable', 'off');
        set(handles.chrpnum_edit, 'Enable', 'off');     
    else
        hfig_stimedit.ch1_include_silence = 0;
        
        set(handles.rev_phase, 'Enable', 'on');
        set(handles.noise, 'Enable', 'on');
        
        set(handles.freq_edit,'Enable', 'on');
        set(handles.pdur_edit, 'Enable', 'on');
        set(handles.ipi_edit, 'Enable', 'on');
        set(handles.ramp_edit, 'Enable', 'on');
        set(handles.pnum_edit, 'Enable', 'on');
        set(handles.chrpnum_edit, 'Enable', 'on');
        set(handles.edit_silence, 'Enable', 'off');
    end
else
    if get(hObject, 'value') == 1
        hfig_stimedit.ch2_include_silence = 1;
        
        set(handles.edit_silence, 'Enable', 'on');
        
        set(handles.rev_phase, 'Enable', 'off');
        set(handles.noise, 'Enable', 'off');
        
        set(handles.freq_edit,'Enable', 'off');
        set(handles.pdur_edit, 'Enable', 'off');
        set(handles.ipi_edit, 'Enable', 'off');
        set(handles.ramp_edit, 'Enable', 'off');
        set(handles.pnum_edit, 'Enable', 'off');
        set(handles.chrpnum_edit, 'Enable', 'off'); 
        
    else
        hfig_stimedit.ch2_include_silence = 0;
        
        set(handles.freq_edit,'Enable', 'on');
        set(handles.rev_phase, 'Enable', 'on');
        set(handles.noise, 'Enable', 'on');
        
        set(handles.pdur_edit, 'Enable', 'on');
        set(handles.ipi_edit, 'Enable', 'on');
        set(handles.ramp_edit, 'Enable', 'on');
        set(handles.pnum_edit, 'Enable', 'on');
        set(handles.chrpnum_edit, 'Enable', 'on');
        set(handles.edit_silence, 'Enable', 'off');
    end;    
end

guidata(hObject, handles);



function edit_silence_Callback(hObject, eventdata, handles)
% hObject    handle to edit_silence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_silence as text
%        str2double(get(hObject,'String')) returns contents of edit_silence as a double

global hfig_stimedit
global hfig_nidaqsetup

if hfig_nidaqsetup.mode == 0;
    srate = 44100;
else
    srate = hfig_nidaqsetup.stimsrate_selected_index;
end

if hfig_stimedit.current_chan ==1
        
        ch1silencedur = str2num(get(hObject,'String'));
    
        silence_stim = ch1silencedur; 
        silence_stim_pts = round(silence_stim * srate/1000);
        append_signal = [zeros(1,silence_stim_pts)];
    
else
        ch2silencedur = str2num(get(hObject,'String'));
    
        silence_stim = ch2silencedur; 
        silence_stim_pts = round(silence_stim * srate/1000);
        append_signal = [zeros(1,silence_stim_pts)];

end

handles.output.silence = get(hObject,'Value');
hfig_stimedit.append_signal = append_signal;

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_silence_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_silence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in checkbox_cust_sig.
function checkbox_cust_sig_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_cust_sig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_cust_sig

 if get(hObject, 'value') == 1
     set(handles.uipanel_cust_sig, 'visible', 'on');
 else
     set(handles.uipanel_cust_sig, 'visible', 'off');
 end
 


% --- Executes on button press in getCurSig.
function getCurSig_Callback(hObject, eventdata, handles)
% hObject    handle to getCurSig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_stimedit

if hfig_stimedit.current_chan == 1
    hfig_stimedit.current_signal = hfig_stimedit.ch1.signal;
else
    hfig_stimedit.current_signal = hfig_stimedit.ch2.signal;
end

% --- Executes on button press in setCurSig.
function setCurSig_Callback(hObject, eventdata, handles)
% hObject    handle to setCurSig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_stimedit


if get(handles.silence, 'value') == 0
    if hfig_stimedit.current_chan ==1
        pt = pulse_train(hfig_stimedit.ch1);
        hfig_stimedit.append_signal = pt;
    else
        pt = pulse_train(hfig_stimedit.ch2);
        hfig_stimedit.append_signal = pt;
    end
end
    

if get(handles.append, 'value') == 0
    new_signal = [hfig_stimedit.append_signal hfig_stimedit.current_signal];
else        
    new_signal = [hfig_stimedit.current_signal hfig_stimedit.append_signal];
end

hfig_stimedit.new_signal = new_signal;
guidata(hObject, handles);  



function freq_edit_Callback(hObject, eventdata, handles)
% hObject    handle to freq_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freq_edit as text
%        str2double(get(hObject,'String')) returns contents of freq_edit as a double

global hfig_stimedit
global hfig_ballgui

if hfig_stimedit.current_chan ==1
    hfig_stimedit.ch1.freq = str2num(get(hObject,'String'));
    hfig_stimedit.stimulus_type = 1;
    set(handles.popupmenu_stimsrate, 'Enable', 'on');
    set(handles.popupmenu_stimsrate, 'String', hfig_stimedit.stimsrate);
else
    hfig_stimedit.ch2.freq = str2num(get(hObject,'String'));
    hfig_stimedit.stimulus_type = 1;
    set(handles.popupmenu_stimsrate, 'Enable', 'on');
    set(handles.popupmenu_stimsrate, 'String', hfig_stimedit.stimsrate);
end

handles.output.ici = get(hObject,'Value');
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function freq_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_load_wav_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_wav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hfig_stimedit
global hfig_ballgui

current_directory = cd;

[filename, pathname] = uigetfile('*.wav', 'Pick a WAV file');

fileinfo = importdata([pathname filename]);

hfig_stimedit.imported_wav.signal = fileinfo.data';
hfig_stimedit.imported_wav.stimsrate = fileinfo.fs;
hfig_stimedit.imported_wav.filename = filename;
hfig_stimedit.imported_wav.freq = 5000;
hfig_stimedit.imported_wav.delay = 0;


hfig_stimedit.stimulus_type = 2; %type 1 is stimprog generated stimuli, type 2 is imported wav

    set(handles.freq_edit,  'String', num2str(0));
    set(handles.pdur_edit,  'String', num2str(0));
    set(handles.ipi_edit,  'String', num2str(0));
    set(handles.ramp_edit,  'String', num2str(0));
    set(handles.pnum_edit,  'String', num2str(0));
    set(handles.rev_phase,  'Value', 0);
    set(handles.noise,  'Value', 0);
    set(handles.chrpnum_edit,  'String', num2str(0));
    set(handles.ici_edit, 'String', num2str(0));

handles.output.freq = hfig_stimedit.imported_wav.freq;
handles.output.pdur = 0;
handles.ouput.ipi = 0;
handles.output.ramp = 0;
handles.output.pnum = 0;
handles.output.rev_phase = 0;
handles.output.noise = 0;
handles.output.chrpnum = 0;
handles.output.ici = 0;

guidata(hObject, handles); 

done_button_Callback(hObject, eventdata, handles);

% --- Executes on selection change in popupmenu_stimsrate.
function popupmenu_stimsrate_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_stimsrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_stimsrate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_stimsrate

global hfig_stimedit
global hfig_ballgui

if hfig_stimedit.current_chan ==1
    selected_index = get(handles.popupmenu_stimsrate, 'value');
    hfig_stimedit.ch1.stimsrate = hfig_stimedit.stimsrate(selected_index);
    
else
    selected_index = get(handles.popupmenu_stimsrate, 'value');
    hfig_stimedit.ch2.stimsrate = hfig_stimedit.stimsrate(selected_index);
end

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
