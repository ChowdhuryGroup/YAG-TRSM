% Takes the outputMat.mat files generated from
% TRSM_TransmissionAnalysis_LineoutAnalysis2.m, and generates DToT vs.
% Fluence data at a chosen time delay for each tested fluence (i.e. each
% row in the experiment).  The fluences at which DToT is determined are
% chosen by the user, and it is recommended to use large increments in
% fluence since the fluence at which a value of DToT is calculated is
% determined by proximity to the fluence array associated with focal spot
% lineout.  This way, "stairstepping" of the DToT vs fluence curve is
% avoided.
% DToT vs fluence relative to ablation threshold is also generated


clear all
close all

path='C:\Users\Noah\Documents\OhioStateU\ChowdhuryResearchGroup\data\LIDT\SundaramSamples_Glass\ZnO\PumpProbe\2019_05_31\DToverTdata\mode7\';
fnStartIndex=5; % Some data sets start are a grid that was already started previously (e.g. first row for 110 fs shots is actually y5 since the grid was started using FCPs)

Fth=2.14; % ablation threshold fluence
F0=[4.52 2.92 3.65 4.83 3.96]; % tested peak fluences; the order is the same as the order of the rows

Sampfluences=(0.1:0.025*Fth:8.0); % sampling fluences where DToT is to be evaluated

allDat=cell(1,5); % each element of this cell is an outputMat 3dimensional matrix (associated with each row)
allDToTvst=cell(1,5); % each element of this cell is a 2D matrix of DToT values, where rows correspond to sample fluences, and columns correspond to delay times
FlsThen=cell(1,5); %since the Sampfluences maximum is larger than the tested fluences to varying degrees, each element of this cell is a logic array determining which fluences in SampFluences are smaller than the corresponding tested fluence.

for n=1:5
    %load outputMat file associated to row n:
    load([path,'y',num2str(n-1+fnStartIndex),'_vertLineouts_position_fluence_DToT_time.mat']);
    
    %renormalize fluences so that peak fluence corresponds to the test peak
    %fluence for row n:
    outputMat(2,2:end,:)=F0(n)*outputMat(2,2:end,:)/max(outputMat(2,2:end,1));
    allDat{n}=outputMat;
    
    %since the number of shots per row can vary, we must extract the delays
    %for each row so that the DToTvstime has the correct number of columns
    delays=outputMat(1,1,:);
    
    %Determine which samplefluences are less than or equal to the test
    %fluence for row n:
    FlsThen{n}=Sampfluences<=F0(n);
    
    % initialize DToTvstime matrix (DToT values at each sample fluence, and
    % for each delay)
    DToTvstime=zeros(sum(FlsThen{n}),length(delays));
    
    % For each sample fluence, there are two DToT values, since there are
    % two positions along the focal spot lineout that have the same
    % fluence, on either side of the peak.  Therefore, we determine the
    % indices of the focal spot lineout that correspond to the two
    % closest values in that array to each sampfluence value that is below
    % the test peak fluence for row n.  The DToT value associated with a
    % given sampfluence is the average of the two DToT values associated
    % with each side of the focal spot.  
    for i=1:sum(FlsThen{n})
        for j=1:length(delays)
            delay=outputMat(1,1,j);
            f=outputMat(2,2:end,j);
            DToT=outputMat(3,2:end,j);

            [array, idx2]=sort(abs(Sampfluences(i)-f));

            DToTvstime(i,j)=mean(DToT(idx2(1:2)));
        end
    end
    allDToTvst{n}=DToTvstime;
end

% Choose a time at which you want to look at fluence scaling
idx=zeros(1,5);
time=0.67;
% Determine index of the delay array for each row that corresponds to the
% delay time that is closest to the chosen time.
allDelays=cell(1,5); % each element of this cell is the array of time delays for each tested row.
for i=1:5
    delays = allDat{i}(1,1,:);
    [val, idx(i)]=min(abs(delays-time));
    allDelays{i}=delays;
end

% figure(2)
% plot(permute(delays,[3 2 1]),DToTvstime)
% 
% figure(3)
% surf(DToTvstime)

% Plot fluence vs DToT for each row on the same plot
colors={'k.-','g.-','r.-','b.-','m.-'};
figure(1)
for i=1:5
    plot(Sampfluences(FlsThen{i}),allDToTvst{i}(:,idx(i)),colors{i})
    hold on
end
plot([Fth Fth],[-1.0 0],'b-')
hold off

% Plot fluence vs DToT for a single row:
rowNumber=7; %This is the y# that can be found in the data spreadsheets
figure(4)
plot(Sampfluences(FlsThen{rowNumber-fnStartIndex+1})/Fth,allDToTvst{rowNumber-fnStartIndex+1}(:,idx(rowNumber-fnStartIndex+1)),'r.-',[Fth Fth]/Fth,[-1.0 0],'b-')
xlim([0.6 1.4])
% 
% figure(5)
% plot(outputMat(1,2:end,idx),(outputMat(2,2:end,idx)/F0)-1,'r',outputMat(1,2:end,idx),outputMat(3,2:end,idx),'b')

% save Sampfluences, FlsThen, allDToTvst, and allDelays to a .mat file if
% you choose to:
str=input('Save data to disc? y/n: ', 's');
if str == 'y'
    finDat={Sampfluences,FlsThen,allDToTvst,allDelays};
    save([path(1:end-6),'DToTvsFluenceScaling\','DToTvsF_allrows.mat'],'finDat');
elseif str== 'n'
    disp('rerun program with new settings');
else
    disp('incorrect input; rerun program');
end
        
        
        