function edit_image(imageData)

%
% part of Bruker - Graphical user interface to image Bruker data 
%
% Usage - 
%
% Written by Matteo Caffini, PhD
% Dipartimento di Elettronica, Informatica e Bioingegneria
% Politecnico di Milano, Milano, ITALY
%
% Copyright (C) 2014 Matteo Caffini <matteo.caffini@polimi.it>
%

% Handles to graphics and data
Hedit_image = []; % handles to uicontrols and graphics
allData = []; % handles to data

allData.imageData = imageData;

screenSize=get(0,'ScreenSize');

figureW = 1000;   % Screen width in pixels
figureH = 600;   % Screen height in pixels
stepHrz = 20;    % Horizontal step in pixels
stepVrt = 20;    % Vertical step in pixels

imagePanelW = 560;
imagePanelH = 560;

% Set color background
defaultColor = get(0,'DefaultUicontrolBackgroundcolor');

% Set font
if ismac
    defaultFontName = 'Lucida Grande';
    if sum(strcmp(listfonts,defaultFontName))<1
        defaultFontName = 'Helvetica';
    end 
elseif ispc
    defaultFontName = 'Lucida Sans Unicode';
    if sum(strcmp(listfonts,defaultFontName))<1
        defaultFontName = 'Helvetica';
    end
else
    defaultFontName = 'Helvetica';
end

% Set figure position
figurePosition = [screenSize(3)/2-figureW/2+figureW/4 screenSize(4)/2-figureH/2+figureH/8 figureW figureH];

% Draw main figure
Hedit_image.mainFigure = figure('Position',figurePosition, ...
    'Visible','off',...
    'Units','pixel', ...
    'Resize','off',...
    'Name','Edit Image', ...
    'Numbertitle','off', ...
    'Tag','main_figure', ...
    'Color',defaultColor, ...
    'Toolbar','none', ...
    'Menubar','none', ...
    'DoubleBuffer','on', ...
    'DockControls','off',...
    'Renderer','OpenGL');

% Draw menu bar
Hedit_image.fileMenu.main = uimenu('Label','File','Accelerator','F', ...
    'Parent',Hedit_image.mainFigure);
Hedit_image.fileMenu.quit_app = uimenu(Hedit_image.fileMenu.main,'Label','Quit',...
    'Separator','on','Callback',@quit_app);

% Draw image panel
Hedit_image.imagePanel = uipanel('parent',Hedit_image.mainFigure,...
    'FontWeight','bold',...
    'FontSize',10,...
    'FontName',defaultFontName,...
    'BackgroundColor',defaultColor,...
    'Units','pixel',...
    'Position',[figureW-imagePanelW-20 stepVrt imagePanelW imagePanelH]);
Hedit_image.mainAxes = axes('parent',Hedit_image.imagePanel,...
    'Units','Pixel',...
    'Position', [10 10 538 538],...
    'Xlim',[0 1],'Ylim',[0 1], ...
    'XDir','normal','YDir','normal',...
    'Box','off', ...
    'XGrid','off','YGrid','off',...
    'Fontsize',12,...
    'FontName',defaultFontName,...
    'Drawmode','normal',...
    'Visible','on');


    function quit_app(h,evt)
        delete(Hedit_image.mainFigure)
    end

    function update_image()
        axes_handle = Hedit_image.mainAxes;
        imageData = allData.imageData;
        currentSlice = 1;
        
        imageName = 'Data1';
        currentSliceString = ['Slice ' num2str(currentSlice) ' of ' num2str(size(imageData,3))];
        
        axes(axes_handle);
        currentImage = squeeze(imageData(:,:,currentSlice));
        imagesc(currentImage); % WARNING: I have to check if scaling of intensity is correct
        grid off, axis equal
        %axis off
        hold on
        text(5,10,imageName,'Color',[1 1 1],'FontSize',14,'FontWeight','bold')
        text(5,20,currentSliceString,'Color',[1 1 1],'FontSize',14,'FontWeight','bold')
    end

update_image;
set(Hedit_image.mainFigure,'Visible','on')
end