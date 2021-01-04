function varargout = vizTool(varargin)
%VIZTOOL MATLAB code file for vizTool.fig
%      VIZTOOL, by itself, creates a new VIZTOOL or raises the existing
%      singleton*.
%
%      H = VIZTOOL returns the handle to a new VIZTOOL or the handle to
%      the existing singleton*.
%
%      VIZTOOL('Property','Value',...) creates a new VIZTOOL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to vizTool_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      VIZTOOL('CALLBACK') and VIZTOOL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in VIZTOOL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vizTool

% Last Modified by GUIDE v2.5 04-Jan-2021 20:51:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vizTool_OpeningFcn, ...
                   'gui_OutputFcn',  @vizTool_OutputFcn, ...
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


% --- Executes just before vizTool is made visible.
function vizTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for vizTool
handles.output = hObject;

% hand data
handles.data.ax1 = varargin{1};
handles.data.ax2 = varargin{2};
handles.data.ax3 = varargin{3};
handles.data.n = calcSlideNumber(handles);

% init plots
if ~isempty(handles.data.ax1)
    handles.data.ax1.plot(handles.axes1,1);
end
if ~isempty(handles.data.ax2)
    handles.data.ax2.plot(handles.axes2,1);
end
if ~isempty(handles.data.ax3)
    handles.data.ax3.plot(handles.axes3,1);
end

% init slider
slider_label = handles.data.ax1.slider_label;
set(handles.text_slider_label, 'String', slider_label);

set(handles.slider, 'Value',1)
set(handles.slider, 'Min'  ,1)
set(handles.slider, 'Max'  , length(handles.data.ax1.slider_data))

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vizTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = vizTool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider_Callback(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

idx_slider = floor(get(handles.slider,'Value'));
updatePlot(handles, idx_slider)
updateSliderLabel(handles);


% --- Executes during object creation, after setting all properties.
function slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in exportbutton.
function exportbutton_Callback(hObject, eventdata, handles)
% hObject    handle to exportbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% set up video file 
prompt = {'Enter a filename for your video', 'Enter total numerb of frames'};
dlgtitle = 'Enter file properties';
dims = [1 35];
definput = {'Fds_Solution', '200'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
file_name = [answer{1}];
movie = VideoWriter(file_name, 'MPEG-4');

% choose frame 



prompt_string = {'Choose a frame for the video'};
list_string = {'Figure', 'Axes1', 'Axes2', 'Axes3'};
indx = listdlg('PromptString',prompt_string,...
               'SelectionMode','single', ...
               'ListString',list_string);
           
switch indx
    case 1
        frame_obj = handles.figure1;
    case 2
        frame_obj = handles.axes1;
    case 3
        frame_obj = handles.axes2;
    case 4
        frame_obj = handles.axes3;
end
        

% animation part
n_data = handles.data.n;
n_slides = str2double(answer{2});

if n_slides < n_data % only take needed data
    slide_idx = [1,floor((1:n_slides)/n_slides * n_data), n_data];
else %get all data we have
    slide_idx = 1:n_data;
end
slide_idx = unique(slide_idx); % no double slides

open(movie)
for idx_s = slide_idx
    
    updatePlot(handles, idx_s)   
    
    frame = getframe(frame_obj);
    writeVideo(movie,frame)
end
close(movie)

% --- Executes on button press in playbutton.
function playbutton_Callback(hObject, eventdata, handles)
% hObject    handle to playbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

n_data = handles.data.n;
n_slides = 200;
time = 2; %seconds

% get slide indices
if n_slides < n_data % only take needed data
    slide_idx = [1,floor((1:n_slides)/n_slides * n_data), n_data];
else %get all data we have
    slide_idx = 1:n_data;
end
slide_idx = unique(slide_idx); % no double slides

% get time for each slide
time_per_slide = time / length(slide_idx);

for idx_s = slide_idx
    tic
    updatePlot(handles, idx_s)
    updateSlider(handles, idx_s)
    
    t = toc;
    if time_per_slide - t > 0
        pause(time_per_slide - t);
    end
    
end


function updatePlot(handles, idx_slider)
    
% axes 1
if ~isempty(handles.data.ax1)
    handles.data.ax1.updatePlot(handles.axes1, idx_slider);
end
% axes 2
if ~isempty(handles.data.ax2)
    handles.data.ax2.updatePlot(handles.axes2, idx_slider);
end
% axes 3
if ~isempty(handles.data.ax3)
    handles.data.ax3.updatePlot(handles.axes3, idx_slider);
end

function updateSlider(handles, idx_s)
set(handles.slider,'Value', idx_s);
updateSliderLabel(handles)


function updateSliderLabel(handles)

idx_slider = floor(get(handles.slider,'Value'));

% update time view
slider_value_string = num2str(handles.data.ax1.slider_data(idx_slider));
slider_index_string = num2str(idx_slider);

set(handles.text_slider_value, 'String', slider_value_string);
set(handles.text_slider_index, 'String', slider_index_string);

function n_slides_1 = calcSlideNumber(handles)

n_slides_1 = length(handles.data.ax1.slider_data);
n_slides_2 = length(handles.data.ax2.slider_data);
n_slides_3 = length(handles.data.ax3.slider_data);

if n_slides_1 ~= n_slides_2
    error('Number of slides of dataset 1 and 3 do not coincide')
end

if n_slides_1 ~= n_slides_3
    error('Number of slides of dataset 1 and 3 do not coincide')
end









