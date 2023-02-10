close all
clear all

files=dir('DToTvsT_*FCP.mat');

traces=zeros(4,20,length(files));

for i=1:length(files)
    load(files(i).name);
    traces(:,:,i)=DToTvsTdat;
end

delaytimes=traces(1,:,1);

idx=[1 2 3 4 5 6 7];
figure(1)
for i=idx
%     plot(delaytimes,traces(2,:,i),'r-',delaytimes,traces(4,:,i),'r-',delaytimes,traces(3,:,i),'ko')
    plot(delaytimes,traces(3,:,i),'ko-')
    xlim([0 13])
    ylim([-1 0])
    hold on
end
set(gca,'fontsize',15)
hold off