function varargout = vizTool2D(varargin)
% VIZTOOL2D MATLAB code for vizTool2D.fig
%      VIZTOOL2D, by itself, creates a new VIZTOOL2D or raises the existing
%      singleton*.
%
%      H = VIZTOOL2D returns the handle to a new VIZTOOL2D or the handle to
%      the existing singleton*.
%
%      VIZTOOL2D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIZTOOL2D.M with the given input arguments.
%
%      VIZTOOL2D('Property','Value',...) creates a new VIZTOOL2D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vizTool2D_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vizTool2D_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vizTool2D

% Last Modified by GUIDE v2.5 29-Nov-2020 23:31:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vizTool2D_OpeningFcn, ...
                   'gui_OutputFcn',  @vizTool2D_OutputFcn, ...
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
end

% --- Executes just before vizTool2D is made visible.
function vizTool2D_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vizTool2D (see VARARGIN)

% Choose default command line output for vizTool2D
handles.output = hObject;

% hand solution struct
solution = varargin{1};
handles.data = solution.f;
handles.data_labels = solution.time;
handles.time_unit = solution.units.time;

if nargin == 5
    title_text = varargin{2};
else
    title_text = 'Visualization of PDE Solution';
end

% inti visualization window
if solution.dim == 1 
    error("1d solution not supported yet")
elseif solution.dim == 2
    surf(...
        handles.axes, ...
        solution.domain(:,:,1),...
        solution.domain(:,:,2),...
        solution.f(:,:,1))
    xlabel(['x [ ', solution.units.space, ' ]'])
    ylabel(['y [ ', solution.units.space, ' ]'])
    title(title_text)
    val = handles.data(:,:,1);
    caxis([0,max(val(:))])
end

handles.settings.fps = 60;
handles.settings.animation_time = 1;
handles.settings.az = 0;
handles.settings.el = 90;

view([handles.settings.az,handles.settings.el])
zlim([min(solution.f(:)),max(solution.f(:))])

set(handles.no_mesh_box, 'Value',0);
set(handles.axis_equal_box, 'Value',0);

% slider settings
set(handles.slider_time_index, 'Value',1)
set(handles.slider_time_index, 'Min'  ,1)
set(handles.slider_time_index, 'Max'  , size(solution.f,3))

% update displays
updateTimeDisplayed(handles)
updateSettingsDisplayed(handles)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vizTool2D wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = vizTool2D_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in play_button.
function play_button_Callback(hObject, eventdata, handles)
% hObject    handle to play_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

n_data = size(handles.data,3);
a_time = handles.settings.animation_time;
total_frames = a_time*handles.settings.fps;
if total_frames < n_data
    time_indices = floor((1:total_frames)/total_frames * n_data);
else
    time_indices = 1:n_data;
end

time_indices = unique(time_indices);
if time_indices ~= 1
    time_indices = [1,time_indices];
end
if time_indices ~= n_data
    time_indices = [time_indices, n_data];
end
time_per_frame = a_time / length(time_indices);

for idx_t = time_indices
    tic;
    updatePlot(handles, idx_t);
    
    set(handles.slider_time_index, 'Value', idx_t);
    updateTimeDisplayed(handles);
    t = toc;
    if time_per_frame - t > 0
        pause(time_per_frame - t );
    end
end

end

% --- Executes on button press in fps_minus_button.
function fps_minus_button_Callback(hObject, eventdata, handles)
% hObject    handle to fps_minus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.settings.fps =  handles.settings.fps - 5;

updateView(handles)
updateSettingsDisplayed(handles)

guidata(hObject, handles);
end

% --- Executes on button press in fps_plus_button.
function fps_plus_button_Callback(hObject, eventdata, handles)
% hObject    handle to fps_plus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.settings.fps =  handles.settings.fps + 5;

updateView(handles)
updateSettingsDisplayed(handles)

guidata(hObject, handles);
end

% --- Executes on button press in time_minus_button.
function time_minus_button_Callback(hObject, eventdata, handles)
% hObject    handle to time_minus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.settings.animation_time =  handles.settings.animation_time - 0.5;

updateView(handles)
updateSettingsDisplayed(handles)

guidata(hObject, handles);
end

% --- Executes on button press in time_plus_button.
function time_plus_button_Callback(hObject, eventdata, handles)
% hObject    handle to time_plus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.settings.animation_time =  handles.settings.animation_time + 0.5;

updateView(handles)
updateSettingsDisplayed(handles)

guidata(hObject, handles);
end

% --- Executes on button press in top_view_button.
function top_view_button_Callback(hObject, eventdata, handles)
% hObject    handle to top_view_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.settings.az = 0;
handles.settings.el = 90;

updateView(handles)
updateSettingsDisplayed(handles)

guidata(hObject, handles);

end

% --- Executes on button press in front_view.
function front_view_Callback(hObject, eventdata, handles)
% hObject    handle to front_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.settings.az = -45;
handles.settings.el = 45;

updateView(handles)
updateSettingsDisplayed(handles)

guidata(hObject, handles);
end

