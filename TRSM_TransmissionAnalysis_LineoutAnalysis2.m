clear all
close all

% DToT vs fluence vs delay time generated from VERTICAL lineouts, which are
% generated from TRSM_TransmissionAnalysis_FlattenedImageReader.m, through
% mode 7.
% 1) The TRSM lineouts are smoothed with a rolling average to get rid of
% high frequency noise;
% 2) a)The user is prompted to select what the center of each TRSM lineout
% is, which will then b)recenter the focal spot image position axis so that
% fluence values at each position in the TRSM lineout can be c) interpolated
% from the focal spot image vs position data.
% 3) The output is a 3-dim matrix of with each element indexed by (i,j,k)
% as follows:
% k = 1:
% .  j=  1    2    3    4    5 ...
% i=
% 1     t1   x11  x12  x13  x14  x15 ... (t1= delay(k=1), positions for delay t1)
% 1     t1   F11  F12  F13  F14  F15 ... (t1= delay(k=1), fluences for delay t1)
% 2     t1   T11  T12  T13  T14  T15 ... (t1= delay(k=1), DToT for delay t1)
%
% k =2:
% .  j=  1    2    3    4    5 ...
% i=
% 1     t2   x21  x22  x23  x24 ...
% 1     t2   F21  F22  F23  F24 ...
% 2     t2   T21  T22  T23  T24 ...
%

% focal spot vertical lineout:
fspath='C:\Users\Noah\Documents\OhioStateU\ChowdhuryResearchGroup\data\LIDT\SundaramSamples_Glass\ZnO\focalspots\2019_05_22\Lineouts\';
fsFN='focalSpot_7p775mmStagePos_10Hz_fcp_AfterRow4_CROPPED_rotated20deg_vert_horiz_Lineouts_1umThickInt.txt';
fsDat=csvread([fspath,fsFN]);
fsPos=fsDat(1,:);
dxfs=fsPos(2)-fsPos(1);
fs=fsDat(2,:);
fsN=length(fs);

% finite delay vertical lineouts of DToT images
path='C:\Users\Noah\Documents\OhioStateU\ChowdhuryResearchGroup\data\LIDT\SundaramSamples_Glass\ZnO\PumpProbe\2019_05_31\DToverTdata\mode7\';
Vfn='y9_DToTvsDelay_mode7_vertLineouts_0.1135umPpx_0.5umThickInt.txt';
VLOmat= csvread([path,Vfn]);

delays=VLOmat(1,:);
VLOmat=VLOmat(2:end,:);
N=length(VLOmat(:,1));

umPpx=str2num(Vfn(end-28:end-23));
pos = ((1:1:N)-N/2)*umPpx;

outputMat=zeros(3,N+1,length(delays));

% Npositions=11;
% dx=2; % um of spacing between probing positions
% dpx=round(dx/umPpx);
% SampPos=(0:1:Npositions-1)*dpx+round(N/2)-floor(Npositions/2)*dpx;


% Try centering the traces by smoothing them with a rolling average and then
% finding the position where the minimum occurs
% EDIT: this doesn't really work; the apparent center of the lineout after
% smoothing is still not "centered"
% EDIT (2020_05_21): I did notice that I could use a small averaging window
% to get rid of the high frequency noise, making the curve smooth without
% distorting it's shape.  I think I'll do this.

for m=1:length(delays)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 1) SMOOTH DToT LINEOUT:
    pxWind=8;
    VLOsmoothed1=VLOmat(:,m);
    for i=pxWind/2+1:length(VLOsmoothed1)-pxWind/2-1
        VLOsmoothed1(i)=mean(VLOsmoothed1((i-pxWind/2):(i+pxWind/2)));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 2a) CHOOSE CENTER OF DToT LINEOUT
    f1 = figure(3)
    plot(pos,VLOsmoothed1,'b')
    hold on

    % choose center of TRSM lineout
    [CenterPos, y]= getpts(f1);
%     xPx= round(CenterPos/umPpx)+round(N/2);
%     plot([pos(xPx) pos(xPx)],[-1.0 0],'r+-')
    hold off
    
    % 2b) RECENTER FOCAL SPOT LINEOUT
    % determine position corresponding to maximum fluence
    [fsMax, fsIndex]=max(fs);
    fsMaxPos=fsPos(fsIndex);

    % recenter focal spot position array to align the focal spot profile with
    % the TRSM image according to the center chosen above:
    % 1) first subtract fsMaxPos from fsPos so that x = 0 corresponds to the
    % max fluence value of the lineout, then
    % 2) add CenterPos to fsPos so that position associated with the center
    % chosen by eye also corresponds to the maximum fluence value
    fsPos=fsPos-fsMaxPos+CenterPos;

    % figure(4)
    % plot(pos,VLOsmoothed1,'b',fsPos,fs-1,'r')

    % 2c) RESAMPLE FOCAL SPOT LINEOUT:
    % Resample focal spot lineout with the position array associated with the
    % TRSM image:
    fluences=interp1(fsPos,fs,pos);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 3) STORE DATA IN OUTPUT MATRIX
    % store fluences, DToT values, and the associated delay time in the output
    % matrix:
    outputMat(:,:,m)=[[delays(m) pos];[delays(m) fluences];[delays(m) VLOsmoothed1']];
end

save([path,Vfn(1:3),'vertLineouts_position_fluence_DToT_time.mat'],'outputMat');



