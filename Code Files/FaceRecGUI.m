function varargout = FaceRecGUI(varargin)
% FACERECGUI MATLAB code for FaceRecGUI.fig
%      FACERECGUI, by itself, creates a new FACERECGUI or raises the existing
%      singleton*.
%
%      H = FACERECGUI returns the handle to a new FACERECGUI or the handle to
%      the existing singleton*.
%
%      FACERECGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACERECGUI.M with the given input arguments.
%
%      FACERECGUI('Property','Value',...) creates a new FACERECGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FaceRecGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FaceRecGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FaceRecGUI

% Last Modified by GUIDE v2.5 29-Nov-2021 10:18:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FaceRecGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @FaceRecGUI_OutputFcn, ...
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


% --- Executes just before FaceRecGUI is made visible.
function FaceRecGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FaceRecGUI (see VARARGIN)

% Choose default command line output for FaceRecGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FaceRecGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FaceRecGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in identify_button.
function identify_button_Callback(hObject, eventdata, handles)
% hObject    handle to identify_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I
load('createdb.mat')
[p,m] = uploadimage(I,myDatabase,minimax);
set(handles.text2, 'String', myDatabase{1,p});



% --- Executes on button press in upload_image.
function upload_image_Callback(hObject, eventdata, handles)
% hObject    handle to upload_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I
[Filename,Pathname]=uigetfile('*.jpg;*.jpeg;*.png','File Selector');
orig_im_name=strcat(Pathname,Filename);
I= imread(orig_im_name);
axes(handles.axes1);
imshow(I);
[h,w,c]=size(I);
if c>=3
    I = rgb2gray(I);
end
% Choose default command line output for GUI_Example
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in capture_image.
function capture_image_Callback(hObject, eventdata, handles)
% hObject    handle to capture_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I
I = capturecam();
axes(handles.axes1);
imshow(I);
I = rgb2gray(I);
% Choose default command line output for GUI_Example
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