function edit_az_Callback(hObject, eventdata, handles)
% hObject    handle to edit_az (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_az as text
%        str2double(get(hObject,'String')) returns contents of edit_az as a double

val = str2double(get(handles.edit_az,'String'));
if abs(val) <= 90
    handles.settings.az = val;
else
    error('Not a valid azimuatal angle')
end
    
updateView(handles)
updateSettingsDisplayed(handles)

guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function edit_az_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_az (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function edit_el_Callback(hObject, eventdata, handles)
% hObject    handle to edit_el (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_el as text
%        str2double(get(hObject,'String')) returns contents of edit_el as a double

val = str2double(get(handles.edit_el,'String'));
if abs(val) <= 90
    handles.settings.el = val;
else
    error('Not a valid azimuatal angle')
end
    
updateView(handles)
updateSettingsDisplayed(handles)

guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_el_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_el (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in az_plus_button.
function az_plus_button_Callback(hObject, eventdata, handles)
% hObject    handle to az_plus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.settings.az = handles.settings.az + 5;

updateView(handles)
updateSettingsDisplayed(handles)

guidata(hObject, handles);
end

% --- Executes on button press in az_minus_button.
function az_minus_button_Callback(hObject, eventdata, handles)
% hObject    handle to az_minus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.settings.az = handles.settings.az - 5;

updateView(handles)
updateSettingsDisplayed(handles)

guidata(hObject, handles);
end

% --- Executes on button press in el_plus_button.
function el_plus_button_Callback(hObject, eventdata, handles)
% hObject    handle to el_plus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.settings.el = handles.settings.el + 5;
updateView(handles)
updateSettingsDisplayed(handles)
handles.el_plus_button

guidata(hObject, handles);

end

% --- Executes on button press in el_minus_button.
function el_minus_button_Callback(hObject, eventdata, handles)
% hObject    handle to el_minus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.settings.el = handles.settings.el - 5;
updateView(handles)
updateSettingsDisplayed(handles)

guidata(hObject, handles);

end

% --- Executes on slider movement.
function slider_time_index_Callback(hObject, eventdata, handles)
% hObject    handle to slider_time_index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx_t = floor(get(handles.slider_time_index,'Value'));

updatePlot(handles, idx_t)

updateTimeDisplayed(handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end

% --- Executes during object creation, after setting all properties.
function slider_time_index_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_time_index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end


function updateTimeDisplayed(handles)

idx_t = floor(get(handles.slider_time_index,'Value'));

% update time view
time_string = [num2str(handles.data_labels(idx_t)), ' ', handles.time_unit];
set(handles.view_simtime, 'String', time_string);

end

function updateSettingsDisplayed(handles)

fps_string = [num2str(handles.settings.fps), ' fps'];
time_string = [num2str(handles.settings.animation_time), ' s'];
az_string = num2str(handles.settings.az);
el_string = num2str(handles.settings.el);

set(handles.view_fps,'String',fps_string);
set(handles.view_time,'String',time_string);
set(handles.edit_el,'String',el_string);
set(handles.edit_az,'String',az_string);

end

function updateView(handles)
view(...
    handles.axes, ...
    handles.settings.az,...
    handles.settings.el);
end

function updatePlot(handles, idx_t)

set(handles.axes.Children(1), 'ZData', handles.data(:,:,idx_t));

%drawnow()

end


% --- Executes on button press in export_button.
function export_button_Callback(hObject, eventdata, handles)
% hObject    handle to export_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set up video 
prompt = {'Enter a filename for your video'};
dlgtitle = 'Enter filename';
dims = [1 35];
definput = {'PDE_Solution'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
file_name = [answer{1}];
movie = VideoWriter(file_name, 'MPEG-4');

%animation part
n_data = size(handles.data,3);
a_time = handles.settings.animation_time;
total_frames = a_time*handles.settings.fps;
if total_frames < n_data
    time_indices = floor((1:total_frames)/total_frames * n_data);
else
    time_indices = 1:n_data;
end

time_indices = unique(time_indices);
if time_indices ~= 1
    time_indices = [1,time_indices];
end
if time_indices ~= n_data
    time_indices = [time_indices, n_data];
end
time_per_frame = a_time / length(time_indices);

open(movie)

for idx_t = time_indices
    tic;
    updatePlot(handles, idx_t);
    
    set(handles.slider_time_index, 'Value', idx_t);
    updateTimeDisplayed(handles);
    t = toc;
    if time_per_frame - t > 0
        pause(time_per_frame - t );
    end
    
    frame = getframe(handles.axes);
    writeVideo(movie,frame)
end

close(movie)
   
end

% --- Executes on button press in no_mesh_box.
function no_mesh_box_Callback(hObject, eventdata, handles)
% hObject    handle to no_mesh_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of no_mesh_box

val = get(handles.no_mesh_box, 'Value');
if val == 1
    shading(handles.axes, 'flat')
else
    shading(handles.axes, 'faceted')
end

end

% --- Executes on button press in axis_equal_box.
function axis_equal_box_Callback(hObject, eventdata, handles)
% hObject    handle to axis_equal_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = get(handles.axis_equal_box, 'Value');
if val == 1
    axis(handles.axes, 'square')
    idx_t = floor(get(handles.slider_time_index,'Value'));
    updatePlot(handles, idx_t)
else
    axis(handles.axes, 'auto')
    idx_t = floor(get(handles.slider_time_index,'Value'));
    updatePlot(handles, idx_t)
end


end