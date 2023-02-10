close all;
% Automation of image processing for time-resolved transmission microscope
% images.  
%
% 1) user specifies the position in a representative image where the center
% of the first image crop occurs.  This position will be used for the rest
% of the images in the filepath. 
%
% 2) user specifies a position within the cropped image to be the center of
% the square region where the data is to be ignored for the background
% fitting step (typically this position is near the center of the cropped
% image, where the damage spot is located).  The region size is specified
% by the user beforehand.
%
% 3) The background fitting and subtraction is done, and the user specifies
% the position of the center of the final crop region.  
%
% 4) The final processed image is displayed and the user is prompted if the
% rest of the images in the path are OK to be processed with the current
% settings.
%
% Note: the sizes of all of the regions must be specified beforehand
%
% Need-To-Update: -delaytime calculator more flexible

% directory filepath:
path='C:\Users\Noah\Documents\OhioStateU\ChowdhuryResearchGroup\data\LIDT\YAG_TRSM\YAG111_16p1uJ\';
rowSpecifier='';
files=dir([path,rowSpecifier,'*_1.bmp']);

zeroDelayDist=[0.007 0.278 0 0]; %[zero delay micrometer stage position (inches), largest micrometer position, manual stage zero delay position (mm), fixed delay (inches)]

% filename of representative image:
filename='45mm_0p07mm_1.bmp';


saveLineoutPlot=0; %1 for yes, which saves figure with yellow line and separate lineout figure.
                   %0 just saves figure with no line, and does not save lineout. 
flipImageHorizontally=1; %1 for yes; a mirror was used to turn the beam in the imaging setup, so an extra flip is necessary for the images
                         %0 for no; image was ONLY inverted by imaging
                         %optics     

rawI=imread([path,filename]); %handle for the RAW image

umPpx=(0.227/2)*0.9476; % in situ microscope calibration in um/px, 0.227 for f=200mm imaging lens, /2 for f=400 imaging lens (for now).  Calibration factor 0.9476 calculated from AFM image is now applied.

% choose crop rectangle to crop the image around the damage site
figure
imshow(rawI)
[centerX, centerY]=getpts;
close
centerX=round(centerX);
centerY=round(centerY);

% crop image with rectangle centered on center point chosen above, with
% dimensions height and width (in units of pixels)
width=570; %700 410 520
height=570;%700 410 520
Icropped=imcrop(rawI,[centerX-width/2 centerY-height/2 width height]);
IcMat=double(Icropped);
[X,Y]=meshgrid(1:1:width+1,1:1:height+1);

% choose rectangle to crop the damage spot out of the image for image
% flattening
figure
imshow(Icropped)
[cXf, cYf] = getpts;
close
cXf=round(cXf);
cYf=round(cYf);
wf=320; %320
hf=320; %320

% use the coordinates (cXf,cYf) and the height and width to set the pixel values of the image in the
% rectangle to 1 less than the min value of the entire matrix
IcMat2=IcMat;
IcMat2(cXf-round(wf/2):cXf+round(wf/2),cYf-round(hf/2):cYf+round(hf/2))=min(min(IcMat))-1;

% reshape coordinate matrices and pixel value matrix to a single column (to
% give the fit function the correct input type), and run a polynomial
% surface fit on only the data points outside of the rectangle defined
% above:
x=reshape(X,[],1);
y=reshape(Y,[],1);
IcArray2=reshape(IcMat2,[],1);

gr=IcArray2>(min(min(IcMat))-1);

linFit=fit([x(gr),y(gr)],IcArray2(gr),'poly55');

% plot the fit function as well as the uncropped image data:
IcArray=reshape(IcMat,[],1);
figure(1)
plot(linFit,[x,y],IcArray)

% plot the flattened data:
IcFlattened=IcArray-linFit([x,y]);
figure(2)
plot3(x,y,IcFlattened,'o','MarkerEdgeColor','w','MarkerFaceColor','b')

% Evaluate the relative transmission at a given position in the image
% defined by the pixel value of the raw image minus the fit function value,
% divided by the fit function value (i.e. DeltaT/T)
%
% NOTE: the tool that shows the function value at your mouse position in
% the figure of the plot below does NOT show the actual function value, it
% just shows the RGB value, which maps to but is not equal to the function
% value.
DeltaToverT=IcFlattened./linFit([x,y]); % This is DeltaT/T_0
DeltaTMat=reshape(DeltaToverT,size(IcMat));

