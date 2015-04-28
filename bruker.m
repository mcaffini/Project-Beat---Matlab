function bruker

%
% Bruker - Graphical user interface to image Bruker data 
%
% Usage - call bruker from Matlab console
%
% Written by Matteo Caffini, PhD
% Dipartimento di Elettronica, Informatica e Bioingegneria
% Politecnico di Milano, Milano, ITALY
%
% Copyright (C) 2014 Matteo Caffini <matteo.caffini@polimi.it>
%

% Handles to graphics and data
Hmain = []; % handles to uicontrols and graphics
allData = []; % handles to data

screenSize=get(0,'ScreenSize');

figureW = 1130;   % Screen width in pixels
figureH = 550;   % Screen height in pixels
stepHrz = 20;    % Horizontal step in pixels
stepVrt = 20;    % Vertical step in pixels

dataListPanelW = 200;     % dataListPanel width in pixels
dataListPanelH = 450;     % dataListPanel height in pixels
browseButtonW = 200;  % browseButton width in pixels
browseButtonH = 40;   % browseButton height in pixels
folderTextW = 650;    % folderText width in pixels
folderTextH = 20;     % folderText height in pixels
dataListW = 160;
dataListH = 400;
parametersPanelW = 400;
parametersPanelH = 450;
previewPanelW = 450;
previewPanelH = 450;
singleParameterW = 80;
singleParameterH = 20;

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
figurePosition = [screenSize(3)/2-figureW/2 screenSize(4)/2-figureH/2-20 figureW figureH];

% Draw main figure
Hmain.mainFigure = figure('Position',figurePosition, ...
    'Visible','off',...
    'Units','pixel', ...
    'Resize','off',...
    'Name','Open Bruker', ...
    'Numbertitle','off', ...
    'Tag','main_figure', ...
    'Color',defaultColor, ...
    'Toolbar','none', ...
    'Menubar','none', ...
    'DoubleBuffer','on', ...
    'DockControls','off',...
    'Renderer','OpenGL');

% Draw menu bar
% File menu
Hmain.fileMenu.main = uimenu('Label','File','Accelerator','F', ...
    'Parent',Hmain.mainFigure);
Hmain.fileMenu.load_folder = uimenu(Hmain.fileMenu.main,'Label','Load Folder...',...
    'Callback',@load_folder);
Hmain.fileMenu.send_to_workspace = uimenu(Hmain.fileMenu.main,'Label','Send Data to Workspace',...
    'Callback',@send_to_workspace);
Hmain.fileMenu.save_file = uimenu(Hmain.fileMenu.main,'Label','Save File',...
    'Enable','off',...
    'Callback',@save_file);
Hmain.fileMenu.save_mat = uimenu(Hmain.fileMenu.save_file,'Label','Save .mat',...
    'Enable','off',...
    'Callback',@save_mat);
Hmain.fileMenu.save_analyze = uimenu(Hmain.fileMenu.save_file,'Label','Save Analyze',...
    'Enable','off',...
    'Callback',@save_analyze);
Hmain.fileMenu.save_dicom_series = uimenu(Hmain.fileMenu.save_file,'Label','Save DICOM',...
    'Enable','off',...
    'Callback',@save_dicom_series);
Hmain.fileMenu.quit_app = uimenu(Hmain.fileMenu.main,'Label','Quit',...
    'Separator','on','Callback',@quit_app);
% List menu
Hmain.listMenu.main = uimenu('Label','List','Accelerator','L', ...
    'Parent',Hmain.mainFigure);
Hmain.listMenu.filter = uimenu(Hmain.listMenu.main,'Label','Filter List...',...
    'Enable','off','Callback',@filter_dataList);
% Help menu
Hmain.helpMenu.main = uimenu('Label','Help','Accelerator','H', ...
    'Parent',Hmain.mainFigure);
Hmain.helpMenu.credits = uimenu(Hmain.helpMenu.main,'Label','Credits...',...
    'Callback',@open_credits);


% Draw toolbar
%Hg.toolbar = uitoolbar('parent',H.mainFigure);

% Draw list panel
Hmain.dataListPanel = uipanel('parent',Hmain.mainFigure,...
    'Title','Data List',...
    'FontWeight','bold',...
    'FontSize',10,...
    'FontName',defaultFontName,...
    'BackgroundColor',defaultColor,...
    'Units','pixel',...
    'Position',[stepHrz stepVrt dataListPanelW dataListPanelH]);
Hmain.dataList = uicontrol('parent',Hmain.mainFigure,...
    'Units','pixel',...
    'Position',[2*stepHrz 5*stepVrt+18 dataListW dataListH-3*stepVrt-18],...
    'Style','list',...
    'HorizontalAlign','left',...
    'FontWeight','normal',...
    'FontSize',12,...
    'FontName',defaultFontName,...
    'BackgroundColor','white',...
    'String','...no dataset loaded...',...
    'Min',1,'Max',3,... % Set Max - Min > 1 to enable multiple selection
    'Callback',@load_image_and_data);

% List options
Hmain.optionsPanel = uipanel('parent',Hmain.mainFigure,...
    'Title','',...
    'FontWeight','bold',...
    'FontSize',10,...
    'FontName',defaultFontName,...
    'BackgroundColor',defaultColor,...
    'Units','pixel',...
    'Position',[2*stepHrz 2*stepVrt dataListW 60]);
Hmain.checkboxScanRecursively = uicontrol('parent',Hmain.optionsPanel,...
    'Units','pixel',...
    'Position',[10 9 dataListPanelW-20 20],...
    'Style','checkbox',...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FontSize',12,...
    'FontName',defaultFontName,...
    'BackgroundColor',defaultColor,...
    'String','Scan recursively',...
    'Callback',@scan_recursively,...
    'Enable','off');
Hmain.checkboxOnlyBruker = uicontrol('parent',Hmain.optionsPanel,...
    'Units','pixel',...
    'Position',[10 30 dataListPanelW-20 20],...
    'Style','checkbox',...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FontSize',12,...
    'FontName',defaultFontName,...
    'BackgroundColor',defaultColor,...
    'String','Only Valid',...
    'Callback',@only_bruker,...
    'Enable','off');

% Draw filter button
Hmain.filterButton = uicontrol('parent',Hmain.mainFigure,...
    'Units','pixel',...
    'Position',[stepHrz 2*stepVrt+dataListPanelH browseButtonW browseButtonH],...
    'Style','pushbutton',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName',defaultFontName,...
    'String','Filter List...',...
    'Value',0,...
    'Callback',@filter_dataList,...
    'Enable','off');

% Draw browse button
Hmain.browseButton = uicontrol('parent',Hmain.mainFigure,...
    'Units','pixel',...
    'Position',[3*stepHrz+browseButtonW+folderTextW 2*stepVrt+dataListPanelH browseButtonW browseButtonH],...
    'Style','pushbutton',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName',defaultFontName,...
    'String','Browse...',...
    'Value',0,...
    'Callback',@load_folder,...
    'Enable','on');

% Draw current folder panel
Hmain.folderPanel = uipanel('parent',Hmain.mainFigure,...
    'BackgroundColor',defaultColor,...
    'Units','pixel',...
    'Position',[2*stepHrz+dataListPanelW 2*stepVrt+dataListPanelH+5 folderTextW browseButtonH-10]);
Hmain.folderText = uicontrol('parent',Hmain.mainFigure,...
    'Units','pixel',...
    'Position',[2*stepHrz+dataListPanelW+5 2*stepVrt+dataListPanelH+browseButtonH/4-1 folderTextW-10 folderTextH],...
    'Style','text',...
    'HorizontalAlignment','left',...
    'FontWeight','normal',...
    'FontSize',14,...
    'FontName',defaultFontName,...
    'BackgroundColor',defaultColor,...
    'String','...no dataset loaded...');

% Draw parameters panel
parametersList = {'Protocol';...
    'Sequence';...
    'FOV (mm)';...
    'FOV (pixel)';...
    'Frames';...
    'Flip Angle';...
    'Averages';...
    'TR';...
    'TE';...
    'Slice Thickness';...
    'Date & Time';...
    'Scan Time'};
