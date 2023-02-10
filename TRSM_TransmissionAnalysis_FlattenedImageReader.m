close all;

% Select mode:
% 
% MODE 1: display DT/T values at position in image specified by user.
% Averaging over user defined rectangle is an option below.
% 
% MODE 2: display horizontal and vertical DT/T lineouts centered on user specified position. User
% must specify a line halfwidth and halfheight (in units of um).
% Averaging over user specified line halfthickness is an option below.
% Specify whether lineout is to be saved.
% 
% MODE 3: specify a rectangle over which to sum DT/T values (i.e. integrate
% the signal over a user-defined rectangle)
% 
% MODE 4: specify a rectangle to crop the image and save the cropped image
% to disk
%
% MODE 5: Automates mode 1, extracting DT/T values for all images in the
% filepath at a specified position in a representative image.
% The representative image is specified in "filename" below.  The DT/T
% values for each delay time are saved to a csv file.  Specify the filepath
% to save the .csv file to. Specify the searchCriteria string in order to
% analyze images of a certain row, if desired.
%
% MODE 6: Same as MODE 5, except that the user specifies the position to
% evalulate DT/T for every image, instead of just for a single
% representative one.
%
% MODE 7: Similar to MODE 2; extracts vertical and horizontal lineouts for
% each image in the specified filepath.  The center position of the
% lineouts is specified by the user for each individual image (like in MODE
% 6).  Averaging over user specified line halfthickness is an option below.
%  The lineouts are saved to disc in the form of two matrices: each column
%  of the vertical lineout matrix has the delay time followed by the DT/T
%  lineout data.  Each row of the horizontal lineout matrix has the delay
%  time followed by the DT/T lineout data.
% 

mode=7;

path = 'C:\Users\Noah\Documents\OhioStateU\ChowdhuryResearchGroup\data\LIDT\YAG_TRSM\YAG111_16p1uJ\DToverTtxtfiles\';
filename='43mm_10p07mm_1_1197.481ps_0.10755umPpx.txt';
searchCriteria='y2x*';

DToT=dlmread([path,filename],'\t');
% DToT = [[-1 -1 -1 -1];[0 0 -1 -1];[-1 0 -1 0];[0 0 0 0]];

[h, w] = size(DToT);
umPpx=str2num(filename(end-14:end-9))*0.9476; % the factor of 0.9476 is from AFM image; only put this factor if file name indicates that umPpx = 0.1135

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODE 1 options/settings:
ave=1; % Average DToT over specificied rectangle size? 0 if no, 1 if yes

aveHum=1.5;
aveWum=1.5;

