function test(Stack)

%Loads DICOMS and shows the stack
% (C) Janne T.A. Mäkelä 2018

[Stack, info] = load_dicoms();

koko = size(Stack,3);

set(fig,'Name','Image','Toolbar','figure');%,...
%'NumberTitle','off')
% Create an axes to plot in
axes('Position',[.15 .05 .7 .9]);
% sliders for epsilon and lambda
slider1_handle=uicontrol(fig,'Style','slider','Max',koko,'Min',1,...
    'Value',2,'SliderStep',[1/(koko-1) 10/(koko-1)],...
    'Units','normalized','Position',[.02 .02 .14 .05]);
uicontrol(fig,'Style','text','Units','normalized','Position',[.02 .07 .14 .04],...
    'String','Choose frame');
% Set up callbacks
vars=struct('slider1_handle',slider1_handle,'Stack',Stack);
set(slider1_handle,'Callback',{@slider1_callback,vars});
plotterfcn(vars)
% End of main file
end

% Callback subfunctions to support UI actions
function slider1_callback(~,~,vars)
% Run slider1 which controls value of epsilon
plotterfcn(vars)
end

function plotterfcn(vars)
% Plots the image
%imshow(vars.Stack(:,:,round(get(vars.slider1_handle,'Value'))));
imagesc(vars.Stack(:,:,round(get(vars.slider1_handle,'Value'))));
axis equal;
title(num2str(get(vars.slider1_handle,'Value')));

end

function [Dicoms, info] = load_dicoms()

path = uigetdir; %Choose the folder where the DICOMS are

f = filesep; %Checks what's the file separator for current operating system (windows,unix,linux)

dicomnames = dir([num2str(path) f '*.dcm*']); %Read dicoms.
disp(['Folder: ', dicomnames(1).folder]); %display folder
%Dicom info
info = dicominfo([num2str(path) f dicomnames(1).name]);

h = waitbar(0,'Loading dicoms, please wait...'); %Display waitbar

%Import dicoms
% % % % % % % % % % % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Preallocating to save speed (With 2.08s, without, 2.56s on i5-6267U processor)
temp = dicomread([num2str(path) f dicomnames(1).name]);
Dicoms= int16(zeros(size(temp,1),size(temp,2), length(dicomnames)));

Dicoms = Dicoms.*info.RescaleSlope+info.RescaleIntercept; %Converting the pixel values

for i = 1:length(dicomnames)
    Dicoms(:,:,i)= dicomread([num2str(path) f dicomnames(i).name]);
    waitbar(i/length(dicomnames));
end
close(h);

end