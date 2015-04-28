function imageData = read_image(a2dseqFile,fidFile,method,acqp,visu_pars,reco)

%
% This function is part of:
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

img_type = visu_pars.VisuCoreWordType;
nFrames = visu_pars.VisuCoreFrameCount;

dim = ones(1,3);
for i=1:1:length(visu_pars.VisuCoreSize)
    dim(i) = visu_pars.VisuCoreSize(i);
end

slope = visu_pars.VisuCoreDataSlope;
offset = visu_pars.VisuCoreDataOffs;

%% Read 2dseq file
% Check 2dseq existence
if (~exist(a2dseqFile,'file')==2)
    return
end

% Check precision
file_id = fopen(a2dseqFile);
if strcmp(img_type,'_32BIT_SGN_INT')
    precision = 'int32';
end
if strcmp(img_type,'_16BIT_SGN_INT')
    precision = 'int16';
end

% Read 2dseq file
img = fread(file_id,inf,precision); 

if size(dim,2)==3
    if rem(length(img),dim(1))==0
        if rem(length(img)/dim(1),dim(2))==0
            if rem(length(img)/dim(1)/dim(2),dim(3))==0
                img = reshape(img,dim(1),dim(2),dim(3),nFrames);
                img = squeeze(img);
            else
                img = NaN;
            end
        else
            img = NaN;
        end
    else
        img = NaN;
    end
else
    img = NaN;
end

fclose(file_id);

% Slope/Offset correction
if nFrames == 1
    img = img*slope+offset;
else
    for ii=1:1:nFrames
        img(:,:,ii) = img(:,:,ii)*slope(ii)+offset(ii);
    end
end

imageData = img;