% specify a position and size of rectangle about that position to calculate
% the (spatially) averaged relative transmission change.  The lineout below
% will correspond to a line going through the position chosen here. 
% Also specify lineout line halfwidth and line thickness:
aveRectW=6; % full width of averaging region (MUST BE EVEN INTEGER)
aveRectH=6; % full height of averaging region (MUST BE EVEN INTEGER)
halfwidth=60; % choose a fixed lineout length (MUST BE EVEN INTEGER)
lineThickness= 6; % line thickness of lineout (averaging occurs over rows)(MUST BE EVEN INTEGER)

if flipImageHorizontally==1;
    DTMat=flip(rot90(DeltaTMat,2),2);
else 
    DTMat=rot90(DeltaTMat,2);
end

figure(3)
image(DTMat,'CDataMapping','scaled')
colormap gray
caxis([-1.0 0.5])
axis image
[cX2, cY2]=getpts;
cX2=round(cX2);
cY2=round(cY2);
width2=375; % pixels (650)(375)(450)
height2=375; % pixels (650)(375)(450)

% (centerX-width2/2:centerX+width2/2,centerY-height2/2:centerY+height2/2)
% [0 rect2(3)*umPpx], [0, rect2(4)*umPpx]
% (rect2(1):(rect2(1)+rect2(3)),rect2(2):(rect2(2)+rect2(4)))

croppedDeltaTMat=DeltaTMat(cX2-round(width2/2):cX2+round(width2/2),cY2-round(height2/2):cY2+round(height2/2));
if flipImageHorizontally==1;
    croppedDTMat=flip(rot90(croppedDeltaTMat,2),2);
else 
    croppedDTMat=rot90(croppedDeltaTMat,2);
end


f=figure(4);
image([0 width2*umPpx], [0 height2*umPpx], croppedDTMat,'CDataMapping','scaled')
colormap gray
caxis([-1.0 0.5])
axis image
xlabel('um','fontsize',20)
ylabel('um','fontsize',20)
set(gca,'fontsize',20)

% Prompt user to verify that current settings are OK:
str=input('Are current settings OK? y/n: ','s');
if str == 'n';
    display('rerun program with new settings');
elseif str == 'y';
    for i = 1:length(files)
        filename=files(i).name;
        rawI=imread([path,files(i).name]); %handle for the RAW image

        
%         delayTime=(str2num(filename(end-9:end-6))/10000-zeroDelayDist(1))*25.4*2/0.3; %in ps
%         delayTime=(str2num(filename(end-8:end-6))/1000-zeroDelayDist(1))*25.4*2/0.3; %in ps
%         delayTime=(str2num(filename(end-13:end-10))/10000-zeroDelayDist(1))*25.4*2/0.3; %in ps
        % delayTime=((zeroDelayDist(2)-zeroDelayDist(1))*25.4+str2num(filename(end-8:end-6))-zeroDelayDist(3))*2/0.3; %in ps
        % delayTime=((zeroDelayDist(2)-zeroDelayDist(1)+zeroDelayDist(4)/2)*25.4+str2num(filename(end-17:end-15))-zeroDelayDist(3))*2/0.3; %in ps
        % delayTime = 45800; %20037 29800 45800
        % delayTime = 3140.389;
        delayTime=((str2num(filename(end-9:end-8))+100*str2num(filename(end-11))/1000-0.007)*25.4+ 45-str2num(filename(1:2)))*2/0.3; % in ps

        delayTime=round(delayTime*1000)/1000; %rounds to nearest fs

        umPpx=0.227/2*0.9476; % in situ microscope calibration in um/px, 0.227 for f=200mm imaging lens, /2 for f=400 imaging lens (for now)

        % crop image with rectangle centered on center point chosen above, with
        % dimensions height and width (in units of pixels)
        Icropped=imcrop(rawI,[centerX-width/2 centerY-height/2 width height]);
        IcMat=double(Icropped);
        [X,Y]=meshgrid(1:1:width+1,1:1:height+1);

        % use the coordinates (cXf,cYf) and the height and width to set the pixel values of the image in the
        % rectangle to 1 less than the min value of the entire matrix
        IcMat2=IcMat;
        IcMat2(cXf-round(wf/2):cXf+round(wf/2),cYf-round(hf/2):cYf+round(hf/2))=min(min(IcMat))-1;

        % reshape coordinate matrices and pixel value matrix to a single column (to
        % give the fit function the correct input type), and run a polynomial
        % surface fit on only the data points outside of the rectangle defined
        % above:
        x=reshape(X,[],1);
        y=reshape(Y,[],1);
        IcArray2=reshape(IcMat2,[],1);

        gr=IcArray2>(min(min(IcMat))-1);

        linFit=fit([x(gr),y(gr)],IcArray2(gr),'poly55');

        % plot the fit function as well as the uncropped image data:
        IcArray=reshape(IcMat,[],1);
