function varargout = setupDiscretisation(varargin)
%SETUPDISCRETISATION MATLAB code file for setupDiscretisation.fig
%      SETUPDISCRETISATION, by itself, creates a new SETUPDISCRETISATION or raises the existing
%      singleton*.
%
%      H = SETUPDISCRETISATION returns the handle to a new SETUPDISCRETISATION or the handle to
%      the existing singleton*.
%
%      SETUPDISCRETISATION('Property','Value',...) creates a new SETUPDISCRETISATION using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to setupDiscretisation_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SETUPDISCRETISATION('CALLBACK') and SETUPDISCRETISATION('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SETUPDISCRETISATION.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setupDiscretisation

% Last Modified by GUIDE v2.5 04-Dec-2020 00:39:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setupDiscretisation_OpeningFcn, ...
                   'gui_OutputFcn',  @setupDiscretisation_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before setupDiscretisation is made visible.
function setupDiscretisation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for setupDiscretisation
handles.output = hObject;

%setup parameter
handles.params.T = 1;
handles.params.Lx = 2;
handles.params.Ly = 2;

set(handles.edit_T, 'String' ,num2str(handles.params.T));
set(handles.edit_Lx, 'String' ,num2str(handles.params.Lx));
set(handles.edit_Ly, 'String' ,num2str(handles.params.Ly));

handles.params.dt = 0.004;
handles.params.dx = 0.01;
handles.params.dy = 0.01;

set(handles.edit_dt, 'String' ,num2str(handles.params.dt));
set(handles.edit_dx, 'String' ,num2str(handles.params.dx));
set(handles.edit_dy, 'String' ,num2str(handles.params.dy));

handles.vis.nt = 1;
handles.vis.nx = 1;
handles.vis.ny = 1;
handles.vis.rx = 1;
handles.vis.ry = 1;

handles.vis = calcParams(handles);
set(handles.bc_t, 'Value', 1)
set(handles.bc_z, 'Value', 0)
handles.params.bc = 't';
    
updateDisplay(handles, handles.vis)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes setupDiscretisation wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = setupDiscretisation_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
params = handles.params;
params.nt = handles.vis.nt;
params.nx = handles.vis.nx;
params.ny = handles.vis.ny;
params.rx = handles.vis.rx;
params.ry = handles.vis.ry;

varargout{1} = params;
delete(handles.figure1)


function edit_T_Callback(hObject, eventdata, handles)
% hObject    handle to edit_T (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_T as text
%        str2double(get(hObject,'String')) returns contents of edit_T as a double
T = get(handles.edit_T, 'String');
handles.params.T = str2double(T);

handles.vis = calcParams(handles);
updateDisplay(handles, handles.vis)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_T_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_T (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Lx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Lx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Lx as text
%        str2double(get(hObject,'String')) returns contents of edit_Lx as a double
Lx = get(handles.edit_Lx, 'String');
handles.params.Lx = str2double(Lx);

handles.vis = calcParams(handles);
updateDisplay(handles, handles.vis)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_Lx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Lx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Ly_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Ly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Ly as text
%        str2double(get(hObject,'String')) returns contents of edit_Ly as a double
Ly = get(handles.edit_Ly, 'String');
handles.params.Ly = str2double(Ly);

handles.vis = calcParams(handles);
updateDisplay(handles, handles.vis)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_Ly_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Ly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_dt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dt as text
%        str2double(get(hObject,'String')) returns contents of edit_dt as a double
dt = get(handles.edit_dt, 'String');
handles.params.dt = str2double(dt);

handles.vis = calcParams(handles);
updateDisplay(handles, handles.vis)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_dt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_dx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dx as text
%        str2double(get(hObject,'String')) returns contents of edit_dx as a double
dx = get(handles.edit_dx, 'String');
handles.params.dx = str2double(dx);

handles.vis = calcParams(handles);
updateDisplay(handles, handles.vis)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_dx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_dy_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dy as text
%        str2double(get(hObject,'String')) returns contents of edit_dy as a double
dy = get(handles.edit_dy, 'String');
handles.params.dy = str2double(dy);

handles.vis = calcParams(handles);
updateDisplay(handles, handles.vis)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_dy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bc_t.
function bc_t_Callback(hObject, eventdata, handles)
% hObject    handle to bc_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.bc_t, 'Value');
if val == 1
    set(handles.bc_z, 'Value', 0)
    handles.params.bc = 't';
else
    set(handles.bc_z, 'Value', 1)
    handles.params.bc = '0';
end
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of bc_t


% --- Executes on button press in bc_z.
function bc_z_Callback(hObject, eventdata, handles)
% hObject    handle to bc_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.bc_z, 'Value');
if val == 1
    set(handles.bc_t, 'Value', 0)
    handles.params.bc = '0';
else
    set(handles.bc_t, 'Value', 1)
    handles.params.bc = 't';
end
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of bc_z

function vis = calcParams(handles)
vis = handles.vis;
vis.rx = handles.params.dt / handles.params.dx;
vis.ry = handles.params.dt / handles.params.dy;

vis.nt = handles.params.T / handles.params.dt;
vis.nx = handles.params.Lx / handles.params.dx;
vis.ny = handles.params.Ly / handles.params.dy;

function updateDisplay(handles, vis)

set(handles.text_nt, 'String', num2str(vis.nt));
set(handles.text_nx, 'String', num2str(vis.nx));
set(handles.text_ny, 'String', num2str(vis.ny));
set(handles.text_rx, 'String', num2str(vis.rx));
set(handles.text_ry, 'String', num2str(vis.ry));


% --- Executes on button press in confirm_button.
function confirm_button_Callback(hObject, eventdata, handles)
% hObject    handle to confirm_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.figure1)

function confirm_button_DeleteFcn(hObject, eventdata, handles)



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    uiresume(hObject)
else
    delete(hObject)
end
