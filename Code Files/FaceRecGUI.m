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

% Last Modified by GUIDE v2.5 29-Nov-2021 14:39:12

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
global stud_id
global conn
global stud_name
load('createdb.mat')
[p,m] = uploadimage(I,myDatabase,minimax);
set(handles.text2, 'String', myDatabase{1,p});

vendor = "MySQL";
opts = databaseConnectionOptions("jdbc",vendor);

opts = setoptions(opts, ...
    'DataSourceName',"MySQL", ...
    'JDBCDriverLocation',"C:\Program Files (x86)\MySQL\Connector J 8.0\mysql-connector-java-8.0.27.jar", ...
    'DatabaseName',"face_rec",'Server',"localhost", ...
    'PortNumber',3306);
% 
username = "root";
password = ""; % enter SQL connection password
status = testConnection(opts,username,password);
saveAsDataSource(opts)

conn = database(vendor,username,password);

id_query = "SELECT stud_id from stud_info where stud_name = ?";
pstmt = databasePreparedStatement(conn, id_query);

selection = [1];

values = {string(myDatabase{1,p})};

pstmt = bindParamValues(pstmt,selection,values);

stud_res = fetch(conn,pstmt);

ins_query = "insert into att_info (stud_id, att_date, att_status) values (?, ?, ?)";

pstmt = databasePreparedStatement(conn, ins_query);

selection = [1, 2, 3];

curr_date = string(datestr(now, 'yyyy-mm-dd HH:MM:SS'))

values = {string(stud_res.stud_id), curr_date, '1'};

stud_id = string(stud_res.stud_id);

stud_name = string(myDatabase{1,p});

pstmt = bindParamValues(pstmt,selection,values);

execute(conn, pstmt);

set(handles.view_att,'visible','on');


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


% --- Executes on button press in view_att.
function view_att_Callback(hObject, eventdata, handles)
global stud_id
global conn
global stud_name
% hObject    handle to view_att (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fetch_query = ['select stud_info.stud_id, stud_info.stud_name, stud_info.stud_class, '...
               'att_info.att_date, att_info.att_status from stud_info '...
               'inner join att_info on stud_info.stud_id = att_info.stud_id '...
               'where stud_info.stud_id = '];

table_ = fetch(conn, strcat(fetch_query, num2str(stud_id)));

f = uifigure('Name',strcat('Attendance For', {' '}, stud_name), 'AutoResizeChildren', 'on', 'Resize', 'on');
uit = uitable(f, 'Data', table_, 'Position', [25 200 500 200]);