%         figure(1)
%         plot(linFit,[x,y],IcArray)

        % plot the flattened data:
        IcFlattened=IcArray-linFit([x,y]);
%         figure(2)
%         plot3(x,y,IcFlattened,'o','MarkerEdgeColor','w','MarkerFaceColor','b')

        % Evaluate the relative transmission at a given position in the image
        % defined by the pixel value of the raw image minus the fit function value,
        % divided by the fit function value (i.e. DeltaT/T)
        %
        % NOTE: the tool that shows the function value at your mouse position in
        % the figure of the plot below does NOT show the actual function value, it
        % just shows the RGB value, which maps to but is not equal to the function
        % value.
        DeltaToverT=IcFlattened./linFit([x,y]);
        DeltaTMat=reshape(DeltaToverT,size(IcMat));

        % specify a position and size of rectangle about that position to calculate
        % the (spatially) averaged relative transmission change.  The lineout below
        % will correspond to a line going through the position chosen here. 
        % Also specify lineout line halfwidth and line thickness:
        aveRectW=6; % full width of averaging region (MUST BE EVEN INTEGER)
        aveRectH=6; % full height of averaging region (MUST BE EVEN INTEGER)
        halfwidth=60; % choose a fixed lineout length (MUST BE EVEN INTEGER)
        lineThickness= 6; % line thickness of lineout (averaging occurs over rows)(MUST BE EVEN INTEGER)

        if flipImageHorizontally==1;
            DTMat=flip(rot90(DeltaTMat,2),2);
        else 
            DTMat=rot90(DeltaTMat,2);
        end


        croppedDeltaTMat=DeltaTMat(cX2-round(width2/2):cX2+round(width2/2),cY2-round(height2/2):cY2+round(height2/2));
        if flipImageHorizontally==1;
            croppedDTMat=flip(rot90(croppedDeltaTMat,2),2);
        else 
            croppedDTMat=rot90(croppedDeltaTMat,2);
        end


        f=figure(4);
        image([0 width2*umPpx], [0 height2*umPpx], croppedDTMat,'CDataMapping','scaled')
        colormap gray
        caxis([-1.0 0.5])
        axis image
        xlabel('um','fontsize',20)
        ylabel('um','fontsize',20)
        set(gca,'fontsize',20)

        % Save croppedDTMat matrix to a tab-delimited .txt file:
        dlmwrite([path,'DToverTtxtfiles\',filename(1:end-4),'_',num2str(delayTime),'ps_',num2str(umPpx),'umPpx.txt'],croppedDTMat,'delimiter','\t');

        % Save figure as png with or without lineout:
        if saveLineoutPlot==0;
            saveas(f,[path,'DToverTimages\',filename(1:end-4),'_',num2str(delayTime),'ps.png']);
        else 
            [xPos,yPos]=getpts;
            hw=halfwidth*umPpx;
            hold on;
            plot([(xPos-hw) (xPos+hw)],[yPos yPos],'-y')

            % produce a lineout of the plot over the horizontal line defined by the point
            % (xPos,yPos) and the halfwidth specified above. Averaging over rows given
            % by linethickness is applied
            xPospx=round(xPos/umPpx);
            yPospx=round(yPos/umPpx);
            rotatedDTmat=rot90(DeltaTMat(cX2-width2/2:cX2+width2/2,cY2-height2/2:cY2+height2/2),2);
            lineout=mean(rotatedDTmat((yPospx-lineThickness/2):(yPospx+lineThickness/2),(xPospx-halfwidth):(xPospx+halfwidth)));
            f2=figure(5);
            plot(((xPospx-halfwidth):1:(xPospx+halfwidth))*umPpx,lineout,'LineWidth',2.5)
            axis([(xPospx-halfwidth)*umPpx (xPospx+halfwidth)*umPpx -1 0.2])
            xlabel('um','fontsize',18)
            ylabel('Relative Transmission Change','fontsize',18)
            set(gca,'fontsize',18)

            saveas(f,[path,'DToverTimages\',filename(1:end-4),'wLineoutLine.png']);
            saveas(f2,[path,'DToverTimages\',filename(1:end-4),'LINEOUT.png']);
        end
    end
else
    display('incorrect input. Rerun program.');
end



           