parametersLabels = {'VisuAcquisitionProtocol';...
    'VisuAcqSequenceName';...
    'VisuCoreExtent';...
    'VisuCoreSize';...
    'VisuCoreFrameCount';...
    'VisuAcqFlipAngle';...
    'VisuAcqNumberOfAverages';...
    'VisuAcqRepetitionTime';...
    'VisuAcqEchoTime';...
    'VisuCoreFrameThickness';...
    'VisuAcqDate';...
    'VisuAcqScanTime'};
parametersList = flipdim(parametersList,1);
parametersLabels = flipdim(parametersLabels,1);
nParameters = length(parametersList);
Hmain.parametersPanel = uipanel('parent',Hmain.mainFigure,...
    'Title','Parameters',...
    'FontWeight','bold',...
    'FontSize',10,...
    'FontName',defaultFontName,...
    'BackgroundColor',defaultColor,...
    'Units','pixel',...
    'Position',[2*stepHrz+dataListPanelW stepVrt parametersPanelW parametersPanelH]);
for i = 1:1:nParameters
    parameterName = parametersList{i};
    parameterLabelLeft = ['param' 'Name' num2str(i)];
    parameterLabelRight = ['param' 'Value' num2str(i)]; 
    Hmain.(parameterLabelLeft) = uicontrol('parent',Hmain.parametersPanel,...
        'Units','pixel',...
        'Position',[15 i*32 singleParameterW singleParameterH],...
        'Style','text',...
        'HorizontalAlignment','center',...
        'FontWeight','normal',...
        'FontSize',10,...
        'FontName',defaultFontName,...
        'BackgroundColor',defaultColor,...
        'String',parameterName);
    Hmain.(parameterLabelRight) = uicontrol('parent',Hmain.parametersPanel,...
        'Units','pixel',...
        'Position',[195 i*32 singleParameterW+100 singleParameterH],...
        'Style','text',...
        'HorizontalAlignment','center',...
        'FontWeight','normal',...
        'FontSize',10,...
        'FontName',defaultFontName,...
        'BackgroundColor',defaultColor,...
        'String','-');
end

% Draw preview panel
Hmain.previewPanel = uipanel('parent',Hmain.mainFigure,...
    'Title','Preview',...
    'FontWeight','bold',...
    'FontSize',10,...
    'FontName',defaultFontName,...
    'BackgroundColor',defaultColor,...
    'Units','pixel',...
    'Position',[3*stepHrz+dataListPanelW+parametersPanelW stepVrt previewPanelW previewPanelH]);
Hmain.mainAxes = axes('parent',Hmain.previewPanel,...
    'Units','Pixel',...
    'Position', [50 40 previewPanelW-100 previewPanelH-100],...
    'Xlim',[0 1],'Ylim',[0 1], ...
    'XDir','normal','YDir','normal',...
    'Box','off', ...
    'XGrid','off','YGrid','off',...
    'Fontsize',12,...
    'FontName',defaultFontName,...
    'Drawmode','normal',...
    'Visible','on');
Hmain.mainSlider = uicontrol('parent',Hmain.previewPanel,...
    'Units','pixel',...
    'Position',[50 385 350 30],...
    'Style','slider',...
    'Callback',@move_main_slider,...
    'Backgroundcolor',defaultColor,...
    'Visible','on');
Hmain.sliceCounter = uicontrol('parent',Hmain.previewPanel,...
    'Units','pixel',...
    'Position',[200 6 50 30],...
    'Style','text',...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName',defaultFontName,...
    'BackgroundColor',defaultColor,...
    'String','-/-',...
    'Visible','on');

clear_data;

