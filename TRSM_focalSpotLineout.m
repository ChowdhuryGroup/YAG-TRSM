clear all
close all

% Saves vertical and horizontal lineouts of a focal spot image (txt image
% format only).  A .jpg of the focal spot image with red lines indicating
% where the lineouts were measured is saved to disk for reference.
%
% SAVE FORMAT: the output of this code is saved as a matrix with 3 rows:
% row 1: position array (um)
% row 2: vertical lineout values (first element of row corresponds to top
% of lineout in the saved .jpg)
% row 3: horizontal lineout values
% 
% Specify magnification of image, as well as pixel size, so that position
% array can be saved with the lineouts.

path='C:\Users\Noah\Documents\OhioStateU\ChowdhuryResearchGroup\data\LIDT\SundaramSamples_Glass\ZnO\focalspots\2019_05_31\';
filename='focalSpot_7p82mmStagePos_10Hz_110fs_AfterRow5_fiberAdjusted_CROPPED_rotated20deg.txt';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pixel size and Magnification:
pxSize=3.75;
mag=7.5;
umPpx=pxSize/mag;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lineout details:

halfLengthUM =27;
halfLengthPX = round(halfLengthUM/umPpx);

halfLineThicknessUM=0.5;
halfLineThicknessPX=round(halfLineThicknessUM/umPpx);

saveLineout=1; %Save lineout? yes=1, no=0;
savePath = [path,'Lineouts\'];
SaveFN=[filename(1:end-4),'_vert_horiz_Lineouts_',num2str(2*halfLineThicknessUM),'umThickInt.txt'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% position array
pos=(-halfLengthPX:1:halfLengthPX)*umPpx;

focalSpot=dlmread([path,filename],'\t');
focalSpot=focalSpot/max(focalSpot,[],'all');

[h w] = size(focalSpot);

f1=figure('Position',[250 100 700 700])
image([0 w*umPpx],[0 h*umPpx],focalSpot,'CDataMapping','scaled')
colormap jet
caxis([0.02 0.97])
axis image
xlabel('um','fontsize',20)
ylabel('um','fontsize',20)
set(gca,'fontsize',20)
hold on;


i=1;
if saveLineout == 0
        while i==1
            [x y] = getpts(f1);
            x=round(x/umPpx);
            y=round(y/umPpx);
            plot([x-halfLengthPX, x+halfLengthPX]*umPpx,[y, y]*umPpx,'r+-')
            plot([x, x]*umPpx,[y-halfLengthPX, y+halfLengthPX]*umPpx,'r+-')

            % horizontal lineout:
            Hlineout=mean(focalSpot((y-halfLineThicknessPX):1:(y+halfLineThicknessPX),(x-halfLengthPX):1:(x+halfLengthPX)));
            figure(2)
            plot(((x-halfLengthPX):1:(x+halfLengthPX))*umPpx,Hlineout,'LineWidth',2.5)
            axis([(x-halfLengthPX)*umPpx (x+halfLengthPX)*umPpx 0.0 1.1])

            % vertical lineout:
            Vlineout=mean(focalSpot((y-halfLengthPX):1:(y+halfLengthPX),(x-halfLineThicknessPX):1:(x+halfLineThicknessPX)),2);
            figure(3)
            plot(((y-halfLengthPX):1:(y+halfLengthPX))*umPpx,Vlineout,'LineWidth',2.5)
            axis([(y-halfLengthPX)*umPpx (y+halfLengthPX)*umPpx 0.0 1.1])
        end
elseif saveLineout == 1
        [x y] = getpts(f1);
        x=round(x/umPpx);
        y=round(y/umPpx);
        plot([x-halfLengthPX, x+halfLengthPX]*umPpx,[y, y]*umPpx,'r+-')
        plot([x, x]*umPpx,[y-halfLengthPX, y+halfLengthPX]*umPpx,'r+-')

        % horizontal lineout:
        Hlineout=mean(focalSpot((y-halfLineThicknessPX):1:(y+halfLineThicknessPX),(x-halfLengthPX):1:(x+halfLengthPX)));
        figure(2)
        plot(((x-halfLengthPX):1:(x+halfLengthPX))*umPpx,Hlineout,'LineWidth',2.5)
        axis([(x-halfLengthPX)*umPpx (x+halfLengthPX)*umPpx 0.0 1.1])

        % vertical lineout:
        Vlineout=mean(focalSpot((y-halfLengthPX):1:(y+halfLengthPX),(x-halfLineThicknessPX):1:(x+halfLineThicknessPX)),2);
        figure(3)
        plot(((y-halfLengthPX):1:(y+halfLengthPX))*umPpx,Vlineout,'LineWidth',2.5)
        axis([(y-halfLengthPX)*umPpx (y+halfLengthPX)*umPpx 0.0 1.1])
       
        % put lineouts and position arrays in one matrix: [pos; Vlineout;
        % Hlineout]
        lineoutDat=[pos;Vlineout';Hlineout];
        
        saveas(f1,[savePath,SaveFN(1:end-4),'.jpg']);
        csvwrite([savePath,SaveFN],lineoutDat);
end