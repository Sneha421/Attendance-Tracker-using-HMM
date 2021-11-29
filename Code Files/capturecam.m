function I = capturecam(myDatabase,minmax)
vid = videoinput('winvideo', 1, 'MJPG_1280x720');
preview(vid);
I = [];
choice=menu('Save Image','Save');
if (choice == 1)
    I = getsnapshot(vid);
end
closepreview(vid);
file_name = sprintf(('Image_Capture.jpg'));
imwrite(I, [file_name,'.jpg']);