%% Nested functions

    function load_image_and_data(h,evt)
        if isfield(allData,'pathDataset')
            pathDataset = allData.pathDataset;
            idx_file = get(Hmain.dataList,'Value');
            contents = cellstr(get(Hmain.dataList,'String'));
            
            nContents = length(contents);
            for cc = 1:1:nContents;
                spam = regexp(contents{cc},'<');
                if ~isempty(spam)
                    eggs = regexp(contents{cc},'>');
                    contents{cc} = contents{cc}(eggs(2)+1:spam(3)-1);
                end
            end
        
            nSelection = length(idx_file); % current selection length
            
            if nSelection == 1
                pathData = strcat(pathDataset,filesep,contents(idx_file));
                pathData = pathData{1};
                
                methodFile = strcat(pathData,filesep,'method');
                acqpFile = strcat(pathData,filesep,'acqp');
                fidFile = strcat(pathData,filesep,'fid');
                
                visu_parsFile = strcat(pathData,filesep,'pdata',filesep,'1',filesep,'visu_pars');
                recoFile = strcat(pathData,filesep,'pdata',filesep,'1',filesep,'reco');
                a2dseqFile = strcat(pathData,filesep,'pdata',filesep,'1',filesep,'2dseq');
                
                if exist(methodFile,'file') == 2
                    method = read_parameters(methodFile);
                else
                    method = NaN;
                end
                if exist(acqpFile,'file') == 2
                    acqp = read_parameters(acqpFile);
                else
                    acqp = NaN;
                end
                if exist(visu_parsFile,'file') == 2
                    visu_pars = read_parameters(visu_parsFile);
                else
                    clear_data;
                    return
                end
                if exist(recoFile,'file') == 2
                    reco = read_parameters(recoFile);
                else
                    reco = NaN;
                end
                
                imageData = read_image(a2dseqFile,fidFile,method,acqp,visu_pars,reco);
                currentSlice = 1;
                
                allData.currentSlice = currentSlice;
                allData.imageData = imageData;
                allData.method = method;
                allData.acqp = acqp;
                allData.visu_pars = visu_pars;
                allData.reco = reco;
                allData.nSelection = nSelection;
            elseif nSelection > 1
                imageData = imread('multiple_selection_image.jpg');
                allData.imageData = imageData;
                allData.nSelection = nSelection;
            else
                clear_data;
                return
            end
            update_data;
        else
            msgbox('Load folder first' ,'Warning','modal')
        end
    end

    function load_folder(h,evt)
        pathDataset = uigetdir;
        
        if pathDataset ~= 0
            allData.pathDataset = pathDataset;
            set(Hmain.checkboxScanRecursively,'Value',0);
            set(Hmain.checkboxScanRecursively,'Enable','on')
            set(Hmain.filterButton,'Enable','on')
            set(Hmain.listMenu.filter,'Enable','on')
            fill_data_list(pathDataset);
        else
            return
        end
    end

    function fill_data_list(pathDataset)
        scanRecursively = get(Hmain.checkboxScanRecursively,'Value');
        
        % Get folder "number names"
        if scanRecursively
            if pathDataset ~= 0
                visu_parsFilesListFullPath = dirrec(pathDataset,'visu_pars*');
                partialPathFirst = length(pathDataset)+2;
                
                for ii=1:1:length(visu_parsFilesListFullPath)
                    spam = regexp(visu_parsFilesListFullPath,filesep);
                    eggs = spam{ii};
                    partialPathLast = eggs(end-2)-1;
                    dirNames{:,ii} = visu_parsFilesListFullPath{:,ii}(1,partialPathFirst:partialPathLast);
                end
                
            else
                return
            end
        else
            if pathDataset ~= 0
                listNames = dir(fullfile(pathDataset, ''));
                dirNames = [];
                fileNames = [];
                for aa = 1:1:length(listNames)
                    if listNames(aa,1).isdir==1
                        dirNames{end+1} = listNames(aa,1).name;
                    else
                        fileNames{end+1} = listNames(aa,1).name;
                    end
                end
                
                % cut '..'
                bb = strcmp(dirNames,'..');
                idx = find(bb==1);
                dirNames(idx) = [];
                
                % cut '.'
                bb = strcmp(dirNames,'.');
                idx = find(bb==1);
                dirNames(idx) = [];
                
                % cut 'AdjResult'
                bb = strcmp(dirNames,'AdjResult');
                idx = find(bb==1);
                dirNames(idx) = [];
  
            else
                return
            end
        end
        
        % Sort folder names by number
        sort_and_populate_list(dirNames);
        
        % Populate current folder and data list
        set(Hmain.folderText,'string',pathDataset)
        
        % Display automatically the first image in the list
        set(Hmain.dataList,'Value',1)
        load_image_and_data;
    end

    function sort_and_populate_list(dirNames)
        spam = regexp(dirNames,filesep);
        for ii = 1:1:length(dirNames)
            nSeparators = size(spam{ii},2);
            switch nSeparators
                case 0
                    idx_lastSeparator = 0;
                    lastFolder{ii} = dirNames{ii}(idx_lastSeparator+1:end);
                    finalString{ii} = lastFolder{ii};
                case 1
                    idx_lastSeparator = spam{ii}(1,nSeparators);
                    lastFolder{ii} = dirNames{ii}(idx_lastSeparator+1:end);
                    beforeLastFolder{ii} = dirNames{ii}(1:idx_lastSeparator-1);
                case 2
                    idx_lastSeparator = spam{ii}(1,nSeparators);
                    idx_beforeLastSeparator = spam{ii}(1,nSeparators-1);
                    lastFolder{ii} = dirNames{ii}(idx_lastSeparator+1:end);
                    beforeLastFolder{ii} = dirNames{ii}(idx_beforeLastSeparator+1:idx_lastSeparator-1);     
            end       
        end
        
        % Create group with multiple color before populating list
        if nSeparators > 0
            [folderGroups,idx_groupOfFolder,idx_folderGroups] = unique(beforeLastFolder);
            nGroups = size(folderGroups,2);
            finalString = [];
            
            for aa = 1:1:nGroups
                % Sort folder in group by number
                foldersInGroup = idx_folderGroups==aa;
                nFolders = sum(foldersInGroup);
                
                Str = sprintf('%s,', lastFolder{foldersInGroup});
                D = sscanf(Str, '%g,');
                [dummy, index] = sort(D);
                index = index + (nFolders*(aa-1));
                
                if aa == 1
                    dirNamesSorted = dirNames(index);
                else
                    dirNamesSorted = [dirNamesSorted dirNames(index)];
                end
                
                % Choose color
                if mod(aa,2)
                    groupColor = 'black';
                else
                    groupColor = 'red';
                end
                
                % Prepare group string
                groupString = [];
                for bb = 1:1:nFolders
                    idx_dirName = bb+(nFolders*(aa-1));
                    if bb == 1
                        groupString{1} = strcat('<html><font color="',groupColor,'">',dirNamesSorted{idx_dirName},'</font></html>');
                    else
                        entryString = strcat('<html><font color="',groupColor,'">',dirNamesSorted{idx_dirName},'</font></html>');
                        groupString{end+1} = entryString;
                    end 
                end
                
                % Concatenate group strings
                if nGroups == 1
                    finalString = groupString;
                else
                    finalString = [finalString groupString];
                end
            end
        else
            finalString = sort_dirNames(finalString);
        end
        
        % Populate data list and select first entry
        allData.finalString = finalString;
        set(Hmain.dataList,'Value',1)
        set(Hmain.dataList,'String',finalString)
    end

    function dirNamesSorted = sort_dirNames(dirNames)
        lengthFolderName = cellfun(@length, dirNames);
        idx_foldersNotNumbers = find(lengthFolderName>3);
        
        dirNamesOnlyFoldersNumber = dirNames;
        dirNamesOnlyFoldersNumber(idx_foldersNotNumbers) = [];
        
        Str = sprintf('%s,', dirNamesOnlyFoldersNumber{:});
        D = sscanf(Str, '%g,');
        
        [dummy, index] = sort(D);
        dirNamesSorted = [dirNamesOnlyFoldersNumber(index) dirNames(idx_foldersNotNumbers)];
    end

    function save_file(h,evt)
        
    end

    function save_mat(h,evt)
        nSelection = allData.nSelection;
        pathDataset = allData.pathDataset;
        dataFolderPositions = get(Hmain.dataList,'Value');
        dataFolderNames = get(Hmain.dataList,'string');
        
        nDataFolderNames = length(dataFolderNames);
        for cc = 1:1:nDataFolderNames;
            spam = regexp(dataFolderNames{cc},'<');
            if ~isempty(spam)
                eggs = regexp(dataFolderNames{cc},'>');
                dataFolderNames{cc} = dataFolderNames{cc}(eggs(2)+1:spam(3)-1);
            end
        end
        
        pathmat = uigetdir;
        if pathmat ~= 0
            currentDir = cd;
            for ii=1:1:nSelection
                dataFolderPosition = dataFolderPositions(ii);
                dataFolderName = dataFolderNames(dataFolderPosition);
                dataFolderName = dataFolderName{1};
                
                % Substitute forbidden characters with underscore
                dataName = dataFolderName;
                spam = regexp(dataName,'\');
                if ~isempty(spam)
                    dataName(spam) = '_';
                end
                spam = regexp(dataName,'/');
                if ~isempty(spam)
                    dataName(spam) = '_';
                end
                spam = regexp(dataName,' ');
                if ~isempty(spam)
                    dataName(spam) = '_';
                end
                spam = regexp(dataName,'\.');
                if ~isempty(spam)
                    dataName(spam) = '_';
                end
                eggs = regexp(dataName,filesep);
                if ~isempty(eggs)
                    dataName(eggs) = '_';
                end
                
                pathData = [pathDataset filesep dataFolderName];
                
                methodFile = strcat(pathData,filesep,'method');
                acqpFile = strcat(pathData,filesep,'acqp');
                fidFile = strcat(pathData,filesep,'fid');
                
                visu_parsFile = strcat(pathData,filesep,'pdata',filesep,'1',filesep,'visu_pars');
                recoFile = strcat(pathData,filesep,'pdata',filesep,'1',filesep,'reco');
                a2dseqFile = strcat(pathData,filesep,'pdata',filesep,'1',filesep,'2dseq');
                
                if exist(methodFile,'file') == 2
                    method = read_parameters(methodFile);
                else
                    method = NaN;
                end
                if exist(acqpFile,'file') == 2
                    acqp = read_parameters(acqpFile);
                else
                    acqp = NaN;
                end
                if exist(visu_parsFile,'file') == 2
                    visu_pars = read_parameters(visu_parsFile);
                else
                    clear_data;
                    return
                end
                if exist(recoFile,'file') == 2
                    reco = read_parameters(recoFile);
                else
                    reco = NaN;
                end
                
                % Get data filename
                idx = max(strfind(allData.pathDataset,filesep));
                dataSetFolderName = allData.pathDataset(idx+1:end);
                fileName = [dataName '.mat'];
                
                % Read image file
                imageData = read_image(a2dseqFile,fidFile,method,acqp,visu_pars,reco);
                
                % Save .mat file
                cd(pathmat)
                save(fileName,'imageData');
                cd(currentDir);
            end
        else
            return
        end
    end

    function save_analyze(h,evt)
        nSelection = allData.nSelection;
        pathDataset = allData.pathDataset;
        dataFolderPositions = get(Hmain.dataList,'Value');
        dataFolderNames = get(Hmain.dataList,'string');
        
        nDataFolderNames = length(dataFolderNames);
        for cc = 1:1:nDataFolderNames;
            spam = regexp(dataFolderNames{cc},'<');
            if ~isempty(spam)
                eggs = regexp(dataFolderNames{cc},'>');
                dataFolderNames{cc} = dataFolderNames{cc}(eggs(2)+1:spam(3)-1);
            end
        end
        
        pathAnalyze = uigetdir;
        if pathAnalyze ~= 0
            for ii=1:1:nSelection
                dataFolderPosition = dataFolderPositions(ii);
                dataFolderName = dataFolderNames(dataFolderPosition);
                dataFolderName = dataFolderName{1};
                
                % Substitute forbidden characters with underscore
                dataName = dataFolderName;
                spam = regexp(dataName,'\');
                if ~isempty(spam)
                    dataName(spam) = '_';
                end
                spam = regexp(dataName,'/');
                if ~isempty(spam)
                    dataName(spam) = '_';
                end
                spam = regexp(dataName,' ');
                if ~isempty(spam)
                    dataName(spam) = '_';
                end
                spam = regexp(dataName,'\.');
                if ~isempty(spam)
                    dataName(spam) = '_';
                end
                eggs = regexp(dataName,filesep);
                if ~isempty(eggs)
                    dataName(eggs) = '_';
                end

                pathData = [pathDataset filesep dataFolderName];
                
                methodFile = strcat(pathData,filesep,'method');
                acqpFile = strcat(pathData,filesep,'acqp');
                fidFile = strcat(pathData,filesep,'fid');
                
                visu_parsFile = strcat(pathData,filesep,'pdata',filesep,'1',filesep,'visu_pars');
                recoFile = strcat(pathData,filesep,'pdata',filesep,'1',filesep,'reco');
                a2dseqFile = strcat(pathData,filesep,'pdata',filesep,'1',filesep,'2dseq');
                
                if exist(methodFile,'file') == 2
                    method = read_parameters(methodFile);
                else
                    method = NaN;
                end
                if exist(acqpFile,'file') == 2
                    acqp = read_parameters(acqpFile);
                else
                    acqp = NaN;
                end
                if exist(visu_parsFile,'file') == 2
                    visu_pars = read_parameters(visu_parsFile);
                else
                    clear_data;
                    return
                end
                if exist(recoFile,'file') == 2
                    reco = read_parameters(recoFile);
                else
                    reco = NaN;
                end
                
                % Get data filename
                idx = max(strfind(allData.pathDataset,filesep));
                %dataSetFolderName = allData.pathDataset(idx+1:end);
                imageDataforAnalyze = read_image(a2dseqFile,fidFile,method,acqp,visu_pars,reco);
                if (size(imageDataforAnalyze,2)>1 && size(imageDataforAnalyze,3)>1)
                    imageDim = visu_pars.VisuCoreSize;
                    nFrames = visu_pars.VisuCoreFrameCount;
                    FOVSize = visu_pars.VisuCoreExtent;
                    SliceThickness = visu_pars.VisuCoreFrameThickness;
                    
                    % Calculate Voxel Size
                    if nFrames == 1
                        voxelSize = FOVSize./imageDim;
                    else
                        voxelSize = FOVSize./imageDim;
                        imageDim = [imageDim nFrames];
                        voxelSize = [voxelSize SliceThickness];
                    end
                    
                    % Write Analyze file
                    writeanalyze(imageDataforAnalyze,imageDim,[pathAnalyze filesep dataName],voxelSize)
                else
                    msgbox([dataName ' not saved (spectrum)'])
                end
            end
        else
            return
        end
    end

    function save_dicom_series(h,evt)
        nSelection = allData.nSelection;
        pathDataset = allData.pathDataset;
        dataFolderPositions = get(Hmain.dataList,'Value');
        dataFolderNames = get(Hmain.dataList,'string');
        
        nDataFolderNames = length(dataFolderNames);
        for cc = 1:1:nDataFolderNames;
            spam = regexp(dataFolderNames{cc},'<');
            if ~isempty(spam)
                eggs = regexp(dataFolderNames{cc},'>');
                dataFolderNames{cc} = dataFolderNames{cc}(eggs(2)+1:spam(3)-1);
            end
        end
        
        pathDICOM = uigetdir;
        if pathDICOM ~= 0
            currentDir = cd;
          
            for ii=1:1:nSelection
                dataFolderPosition = dataFolderPositions(ii);
                dataFolderName = dataFolderNames(dataFolderPosition);
                dataFolderName = dataFolderName{1};
                dataName = ['data' dataFolderName];
                
                pathData = [pathDataset filesep dataFolderName];
                
                methodFile = strcat(pathData,filesep,'method');
                acqpFile = strcat(pathData,filesep,'acqp');
                fidFile = strcat(pathData,filesep,'fid');
                
                visu_parsFile = strcat(pathData,filesep,'pdata',filesep,'1',filesep,'visu_pars');
                recoFile = strcat(pathData,filesep,'pdata',filesep,'1',filesep,'reco');
                a2dseqFile = strcat(pathData,filesep,'pdata',filesep,'1',filesep,'2dseq');
                
                if exist(methodFile,'file') == 2
                    method = read_parameters(methodFile);
                else
                    method = NaN;
                end
                if exist(acqpFile,'file') == 2
                    acqp = read_parameters(acqpFile);
                else
                    acqp = NaN;
                end
                if exist(visu_parsFile,'file') == 2
                    visu_pars = read_parameters(visu_parsFile);
                else
                    clear_data;
                    return
                end
                if exist(recoFile,'file') == 2
                    reco = read_parameters(recoFile);
                else
                    reco = NaN;
                end
                
                % Get data filename
                idx = max(strfind(allData.pathDataset,filesep));
                dataSetFolderName = allData.pathDataset(idx+1:end);
                
                imageData = read_image(a2dseqFile,fidFile,method,acqp,visu_pars,reco);
                imageDataforDICOM = uint16(imageData);
                nSlices = size(imageDataforDICOM,3);
                if(size(imageDataforDICOM,2)>1 && size(imageDataforDICOM,3)>1)
                    % Create subfolder
                    cd(pathDICOM)
                    folderName = [dataFolderName '_dicom'];
                    mkdir(folderName)
                    cd(folderName)
                    pathDICOMSlices = cd;
                    cd(currentDir)
                    
                    % Save dicom series
                    for k=1:1:nSlices
                        singleSlice = squeeze(imageDataforDICOM(:,:,k));
                        sliceName = ['Slice' num2str(k) '.dcm'];
                        pathSingleSlice = [pathDICOMSlices filesep sliceName];
                        dicomwrite(singleSlice,pathSingleSlice);
                    end
                else
                    msgbox([dataName ' not saved (spectrum)'])
                end
            end
        else
            return
        end
    end

    function send_to_workspace(h,evt)
        nSelection = allData.nSelection;
        pathDataset = allData.pathDataset;
        dataFolderPositions = get(Hmain.dataList,'Value');
        dataFolderNames = get(Hmain.dataList,'string');
        
        nDataFolderNames = length(dataFolderNames);
        for cc = 1:1:nDataFolderNames;
            spam = regexp(dataFolderNames{cc},'<');
            if ~isempty(spam)
                eggs = regexp(dataFolderNames{cc},'>');
                dataFolderNames{cc} = dataFolderNames{cc}(eggs(2)+1:spam(3)-1);
            end
        end
      
        for ii=1:1:nSelection
            dataFolderPosition = dataFolderPositions(ii);
            dataFolderName = dataFolderNames(dataFolderPosition);
            dataFolderName = dataFolderName{1};
            
            % Substitute forbidden characters with underscore
            dataName = dataFolderName;
            spam = regexp(dataName,'\');
            if ~isempty(spam)
                dataName(spam) = '_';
            end
            spam = regexp(dataName,'/');
            if ~isempty(spam)
                dataName(spam) = '_';
            end
            spam = regexp(dataName,' ');
            if ~isempty(spam)
                dataName(spam) = '_';
            end
            spam = regexp(dataName,'\.');
            if ~isempty(spam)
                dataName(spam) = '_';
            end
            eggs = regexp(dataName,filesep);
            if ~isempty(eggs)
                dataName(eggs) = '_';
            end
            
            pathData = [pathDataset filesep num2str(dataFolderName)];
            
            methodFile = strcat(pathData,filesep,'method');
            acqpFile = strcat(pathData,filesep,'acqp');
            fidFile = strcat(pathData,filesep,'fid');
            
            visu_parsFile = strcat(pathData,filesep,'pdata',filesep,'1',filesep,'visu_pars');
            recoFile = strcat(pathData,filesep,'pdata',filesep,'1',filesep,'reco');
            a2dseqFile = strcat(pathData,filesep,'pdata',filesep,'1',filesep,'2dseq');
            
            if exist(methodFile,'file') == 2
                method = read_parameters(methodFile);
            else
                method = NaN;
            end
            if exist(acqpFile,'file') == 2
                acqp = read_parameters(acqpFile);
            else
                acqp = NaN;
            end
            if exist(visu_parsFile,'file') == 2
                visu_pars = read_parameters(visu_parsFile);
            else
                clear_data;
                return
            end
            if exist(recoFile,'file') == 2
                reco = read_parameters(recoFile);
            else
                reco = NaN;
            end
            
            imageData = read_image(a2dseqFile,fidFile,method,acqp,visu_pars,reco);
            assignin('base',dataName,imageData)
        end
    end

    function quit_app(h,evt)
        delete(Hmain.mainFigure)
    end

    function update_data(h,evt)
        set(Hmain.mainSlider,'Visible','off')
        set(Hmain.sliceCounter,'Visible','off')
       
        axes_handle = Hmain.mainAxes;
        imageData = allData.imageData;
        nSelection = allData.nSelection;
        
        if nSelection == 1 % Single selection
            currentSlice = allData.currentSlice;
            if (size(imageData,2)==1 && size(imageData,3)==1) % Spectrum
                
                % Set controls visibility
                set(Hmain.mainAxes,'Visible','on')
                set(Hmain.mainSlider,'Visible','off')
                set(Hmain.sliceCounter,'Visible','off')
                set(Hmain.fileMenu.send_to_workspace,'Enable','on')
                set(Hmain.fileMenu.save_file,'Enable','on')
                set(Hmain.fileMenu.save_mat,'Enable','on')
                set(Hmain.fileMenu.save_analyze,'Enable','off')
                set(Hmain.fileMenu.save_dicom_series,'Enable','off')
                
                % Plot spectrum
                axes(axes_handle);
                plot(imageData)
                axis on, grid on
            else % Image
                currentImage = imageData(:,:,currentSlice);
                currentImage = squeeze(currentImage);
                
                lastSlice = size(imageData,3);
                sliderMin = 1;         % Min slider value
                sliderMax = lastSlice; % Max slider value
                sliderStep = [1/(sliderMax-1), 1/(sliderMax-1)]; % Major and minor slider steps set to 1
                
                % Set controls visibility
                set(Hmain.mainAxes,'Visible','on')
                set(Hmain.mainSlider,'Visible','on')
                set(Hmain.sliceCounter,'Visible','on')
                set(Hmain.fileMenu.send_to_workspace,'Enable','on')
                set(Hmain.fileMenu.save_file,'Enable','on')
                set(Hmain.fileMenu.save_mat,'Enable','on')
                set(Hmain.fileMenu.save_analyze,'Enable','on')
                set(Hmain.fileMenu.save_dicom_series,'Enable','on')
                
                % Set slider limits and step
                if lastSlice > 1
                    set(Hmain.mainSlider, 'Min', sliderMin);
                    set(Hmain.mainSlider, 'Max', sliderMax);
                    set(Hmain.mainSlider, 'SliderStep', sliderStep);
                    set(Hmain.mainSlider, 'Value', currentSlice);
                else
                    set(Hmain.mainSlider,'Visible','off')
                end
                
                % Plot image
                axes(axes_handle);
                imagesc(currentImage); % WARNING: I have to check if scaling of intensity is correct
                axis equal
                axis off
                grid off
                colormap('gray')
                counterString = [num2str(currentSlice) '/' num2str(lastSlice)];
                set(Hmain.sliceCounter,'String',counterString);    
            end
        else % Multiple selection
            axes(axes_handle);
            set(Hmain.mainAxes,'Visible','on')
            set(Hmain.mainSlider,'Visible','off')
            set(Hmain.sliceCounter,'Visible','off')
            set(Hmain.fileMenu.send_to_workspace,'Enable','on')
            set(Hmain.fileMenu.save_file,'Enable','on')
            set(Hmain.fileMenu.save_mat,'Enable','on')
            set(Hmain.fileMenu.save_analyze,'Enable','on')
            set(Hmain.fileMenu.save_dicom_series,'Enable','on')
            for j = 1:1:nParameters
                parameterCurrentValue = '-';
                handle_tmp = ['param' 'Value' num2str(j)];
                set(Hmain.(handle_tmp),'String',num2str(parameterCurrentValue));
            end
            imshow(imageData); %  WARNING: I have to check if scaling of intensity is correct
            axis equal
            axis off
            grid off
        end
        
        % Fill parameters
                for j = 1:1:nParameters
                    parameterCurrentLabel = parametersLabels{j};
                    if any(strcmp(parameterCurrentLabel,fieldnames(allData.visu_pars)))
                        parameterCurrentValue = allData.visu_pars.(parameterCurrentLabel);
                    else
                        parameterCurrentValue = '-';
                    end
                    handle_tmp = ['param' 'Value' num2str(j)];
                    set(Hmain.(handle_tmp),'String',num2str(parameterCurrentValue));
                end
        
    end

    function clear_data(h,evt)
        set(Hmain.fileMenu.send_to_workspace,'Enable','off')
        set(Hmain.fileMenu.save_file,'Enable','off')
        set(Hmain.mainAxes,'Visible','off')
        set(Hmain.mainSlider,'Visible','off')
        set(Hmain.sliceCounter,'Visible','off')
        cla(Hmain.mainAxes)
        for j = 1:1:nParameters
            parameterCurrentValue = '-';
            handle_tmp = ['param' 'Value' num2str(j)];
            set(Hmain.(handle_tmp),'String',num2str(parameterCurrentValue));
        end
    end

    function move_main_slider(h,evt)
        currentSlice = get(Hmain.mainSlider,'Value');
        currentSlice = round(currentSlice);
        allData.currentSlice = currentSlice;
        update_data;
    end

    function open_credits(h,evt)
        msgbox({'Project Bruker Editor';'written by Matteo Caffini';'DEIB, PoliMi'} ,'Credits','modal')
    end

    function filter_dataList(h,evt)
        pathDataset = allData.pathDataset;
        
        foldersInList = cellstr(get(Hmain.dataList,'String'));
        
        nContents = length(foldersInList);
        for cc = 1:1:nContents;
            spam2 = regexp(foldersInList{cc},'<');
            if ~isempty(spam2)
                eggs2 = regexp(foldersInList{cc},'>');
                foldersInListNoHTML{cc} = foldersInList{cc}(eggs2(2)+1:spam2(3)-1);
            else
                foldersInListNoHTML{cc} = foldersInList{cc};
            end
        end
        
        if pathDataset ~= 0
            listNames = dir(fullfile(pathDataset, ''));
            dirNames = [];
            fileNames = [];
            for aa = 1:1:length(listNames)
                if listNames(aa,1).isdir==1
                    dirNames{end+1} = listNames(aa,1).name;
                else
                    fileNames{end+1} = listNames(aa,1).name;
                end
            end
            
            % cut '..'
            bb = strcmp(dirNames,'..');
            idx = find(bb==1);
            dirNames(idx) = [];
            
            % cut '.'
            bb = strcmp(dirNames,'.');
            idx = find(bb==1);
            dirNames(idx) = [];
            
            % cut 'AdjResult'
            bb = strcmp(dirNames,'AdjResult');
            idx = find(bb==1);
            dirNames(idx) = [];
            
            %dirNamesSorted = sort_dirNames(dirNames);
            
            filtersOpen = findobj('type','figure','name','Filters');
            if filtersOpen
                figure(filtersOpen);
            else
                % Draw filter figure
                Hmain.filterWindow = figure('Position',[screenSize(3)/2-figureW/2-100 screenSize(4)/2-figureH/2+100 400 580], ...
                    'Visible','on',...
                    'Units','pixel', ...
                    'Resize','off',...
                    'Name','Filters', ...
                    'Numbertitle','off', ...
                    'Tag','filter_figure', ...
                    'Color',defaultColor, ...
                    'Toolbar','none', ...
                    'Menubar','none', ...
                    'DoubleBuffer','on', ...
                    'DockControls','off',...
                    'Renderer','OpenGL');
                
                % Draw filter options
                % Protocol
                protocolsString = {'aa','bb','cc','Custom Protocol'};
                Hmain.filterProtocolPanel = uipanel('parent',Hmain.filterWindow,...
                    'Title','',...
                    'FontWeight','bold',...
                    'FontSize',10,...
                    'FontName',defaultFontName,...
                    'BackgroundColor',defaultColor,...
                    'Units','pixel',...
                    'Position',[30 500 340 60]);
                Hmain.checkboxProtocol = uicontrol('parent',Hmain.filterProtocolPanel,...
                    'Units','pixel',...
                    'Position',[10 19 90 20],...
                    'Style','checkbox',...
                    'HorizontalAlignment','center',...
                    'FontWeight','bold',...
                    'FontSize',12,...
                    'FontName',defaultFontName,...
                    'BackgroundColor',defaultColor,...
                    'String','Protocol',...
                    'Callback',@enable_protocol_filter,...
                    'Enable','on');
                Hmain.popUpProtocol = uicontrol('parent',Hmain.filterProtocolPanel,...
                    'Style','popupmenu',...
                    'String',protocolsString,...
                    'FontSize',12,...
                    'Value',1,...
                    'Position',[120 9 205 40],...
                    'Enable','off',...
                    'Callback',@pop_up_protocol);
                Hmain.textProtocol = uicontrol('parent',Hmain.filterProtocolPanel,...
                    'Style','edit',...
                    'String','',...
                    'HorizontalAlignment','left',...
                    'FontSize',12,...
                    'Value',1,...
                    'Enable','off',...
                    'Position',[120 3 205 24]);
                
                % Sequence type
                sequencesString = {'FLASH (pvm)','RARE (pvm)','SINGLEPULSE (pvm)','Custom Sequence'};
                Hmain.filterSequencePanel = uipanel('parent',Hmain.filterWindow,...
                    'Title','',...
                    'FontWeight','bold',...
                    'FontSize',10,...
                    'FontName',defaultFontName,...
                    'BackgroundColor',defaultColor,...
                    'Units','pixel',...
                    'Position',[30 420 340 60]);
                Hmain.checkboxSequence = uicontrol('parent',Hmain.filterSequencePanel,...
                    'Units','pixel',...
                    'Position',[10 19 90 20],...
                    'Style','checkbox',...
                    'HorizontalAlignment','center',...
                    'FontWeight','bold',...
                    'FontSize',12,...
                    'FontName',defaultFontName,...
                    'BackgroundColor',defaultColor,...
                    'String','Sequence',...
                    'Callback',@enable_sequence_filter,...
                    'Enable','on');
                Hmain.popUpSequence = uicontrol('parent',Hmain.filterSequencePanel,...
                    'Style','popupmenu',...
                    'String',sequencesString,...
                    'FontSize',12,...
                    'Value',1,...
                    'Position',[120 9 205 40],...
                    'Enable','off',...
                    'Callback',@pop_up_sequence);
                Hmain.textSequence = uicontrol('parent',Hmain.filterSequencePanel,...
                    'Style','edit',...
                    'String','',...
                    'HorizontalAlignment','left',...
                    'FontSize',12,...
                    'Value',1,...
                    'Enable','off',...
                    'Position',[120 3 205 24]);
                
                % Date
                Hmain.filterDatePanel = uipanel('parent',Hmain.filterWindow,...
                    'Title','',...
                    'FontWeight','bold',...
                    'FontSize',10,...
                    'FontName',defaultFontName,...
                    'BackgroundColor',defaultColor,...
                    'Units','pixel',...
                    'Position',[30 300 340 100]);
                Hmain.checkboxDate = uicontrol('parent',Hmain.filterDatePanel,...
                    'Units','pixel',...
                    'Position',[10 39 60 20],...
                    'Style','checkbox',...
                    'HorizontalAlignment','center',...
                    'FontWeight','bold',...
                    'FontSize',12,...
                    'FontName',defaultFontName,...
                    'BackgroundColor',defaultColor,...
                    'String','Date',...
                    'Callback',@enable_date_filter,...
                    'Enable','on');
                Hmain.dateFromText = uicontrol('parent',Hmain.filterDatePanel,...
                    'Style','text',...
                    'String','(DD-MMM-YYYY)',...
                    'HorizontalAlignment','center',...
                    'FontSize',9,...
                    'Value',1,...
                    'Enable','off',...
                    'Position',[120 0 100 24]);
                Hmain.dateToText = uicontrol('parent',Hmain.filterDatePanel,...
                    'Style','text',...
                    'String','(DD-MMM-YYYY)',...
                    'HorizontalAlignment','center',...
                    'FontSize',9,...
                    'Value',1,...
                    'Enable','off',...
                    'Position',[225 0 100 24]);
                Hmain.dateFromEdit = uicontrol('parent',Hmain.filterDatePanel,...
                    'Style','edit',...
                    'String','-',...
                    'HorizontalAlignment','center',...
                    'FontSize',12,...
                    'Value',1,...
                    'Enable','off',...
                    'Position',[120 30 100 24]);
                Hmain.dateToEdit = uicontrol('parent',Hmain.filterDatePanel,...
                    'Style','edit',...
                    'String','-',...
                    'HorizontalAlignment','center',...
                    'FontSize',12,...
                    'Value',1,...
                    'Enable','off',...
                    'Position',[225 30 100 24]);
                Hmain.dateFromButton = uicontrol('parent',Hmain.filterDatePanel,...
                    'Units','pixel',...
                    'Position',[120 60 100 24],...
                    'Style','pushbutton',...
                    'FontWeight','bold',...
                    'FontSize',12,...
                    'FontName',defaultFontName,...
                    'String','From',...
                    'Value',0,...
                    'Callback',@get_date_from,...
                    'Enable','off');
                Hmain.dateToButton = uicontrol('parent',Hmain.filterDatePanel,...
                    'Units','pixel',...
                    'Position',[225 60 100 24],...
                    'Style','pushbutton',...
                    'FontWeight','bold',...
                    'FontSize',12,...
                    'FontName',defaultFontName,...
                    'String','To',...
                    'Value',0,...
                    'Callback',@get_date_to,...
                    'Enable','off');
                
                % Time
                hoursStringFrom = {'0','1','2','3','4','5','6','7','8','9','10',...
                    '11','12','13','14','15','16','17','18','19','20',...
                    '21','22','23'};
                hoursStringTo = {'1','2','3','4','5','6','7','8','9','10',...
                    '11','12','13','14','15','16','17','18','19','20',...
                    '21','22','23','24'};
                Hmain.filterTimePanel = uipanel('parent',Hmain.filterWindow,...
                    'Title','',...
                    'FontWeight','bold',...
                    'FontSize',10,...
                    'FontName',defaultFontName,...
                    'BackgroundColor',defaultColor,...
                    'Units','pixel',...
                    'Position',[30 200 340 80]);
                Hmain.checkboxTime = uicontrol('parent',Hmain.filterTimePanel,...
                    'Units','pixel',...
                    'Position',[10 30 60 20],...
                    'Style','checkbox',...
                    'HorizontalAlignment','center',...
                    'FontWeight','bold',...
                    'FontSize',12,...
                    'FontName',defaultFontName,...
                    'BackgroundColor',defaultColor,...
                    'String','Time',...
                    'Callback',@enable_time_filter,...
                    'Enable','on');
                Hmain.timeFromText = uicontrol('parent',Hmain.filterTimePanel,...
                    'Style','text',...
                    'String','From',...
                    'HorizontalAlignment','center',...
                    'FontSize',9,...
                    'Value',1,...
                    'Enable','off',...
                    'Position',[120 35 100 24]);
                Hmain.timeToText = uicontrol('parent',Hmain.filterTimePanel,...
                    'Style','text',...
                    'String','To',...
                    'HorizontalAlignment','center',...
                    'FontSize',9,...
                    'Value',1,...
                    'Enable','off',...
                    'Position',[225 35 100 24]);
                Hmain.timeFromPopUp = uicontrol('parent',Hmain.filterTimePanel,...
                    'Style','popupmenu',...
                    'String',hoursStringFrom,...
                    'FontSize',12,...
                    'Value',1,...
                    'Position',[145 20 70 24],...
                    'Enable','off');
                Hmain.timeToPopUp = uicontrol('parent',Hmain.filterTimePanel,...
                    'Style','popupmenu',...
                    'String',hoursStringTo,...
                    'FontSize',12,...
                    'Value',1,...
                    'Position',[250 20 70 24],...
                    'Enable','off');
                
                % Ok button
                Hmain.applyFilterButton = uicontrol('parent',Hmain.filterWindow,...
                    'Units','pixel',...
                    'Position',[30 140 340 40],...
                    'Style','pushbutton',...
                    'FontWeight','bold',...
                    'FontSize',14,...
                    'FontName',defaultFontName,...
                    'String','Apply Filter',...
                    'Value',0,...
                    'Callback',@apply_filter,...
                    'Enable','on');
                
                % Draw utilities
                % Axes for embedded waitbar
                Hmain.filterAxesWaitbarPanel = uipanel('parent',Hmain.filterWindow,...
                    'Title','',...
                    'FontWeight','bold',...
                    'FontSize',10,...
                    'FontName',defaultFontName,...
                    'BackgroundColor',defaultColor,...
                    'Units','pixel',...
                    'Position',[30 80 340 40]);
                Hmain.filterAxesWaitbar = axes('parent',Hmain.filterAxesWaitbarPanel,...
                    'Units','Pixel',...
                    'Position', [5 5 327 27],...
                    'Xlim',[0 1],'Ylim',[0 1], ...
                    'XDir','normal','YDir','normal',...
                    'Box','off', ...
                    'XGrid','off','YGrid','off',...
                    'Fontsize',12,...
                    'FontName',defaultFontName,...
                    'Drawmode','normal',...
                    'Visible','off');
                
                % Text message
                Hmain.filterMessagePanel = uipanel('parent',Hmain.filterWindow,...
                    'Title','',...
                    'FontWeight','bold',...
                    'FontSize',12,...
                    'FontName',defaultFontName,...
                    'BackgroundColor',defaultColor,...
                    'Units','pixel',...
                    'Position',[30 20 200 40]);
                Hmain.filterMessageText = uicontrol('parent',Hmain.filterMessagePanel,...
                    'Style','text',...
                    'String','Select filters...',...
                    'HorizontalAlignment','left',...
                    'FontSize',13,...
                    'Fontweight','bold',...
                    'Value',1,...
                    'Enable','on',...
                    'Position',[5 4 190 23]);
                
                % Close filter window button
                Hmain.closeFilterButton = uicontrol('parent',Hmain.filterWindow,...
                    'Units','pixel',...
                    'Position',[250 20 120 40],...
                    'Style','pushbutton',...
                    'FontWeight','bold',...
                    'FontSize',14,...
                    'FontName',defaultFontName,...
                    'String','Close',...
                    'Value',0,...
                    'Callback',@quit_filter,...
                    'Enable','on');
            end
        else
            return
        end
        
        function enable_protocol_filter(h,evt)
            ProtocolOn = get(Hmain.checkboxProtocol,'Value');
            if ProtocolOn
                set(Hmain.popUpProtocol,'Enable','on')
            else
                set(Hmain.popUpProtocol,'Enable','off')
            end
        end
        
        function enable_sequence_filter(h,evt)
            sequenceOn = get(Hmain.checkboxSequence,'Value');
            if sequenceOn
                set(Hmain.popUpSequence,'Enable','on')
            else
                set(Hmain.popUpSequence,'Enable','off')
            end  
        end
        
        function enable_date_filter(h,evt)
            dateOn = get(Hmain.checkboxDate,'Value');
            if dateOn
                set(Hmain.dateFromText,'Enable','on')
                set(Hmain.dateToText,'Enable','on')
                set(Hmain.dateFromEdit,'Enable','on')
                set(Hmain.dateToEdit,'Enable','on')
                set(Hmain.dateFromButton,'Enable','on')
                set(Hmain.dateToButton,'Enable','on')
            else
                set(Hmain.dateFromText,'Enable','off')
                set(Hmain.dateToText,'Enable','off')
                set(Hmain.dateFromEdit,'Enable','off')
                set(Hmain.dateToEdit,'Enable','off')
                set(Hmain.dateFromButton,'Enable','off')
                set(Hmain.dateToButton,'Enable','off')
            end
        end
        
        function enable_time_filter(h,evt)
            dateOn = get(Hmain.checkboxTime,'Value');
            if dateOn
                set(Hmain.timeFromText,'Enable','on')
                set(Hmain.timeToText,'Enable','on')
                set(Hmain.timeFromPopUp,'Enable','on')
                set(Hmain.timeToPopUp,'Enable','on')
            else
                set(Hmain.timeFromText,'Enable','off')
                set(Hmain.timeToText,'Enable','off')
                set(Hmain.timeFromPopUp,'Enable','off')
                set(Hmain.timeToPopUp,'Enable','off')
            end
        end
        
        function get_date_from(h,evt)
            uicalendar('DestinationUI',{Hmain.dateFromEdit,'string'})
        end
        
        function get_date_to(h,evt)
            uicalendar('DestinationUI',{Hmain.dateToEdit,'string'})
        end
        
        function pop_up_protocol(h,evt)
            if get(Hmain.popUpProtocol,'Value') == length(protocolsString)
                set(Hmain.textProtocol,'Enable','on');
            else
                set(Hmain.textProtocol,'Enable','off');
            end
        end
        
        function pop_up_sequence(h,evt)
            if get(Hmain.popUpSequence,'Value') == length(sequencesString)
                set(Hmain.textSequence,'Enable','on');
            else
                set(Hmain.textSequence,'Enable','off');
            end
        end
        
        function apply_filter(h,evt)
            filterByProtocol = get(Hmain.checkboxProtocol,'Value');
            filterBySequence = get(Hmain.checkboxSequence,'Value');
            filterByDate = get(Hmain.checkboxDate,'Value');
            filterByTime = get(Hmain.checkboxTime,'Value');
            dirNamesPickedProtocol = {};
            dirNamesPickedSequence = {};
            dirNamesPickedDate = {};
            dirNamesPickedTime = {};
            finalString = [];

            % Get folder list in current folder
            pathDataset2 = allData.pathDataset;
 
            %dirNamesSorted2 = dirNamesSorted;
            dirNamesSorted2 = foldersInListNoHTML;
            
            
             % Filter by protocol name
            if filterByProtocol
                protocolStringPosition = get(Hmain.popUpProtocol,'Value');
                if protocolStringPosition == length(protocolsString)
                    % Custom string
                    protocolString = get(Hmain.textProtocol,'String');
                    for ii = 1:1:length(dirNamesSorted2)
                        visu_parsFile = strcat(pathDataset2,filesep,dirNamesSorted2{ii},filesep,'pdata',filesep,'1',filesep,'visu_pars');
                        visu_pars = read_parameters(visu_parsFile);
                        startIndex = regexpi(visu_pars.VisuAcquisitionProtocol,protocolString);
                        if ~isempty(startIndex)
                            if isempty(dirNamesPickedProtocol)
                                dirNamesPickedProtocol{1} = dirNamesSorted2{ii};
                            else
                                dirNamesPickedProtocol{end+1} = dirNamesSorted2{ii};
                            end
                        end
                        
                    end
                else
                    % Predefined strings
                    protocolString = protocolsString{protocolStringPosition};
                    for ii = 1:1:length(dirNamesSorted2)
                        visu_parsFile = strcat(pathDataset2,filesep,dirNamesSorted2{ii},filesep,'pdata',filesep,'1',filesep,'visu_pars');
                        visu_pars = read_parameters(visu_parsFile);
                        stringComparison = strcmp(visu_pars.VisuAcquisitionProtocol,protocolString);
                        if stringComparison
                            if isempty(dirNamesPickedProtocol)
                                dirNamesPickedProtocol{1} = dirNamesSorted2{ii};
                            else
                                dirNamesPickedProtocol{end+1} = dirNamesSorted2{ii};
                            end
                        end
                        
                    end
                end    
            end
            

            % Filter by sequence name
            if filterBySequence
                sequenceStringPosition = get(Hmain.popUpSequence,'Value');
                if sequenceStringPosition == length(sequencesString)
                    % Custom string
                    sequenceString = get(Hmain.textSequence,'String');
                    for ii = 1:1:length(dirNamesSorted2)
                        visu_parsFile = strcat(pathDataset2,filesep,dirNamesSorted2{ii},filesep,'pdata',filesep,'1',filesep,'visu_pars');
                        visu_pars = read_parameters(visu_parsFile);
                        startIndex = regexpi(visu_pars.VisuAcqSequenceName,sequenceString);
                        if ~isempty(startIndex)
                            if isempty(dirNamesPickedSequence)
                                dirNamesPickedSequence{1} = dirNamesSorted2{ii};
                            else
                                dirNamesPickedSequence{end+1} = dirNamesSorted2{ii};
                            end
                        end
                        
                    end
                else
                    % Predefined strings
                    sequenceString = sequencesString{sequenceStringPosition};
                    for ii = 1:1:length(dirNamesSorted2)
                        visu_parsFile = strcat(pathDataset2,filesep,dirNamesSorted2{ii},filesep,'pdata',filesep,'1',filesep,'visu_pars');
                        visu_pars = read_parameters(visu_parsFile);
                        stringComparison = strcmp(visu_pars.VisuAcqSequenceName,sequenceString);
                        if stringComparison
                            if isempty(dirNamesPickedSequence)
                                dirNamesPickedSequence{1} = dirNamesSorted2{ii};
                            else
                                dirNamesPickedSequence{end+1} = dirNamesSorted2{ii};
                            end
                        end
                        
                    end
                end    
            end
            
            % Filter by date
            if filterByDate
                firstDate = get(Hmain.dateFromEdit,'String');
                lastDate = get(Hmain.dateToEdit,'String');
                
                if firstDate == '0'
                    firstDate = '00-Gen-0000';
                end
                
                if strcmp(lastDate,'today')||strcmp(lastDate,'Today')
                    lastDate = now;
                end
                
                for ii = 1:1:length(dirNamesSorted2)
                    visu_parsFile = strcat(pathDataset2,filesep,dirNamesSorted2{ii},filesep,'pdata',filesep,'1',filesep,'visu_pars');
                    visu_pars = read_parameters(visu_parsFile);
                    scanDate = visu_pars.VisuAcqDate;
                    spam = regexp(scanDate,' ');
                    scanDate = scanDate((spam(1)+1):end);
                    eggs = regexp(scanDate,' ');
                    scanDate(eggs)='-';
                    
                    if (datenum(firstDate)<=datenum(scanDate)) && (datenum(lastDate)>=datenum(scanDate))
                        dateInRange = 1;
                    else
                        dateInRange = 0;
                    end
                    
                    if dateInRange
                        if isempty(dirNamesPickedDate)
                            dirNamesPickedDate{1} = dirNamesSorted2{ii};
                        else
                            if ~strcmp(dirNamesSorted2{ii},dirNamesPickedDate)
                                dirNamesPickedDate{end+1} = dirNamesSorted2{ii};
                            end
                        end
                    end
                    
                end
            end
            
            % Filter by time
            if filterByTime
                firstTime = hoursStringFrom{get(Hmain.timeFromPopUp,'Value')};
                lastTime = hoursStringTo{get(Hmain.timeToPopUp,'Value')};
                
                for ii = 1:1:length(dirNamesSorted2)
                    visu_parsFile = strcat(pathDataset2,filesep,dirNamesSorted2{ii},filesep,'pdata',filesep,'1',filesep,'visu_pars');
                    visu_pars = read_parameters(visu_parsFile);
                    scanTime = visu_pars.VisuAcqDate;
                    spam = regexp(scanTime,':');
                    scanTime = scanTime(1:(spam(1)-1));
                    
                    if (str2double(firstTime) <= str2double(scanTime) && (str2double(lastTime) > str2double(scanTime)))
                        timeInRange = 1;
                    else
                        timeInRange = 0;
                    end
                    
                    if timeInRange
                        if isempty(dirNamesPickedTime)
                            dirNamesPickedTime{1} = dirNamesSorted2{ii};
                        else
                            if ~strcmp(dirNamesSorted2{ii},dirNamesPickedTime)
                                dirNamesPickedTime{end+1} = dirNamesSorted2{ii};
                            end
                        end
                        
                    end
                    
                end
            end
            
            % Intersect filters
            if ~filterByProtocol
                dirNamesPickedProtocol = dirNamesSorted2;
            end
            if ~filterBySequence
                dirNamesPickedSequence = dirNamesSorted2;
            end
            if ~filterByDate
                dirNamesPickedDate = dirNamesSorted2;
            end
            if ~filterByTime
                dirNamesPickedTime = dirNamesSorted2;
            end
            dirNamesPicked = mintersect(dirNamesPickedProtocol,dirNamesPickedSequence,dirNamesPickedDate,dirNamesPickedTime);
            
            Nscans = length(dirNamesPicked);
            
            if Nscans > 0
                spam = regexp(dirNamesPicked,filesep);
                for ii = 1:1:length(dirNamesPicked)
                    nSeparators = size(spam{ii},2);
                    switch nSeparators
                        case 0
                            idx_lastSeparator = 0;
                            lastFolder{ii} = dirNamesPicked{ii}(idx_lastSeparator+1:end);
                            finalString{ii} = lastFolder{ii};
                        case 1
                            idx_lastSeparator = spam{ii}(1,nSeparators);
                            lastFolder{ii} = dirNamesPicked{ii}(idx_lastSeparator+1:end);
                            beforeLastFolder{ii} = dirNamesPicked{ii}(1:idx_lastSeparator-1);
                        case 2
                            idx_lastSeparator = spam{ii}(1,nSeparators);
                            idx_beforeLastSeparator = spam{ii}(1,nSeparators-1);
                            lastFolder{ii} = dirNamesPicked{ii}(idx_lastSeparator+1:end);
                            beforeLastFolder{ii} = dirNamesPicked{ii}(idx_beforeLastSeparator+1:idx_lastSeparator-1);
                    end
                end
                
                % Create group with multiple color before populating list
                if nSeparators > 0
                    [folderGroups,idx_groupOfFolder,idx_folderGroups] = unique(beforeLastFolder);
                    nGroups = size(folderGroups,2);
                    
                    
                    for aa = 1:1:nGroups
                        % Sort folder in group by number
                        foldersInGroup = idx_folderGroups==aa;
                        nFolders = sum(foldersInGroup);
                        
                        Str = sprintf('%s,', lastFolder{foldersInGroup});
                        D = sscanf(Str, '%g,');
                        [dummy, index] = sort(D);
                        index = index + (nFolders*(aa-1));
                        
                        if aa == 1
                            dirNamesSorted = dirNamesPicked(index);
                        else
                            dirNamesSorted = [dirNamesSorted dirNamesPicked(index)];
                        end
                        
                        % Choose color
                        if mod(aa,2)
                            groupColor = 'black';
                        else
                            groupColor = 'red';
                        end
                        
                        % Prepare string to populate listbox with
                        groupString = [];
                        for bb = 1:1:nFolders
                            idx_dirName = bb+(nFolders*(aa-1));
                            if bb == 1
                                groupString{1} = strcat('<html><font color="',groupColor,'">',dirNamesSorted{idx_dirName},'</font></html>');
                            else
                                entryString = strcat('<html><font color="',groupColor,'">',dirNamesSorted{idx_dirName},'</font></html>');
                                groupString{end+1} = entryString;
                            end
                        end
                        if nGroups == 1
                            finalString = groupString;
                        else
                            finalString = [finalString groupString];
                        end
                    end
                end
            end
         
            % Prepare exit message
            if (filterByProtocol == 0) && (filterBySequence == 0) && (filterByDate == 0) && (filterByTime == 0)
                message = 'All filters removed.';
                set(Hmain.dataList,'String',foldersInList)
                set(Hmain.dataList,'Value',1)
                load_image_and_data;
                figure(Hmain.filterWindow)
            else
                set(Hmain.dataList,'string',finalString)
                switch Nscans
                    case 0
                        message = ['Filtering... ' num2str(Nscans) ' scans found.'];
                    case 1
                        message = 'Filtering... 1 scan found.';
                        set(Hmain.dataList,'Value',1)
                        load_image_and_data;
                        figure(Hmain.filterWindow)
                    otherwise
                        message = ['Filtering... ' num2str(Nscans) ' scans found.'];
                        set(Hmain.dataList,'Value',1)
                        load_image_and_data;
                        figure(Hmain.filterWindow)
                end  
            end
            
            set(Hmain.filterMessageText,'String',message);
            dirNamesPicked = {};
        end
        
        function quit_filter(h,evt)
            delete(Hmain.filterWindow);
        end
    end

    function scan_recursively(h,evt)
        pathDataset = allData.pathDataset;
        fill_data_list(pathDataset)
    end
    
    
set(Hmain.mainFigure,'Visible','on')
end