aveHALFHpx=round(aveHum/umPpx/2);
aveHALFWpx=round(aveWum/umPpx/2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODE 2 options/settings:
halfwidthUM =30;
halfwidthPX = round(halfwidthUM/umPpx);
if halfwidthPX >w/2
    halfwidthPX=floor(w/2); % this is to get around the problem where the whole length of the lineout line isn't larger than the image itself
end

halfheightUM=30;
halfheightPX=round(halfheightUM/umPpx);
if halfheightPX>h/2
    halfheightPX=floor(h/2);
end

halfLineThicknessUM=0.25;
halfLineThicknessPX=round(halfLineThicknessUM/umPpx);

saveLineout=0; %Save lineout? yes=1, no=0;
M2datSavePath = 'C:\Users\Noah\Documents\OhioStateU\ChowdhuryResearchGroup\data\LIDT\SundaramSamples_Glass\SLS\PumpProbe\2019_06_03\DToverTdata\mode2\';
M2vertdatSaveFN=[searchCriteria(1:2),'_DToTvsDelay_mode2_vertLineouts_',filename(end-14:end-9),'umPpx_',num2str(2*halfLineThicknessUM),'umThickInt_'];
M2horizdatSaveFN=[searchCriteria(1:2),'_DToTvsDelay_mode2_horizLineouts_',filename(end-14:end-9),'umPpx_',num2str(2*halfLineThicknessUM),'umThickInt_'];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODE 3 has no options/settings


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODE 4 options/settings:
width=279; %px (220)
height=279;%px (220)
savePath='C:\Users\Noah\Documents\OhioStateU\ChowdhuryResearchGroup\data\LIDT\SundaramSamples_Glass\Borofloat\PumpProbe\2019_05_24\CroppedImages\';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODE 5 options/settings:
% The averaging region size is specified in the MODE 1 settings.
M5datSavePath='C:\Users\Noah\Documents\OhioStateU\ChowdhuryResearchGroup\data\LIDT\SundaramSamples_Glass\Borofloat\PumpProbe\2019_05_27\DToverTdata\mode5\';
M5datSaveFilename=[searchCriteria(1:2),'_DToTvsDelay_mode5_',num2str(2*aveHum),'umIntRegion.txt'];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODE 6 options/settings:
% The averaging region size is specified in the MODE 1 settings.
M6datSavePath='C:\Users\Noah\Documents\OhioStateU\ChowdhuryResearchGroup\data\LIDT\ThinFilmDamageExperiments\SiO2_HfO2_QLTF\pumpProbe\2020_01_13\DToverTdata\mode6\';
M6datSaveFilename=[searchCriteria(1:2),'_DToTvsDelay_mode6_',num2str(2*aveHum),'umIntRegion.txt'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODE 7 options/settings:
% The linehalflengths and thicknesses are specificed in the MODE 2
% settings.
M7datSavePath = 'C:\Users\Noah\Documents\OhioStateU\ChowdhuryResearchGroup\data\LIDT\YAG_TRSM\YAG111_16p1uJ\DToverTtxtfiles\DToverTdata\mode7\';
M7vertdatSaveFN=[searchCriteria(1:2),'_DToTvsDelay_mode7_vertLineouts_',filename(end-14:end-9),'umPpx_',num2str(2*halfLineThicknessUM),'umThickInt.txt'];%end-14:end-9, searchCriteria(1:2)
M7horizdatSaveFN=[searchCriteria(1:2),'_DToTvsDelay_mode7_horizLineouts_',filename(end-14:end-9),'umPpx_',num2str(2*halfLineThicknessUM),'umThickInt.txt'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f1=figure('Position',[250 150 600 600])
image([0 w*umPpx],[0 h*umPpx],DToT,'CDataMapping','scaled')
colormap gray
caxis([-1.0 0.5])
axis image
xlabel('um','fontsize',20)
ylabel('um','fontsize',20)
set(gca,'fontsize',20)
hold on;

i=1;
if mode == 1 
    while i==1        
        [x y] = getpts(f1)
        plot(x,y,'r+','MarkerSize',5)
        x=round(x/umPpx);
        y=round(y/umPpx);
        
%         size(DToT((x-halfwidthPX):1:(x+halfwidthPX),(y-halfLineThicknessPX):1:(y+halfLineThicknessPX)))
%         size((x-halfwidthPX):1:(x+halfwidthPX))

        if ave==0
            DT=DToT(y,x)
        else
            DT=mean(mean(DToT(y-aveHALFHpx:y+aveHALFHpx,x-aveHALFWpx:x+aveHALFWpx)))
        end
    end
elseif mode ==2 
    if saveLineout == 0
        while i==1
            [x y] = getpts(f1);
            x=round(x/umPpx);
            y=round(y/umPpx);
            plot([x-halfwidthPX, x+halfwidthPX]*umPpx,[y, y]*umPpx,'r+-')
            plot([x, x]*umPpx,[y-halfheightPX, y+halfheightPX]*umPpx,'r+-')

            % horizontal lineout:
            if x-halfwidthPX<1
                Hlineout=mean(DToT((y-halfLineThicknessPX):1:(y+halfLineThicknessPX),1:1:(x+halfwidthPX)));
                Hlineout=[zeros(1,halfwidthPX-x+1),Hlineout];
            elseif x+halfwidthPX>w
                Hlineout=mean(DToT((y-halfLineThicknessPX):1:(y+halfLineThicknessPX),(x-halfwidthPX):1:w));
                Hlineout=[Hlineout,zeros(1,x+halfwidthPX-w)];
            else
                Hlineout=mean(DToT((y-halfLineThicknessPX):1:(y+halfLineThicknessPX),(x-halfwidthPX):1:(x+halfwidthPX)));
            end
            figure(2)
            plot(((x-halfwidthPX):1:(x+halfwidthPX))*umPpx,Hlineout,'LineWidth',2.5)
            axis([(x-halfwidthPX)*umPpx (x+halfwidthPX)*umPpx -1.0 0.3])

            % vertical lineout:
            if y-halfheightPX<1
                Vlineout=mean(DToT(1:1:(y+halfheightPX),(x-halfLineThicknessPX):1:(x+halfLineThicknessPX)),2);
                Vlineout=[zeros(halfheightPX-y+1,1);Vlineout];
            elseif y+halfheightPX>h
                Vlineout=mean(DToT((y-halfheightPX):1:h,(x-halfLineThicknessPX):1:(x+halfLineThicknessPX)),2);
                Vlineout=[Vlineout;zeros(y+halfheightPX-h,1)];
            else
                Vlineout=mean(DToT((y-halfheightPX):1:(y+halfheightPX),(x-halfLineThicknessPX):1:(x+halfLineThicknessPX)),2);
            end
            figure(3)
            plot(((y-halfheightPX):1:(y+halfheightPX))*umPpx,Vlineout,'LineWidth',2.5)
            axis([(y-halfheightPX)*umPpx (y+halfheightPX)*umPpx -1.0 0.3])
        end
    elseif saveLineout == 1
        [x y] = getpts(f1);
        x=round(x/umPpx);
        y=round(y/umPpx);
        plot([x-halfwidthPX, x+halfwidthPX]*umPpx,[y, y]*umPpx,'r+-')
        plot([x, x]*umPpx,[y-halfheightPX, y+halfheightPX]*umPpx,'r+-')

        % horizontal lineout:
        if x-halfwidthPX<=0
            Hlineout=mean(DToT((y-halfLineThicknessPX):1:(y+halfLineThicknessPX),1:1:(x+halfwidthPX)));
            Hlineout=[zeros(1,halfwidthPX-x),Hlineout];
        elseif x+halfwidthPX>w
            Hlineout=mean(DToT((y-halfLineThicknessPX):1:(y+halfLineThicknessPX),(x-halfwidthPX):1:h));
            Hlineout=[Hlineout,zeros(1,x+halfwidthPX-w)];
        else
            Hlineout=mean(DToT((y-halfLineThicknessPX):1:(y+halfLineThicknessPX),(x-halfwidthPX):1:(x+halfwidthPX)));
        end
        figure(2)
        plot(((x-halfwidthPX):1:(x+halfwidthPX))*umPpx,Hlineout,'LineWidth',2.5)
        axis([(x-halfwidthPX)*umPpx (x+halfwidthPX)*umPpx -1.0 0.3])

        % vertical lineout:
        if y-halfheightPX<1
            Vlineout=mean(DToT(1:1:(y+halfheightPX),(x-halfLineThicknessPX):1:(x+halfLineThicknessPX)),2);
            Vlineout=[zeros(halfheightPX-y+1,1);Vlineout];
        elseif y+halfheightPX>h
            Vlineout=mean(DToT((y-halfheightPX):1:h,(x-halfLineThicknessPX):1:(x+halfLineThicknessPX)),2);
            Vlineout=[Vlineout;zeros(y+halfheightPX-h,1)];
        else
            Vlineout=mean(DToT((y-halfheightPX):1:(y+halfheightPX),(x-halfLineThicknessPX):1:(x+halfLineThicknessPX)),2);
        end
        figure(3)
        plot(((y-halfheightPX):1:(y+halfheightPX))*umPpx,Vlineout,'LineWidth',2.5)
        axis([(y-halfheightPX)*umPpx (y+halfheightPX)*umPpx -1.0 0.3])
        
        if contains(filename,'PuB')
            delaySpecifier='PuB';
        else
            % find delay time from filename:
            dtInd=strfind(filename,'in_')+3; % filename string index at which delay time starts
            j=0;
            while ~isempty(str2num(filename(dtInd:dtInd+j))) % check each char in filename after dtInd until you reach the end of the delay time
                j=j+1;                                   
            end
            delay=vertcat(delay,[str2num(filename(dtInd:dtInd+j-1))]);
            delaySpecifier=[num2str(delay), 'ps'];
        end
        
        csvwrite([M2datSavePath,M2vertdatSaveFN,delaySpecifier,'.txt'],Vlineout);
        csvwrite([M2datSavePath,M2horizdatSaveFN,delaySpecifier,'.txt'],Hlineout);
    end
elseif mode == 3
    while i==1
        rect=getrect(f1);
        rectArea=rect(3)*rect(4)
        rect=round(rect/umPpx);
        
        integratedDToT=sum(sum(DToT(rect(2):1:(rect(2)+rect(4)),rect(1):1:(rect(1)+rect(3)))))
    end   
elseif mode==4
    [x y]=getpts(f1);
    x=round(x/umPpx);
    y=round(y/umPpx);
    croppedDToT=DToT(y-round(height/2):y+round(height/2),x-round(width/2):x+round(width/2));
    f2=figure('Position',[250 150 600 600])
    image([0 width*umPpx],[0 height*umPpx],croppedDToT,'CDataMapping','scaled')
    colormap gray
    caxis([-1.0 0.5])
    axis image
    set(gca,'YTickLabel',[])
    set(gca,'XTickLabel',[])
    
    saveas(f2,[savePath,filename(1:end-4),'_',num2str(round(width*umPpx)),'umWide.png']);
elseif mode==5
    files=dir([path,searchCriteria,'.txt']);
    PuBfiles=dir([path,searchCriteria,'PuB*.txt']);
    
    [x y] = getpts(f1);
    x=round(x/umPpx);
    y=round(y/umPpx);
    
    DTs=[];
    delays=[];
    for i=1:length(files)
       if isempty(strfind(files(i).name,'PuB'))&& isempty(strfind(files(i).name,'x0'))&& isempty(strfind(files(i).name,'PrB'))
           filename=files(i).name;
           DToT=dlmread([path,filename],'\t');
           [h, w] = size(DToT);
           umPpx=str2num(filename(end-14:end-9));
           DTs=vertcat(DTs,[mean(mean(DToT(y-aveHALFHpx:y+aveHALFHpx,x-aveHALFWpx:x+aveHALFWpx)))]);
           
           % find delay time from filename:
           dtInd=strfind(filename,'in_')+3; % filename string index at which delay time starts
           j=0;
           while ~isempty(str2num(filename(dtInd:dtInd+j))) % check each char in filename after dtInd until you reach the end of the delay time
               j=j+1;                                   
           end
           delays=vertcat(delays,[str2num(filename(dtInd:dtInd+j-1))]);
       else
       end
    end
    close(f1);
    % sort delays and DTs arrays in acsending order of delays:
    [delays, idx]=sort(delays);
    DTs=DTs(idx);
    plot(delays,DTs,'o')
    
    % save [delays DTs] to csv file:
    csvwrite([M5datSavePath,M5datSaveFilename],[delays DTs])
    
elseif mode == 6
    files=dir([path,searchCriteria,'.txt']);
    PuBfiles=dir([path,searchCriteria,'PuB*.txt']);
    
    [x y] = getpts(f1);
    x=round(x/umPpx);
    y=round(y/umPpx);
    
    close(f1);
    DTs=[];
    delays=[];
    for i=1:length(files)
       if isempty(strfind(files(i).name,'PuB'))&& isempty(strfind(files(i).name,'x0'))&& isempty(strfind(files(i).name,'PrB'))
           filename=files(i).name;
           DToT=dlmread([path,filename],'\t');
           [h, w] = size(DToT);
           umPpx=str2num(filename(end-14:end-9));
           
           f1=figure('Position',[250 150 600 600])
           image([0 w*umPpx],[0 h*umPpx],DToT,'CDataMapping','scaled')
           colormap gray
           caxis([-1.0 0.5])
           axis image
           xlabel('um','fontsize',20)
           ylabel('um','fontsize',20)
           set(gca,'fontsize',20)
           hold on;
           plot(x*umPpx,y*umPpx,'r+','MarkerSize',10)
           
           [x y] = getpts(f1);
           x=round(x/umPpx);
           y=round(y/umPpx);
           
           DTs=vertcat(DTs,[mean(mean(DToT(y-aveHALFHpx:y+aveHALFHpx,x-aveHALFWpx:x+aveHALFWpx)))]);
           
           % find delay time from filename:
           dtInd=strfind(filename,'in_')+3; % filename string index at which delay time starts
           j=0;
           while ~isempty(str2num(filename(dtInd:dtInd+j))) % check each char in filename after dtInd until you reach the end of the delay time
               j=j+1;                                   
           end
           delays=vertcat(delays,[str2num(filename(dtInd:dtInd+j-1))]);
           
           close(f1);
       else
       end
    end
    % sort delays and DTs arrays in acsending order of delays:
    [delays, idx]=sort(delays);
    DTs=DTs(idx);
    plot(delays,DTs,'o')
    
    % save [delays DTs] to csv file:
    csvwrite([M6datSavePath,M6datSaveFilename],[delays DTs])    
    
elseif mode==7
    files=dir([path,searchCriteria,'.txt']);
    PuBfiles=dir([path,searchCriteria,'PuB*.txt']);
    
    [x y] = getpts(f1);
    x=round(x/umPpx);
    y=round(y/umPpx);
    
    close(f1);
    VLOs=[];
    HLOs=[];
    delays=[];
    for i=1:length(files)
       if isempty(strfind(files(i).name,'PuB'))&& isempty(strfind(files(i).name,'x0'))&& isempty(strfind(files(i).name,'PrB'))
           filename=files(i).name;
           DToT=dlmread([path,filename],'\t');
           [h, w] = size(DToT);
           umPpx=str2num(filename(end-14:end-9));
           
           f1=figure('Position',[250 150 600 600])
           image([0 w*umPpx],[0 h*umPpx],DToT,'CDataMapping','scaled')
           colormap gray
           caxis([-1.0 0.5])
           axis image
           xlabel('um','fontsize',20)
           ylabel('um','fontsize',20)
           set(gca,'fontsize',20)
           hold on;
           plot(x*umPpx,y*umPpx,'r+','MarkerSize',10)
           
           [x y] = getpts(f1);
           x=round(x/umPpx);
           y=round(y/umPpx);
           plot([x-halfwidthPX, x+halfwidthPX]*umPpx,[y, y]*umPpx,'r+-')
           plot([x, x]*umPpx,[y-halfheightPX, y+halfheightPX]*umPpx,'r+-')

            % horizontal lineout:
            if x-halfwidthPX<1
                Hlineout=mean(DToT((y-halfLineThicknessPX):1:(y+halfLineThicknessPX),1:1:(x+halfwidthPX)));
                Hlineout=[zeros(1,halfwidthPX-x+1),Hlineout];
            elseif x+halfwidthPX>w
                Hlineout=mean(DToT((y-halfLineThicknessPX):1:(y+halfLineThicknessPX),(x-halfwidthPX):1:w));
                Hlineout=[Hlineout,zeros(1,x+halfwidthPX-w)];
            else
                Hlineout=mean(DToT((y-halfLineThicknessPX):1:(y+halfLineThicknessPX),(x-halfwidthPX):1:(x+halfwidthPX)));
            end
            figure(2)
            plot(((x-halfwidthPX):1:(x+halfwidthPX))*umPpx,Hlineout,'LineWidth',2.5)
            axis([(x-halfwidthPX)*umPpx (x+halfwidthPX)*umPpx -1.0 0.3])
           
           HLOs=[HLOs;Hlineout];

            % vertical lineout:
            if y-halfheightPX<1
                Vlineout=mean(DToT(1:1:(y+halfheightPX),(x-halfLineThicknessPX):1:(x+halfLineThicknessPX)),2);
                Vlineout=[zeros(halfheightPX-y+1,1);Vlineout];
            elseif y+halfheightPX>h
                Vlineout=mean(DToT((y-halfheightPX):1:h,(x-halfLineThicknessPX):1:(x+halfLineThicknessPX)),2);
                Vlineout=[Vlineout;zeros(y+halfheightPX-h,1)];
            else
                Vlineout=mean(DToT((y-halfheightPX):1:(y+halfheightPX),(x-halfLineThicknessPX):1:(x+halfLineThicknessPX)),2);
            end
            figure(3)
            plot(((y-halfheightPX):1:(y+halfheightPX))*umPpx,Vlineout,'LineWidth',2.5)
            axis([(y-halfheightPX)*umPpx (y+halfheightPX)*umPpx -1.0 0.3])
           
           VLOs=[VLOs,Vlineout];
           
           % find delay time from filename:
           dtInd=strfind(filename,'in_')+3; % filename string index at which delay time starts
           j=0;
           while ~isempty(str2num(filename(dtInd:dtInd+j))) % check each char in filename after dtInd until you reach the end of the delay time
               j=j+1;                                   
           end
           delays=vertcat(delays,[str2num(filename(dtInd:dtInd+j-1))]);
           
           close(f1);
       else
       end
    end
    % append delays array onto the data matrices:
    VLOs = [delays';VLOs];
    HLOs = [delays,HLOs];
    
    % sort matrices in acsending order of delays:
    VLOs=sortrows(VLOs')';
    HLOs=sortrows(HLOs);
    
    % save matrices to csv file:
    csvwrite([M7datSavePath,M7vertdatSaveFN],VLOs)
    csvwrite([M7datSavePath,M7horizdatSaveFN],HLOs)
end