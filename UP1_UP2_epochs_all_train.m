% Select which sleep epoch to analyze (1 = sleep1; 2 = sleep2; 3 = sleep3)
clear all;
ThPer = 60;
Epoch_Select = 3;
Run_Num = 10; %for the save filename
% Select which HMM file to load
dataset = '8482_15p';
cd(sprintf('E:/HMM - UP&Down/Soroush/Data/New_Result/%s', dataset));

filename = sprintf('E:/HMM - UP&Down/Soroush/Data/New_Result/%s/HMM_UPonly_all_train_2states_10_rep_run10_sleep3_Th%dMotionless.mat', dataset, ThPer);
% Select which epoch file to load
% epoch_file = 'sleep3_UP_epochs_run7.mat';
DurationLimit = 10;
load(filename,'Vit','UP_test', 'numNeurons');
load(sprintf('E:/HMM - UP&Down/Soroush/Data/New_Result/%s/ts.mat', dataset));
switch Epoch_Select
    case 1
        %         load(epoch_file, 'UP_test')
        load('sleep1_HMM_data.mat')
        savefile = ['sleep1_UP1_UP2_epochs_run',num2str(Run_Num),'.mat'];
        sleep_start = e.epochs.sleep1(1);
    case 2
        %         load(epoch_file, 'UP_test')
        savefile = ['sleep2_UP1_UP2_epochs_run',num2str(Run_Num),'.mat'];
        sleep_start = e.epochs.sleep2(1);
    case 3
        %         load(epoch_file, 'UP_test')
        load('sleep3_HMM_data.mat')
        savefile = ['sleep3_UP1_UP2_epochs_run',num2str(Run_Num),'_Th',num2str(ThPer),'Motionless.mat'];
        
        if exist('e','var')
            sleep_start = e.epochs.sleep3(1);
        else
            sleep_start = epochs.sleep3(1);
        end;
        
    otherwise
        error('Wrong Value for Epoch_select')
end

UP1 = [];
UP2 = [];
start_with_UP1 = 0;
start_with_UP2 = 0;
UP1_only = 0;
UP2_only = 0;

for i = 1:length(UP_test)
    
    state_seq = Vit{i};
    
    if isempty(state_seq)
        continue
    end
    
    state1 = state_seq == 1;
    state2 = state_seq == 2;
    
    UP1_diff = diff([0 state1 0]);
    UP2_diff = diff([0 state2 0]);
    
    UP1_start_idx = find(UP1_diff == 1);
    UP1_end_idx = find(UP1_diff == -1) - 1;
    UP2_start_idx = find(UP2_diff == 1);
    UP2_end_idx = find(UP2_diff == -1) - 1;
    
    
    
    UP1_temp = [];
    UP2_temp = [];
    
    if ~isempty(UP1_start_idx) && ~isempty(UP2_start_idx)
        if state_seq(6) == 1
            start_with_UP1 = start_with_UP1 + 1;
        else
            start_with_UP2 = start_with_UP2 + 1;
        end
    end
    
    if isempty(UP1_start_idx)
        UP2_only = UP2_only +1;
    elseif isempty(UP2_start_idx)
        UP1_only = UP1_only +1;
    end
    
    for ii = 1:length(UP1_start_idx)
        UP1_temp(ii,1) = UP_test(i,1) + UP1_start_idx(ii) - 1;
        UP1_temp(ii,2) = UP_test(i,1) + UP1_end_idx(ii) - 1;
    end
    
    for iii = 1:length(UP2_start_idx)
        UP2_temp(iii,1) = UP_test(i,1) + UP2_start_idx(iii) - 1;
        UP2_temp(iii,2) = UP_test(i,1) + UP2_end_idx(iii) - 1;
    end
    
    UP1 = [UP1;UP1_temp];
    UP2 = [UP2;UP2_temp];
end


UP1_dur = UP1(:,2)-UP1(:,1);
idx3 = find(UP1_dur < DurationLimit);
UP1(idx3,:) = [];
UP1_dur(UP1_dur < DurationLimit) = [];
%UP1_dur(find(UP1_dur < 5 )) = [];
UP2_dur = UP2(:,2)-UP2(:,1);
idx4 = find(UP2_dur < DurationLimit);
UP2(idx4,:) = [];
UP2_dur(UP2_dur < DurationLimit) = [];

UP1_full = ((UP1*10) + sleep_start);
UP2_full = ((UP2*10) + sleep_start);

% Added by Soroush

UP1_epochs = UP1;
UP2_epochs = UP2;

UP1_spikes = cell(length(UP1_epochs),1);
for i = 1:length(UP1_epochs)
    UP1_spikes{i} = times(times > UP1_epochs(i,1) & times < UP1_epochs(i,2));
    A_UP1(i) = length(UP1_spikes{i})*1000/UP1_dur(i);
    %A_UP1(i) = length(UP1_spikes{i});
end
UP1_spikes_mat = cell2mat(UP1_spikes);
UP1_spikes_tot = length(UP1_spikes_mat);
%AA_UP1 = A_UP1';
%AA_UP1(idx3,:) = [];

UP2_spikes = cell(length(UP2_epochs),1);
for i = 1:length(UP2_epochs)
    UP2_spikes{i} = times(times > UP2_epochs(i,1) & times < UP2_epochs(i,2));
    A_UP2(i) = length(UP2_spikes{i})*1000/UP2_dur(i);
    % A_UP2(i) = length(UP2_spikes{i});
    
end
UP2_spikes_mat = cell2mat(UP2_spikes);
UP2_spikes_tot = length(UP2_spikes_mat);

%AA_UP2=A_UP2';
%AA_UP2(idx4, :) = [];



figure;
min=0;

A_UP_Tot = [A_UP1/numNeurons, A_UP2/numNeurons];
UP_Duration_Tot = [UP1_dur; UP2_dur];
edgesx1= [0:.4:max(A_UP_Tot)];
edgesx2= [0:.025:max(UP_Duration_Tot/1000)];

axax1=subplot(1,2,1);


H1 = histogram(UP1_dur/1000, edgesx2);
MaxHistogram1 = max(H1.Values);
title('Distribution of UP Type1', 'fontsize' ,12);
xlabel('UP Type1 Duration(s)','fontsize', 12);
ylabel('Number of UP Type1','fontsize', 12);
Mean_UP1_Dur = mean(UP1_dur/1000)
%ylim([min max(MaxHistogram1,MaxHistogram2)]);

hold on;

    
axax2=subplot(1,2,2);

H2 = histogram(UP2_dur/1000, edgesx2);
MaxHistogram2= max(H2.Values);
title('Distribution of UP Type2', 'fontsize' ,12);
xlabel('UP Type2 Duration(s)','fontsize', 12);
ylabel('Number of UP Type2','fontsize', 12);
Mean_UP2_Dur = mean(UP2_dur/1000)
%ylim([min MaxHistogram1]);
linkaxes([axax1, axax2], 'xy');

% % % % % saveas(gcf, ['TwoUPsDistribution_Extra' num2str(Epoch_Select) '_Th' num2str(ThPer) 'Motionless.fig' ]);

figure;
axcd1 = subplot(1,2,1);


H3 = histogram(A_UP1/numNeurons, edgesx1);
MaxHistogram3 = max(H3.Values);
title('Firing rate of UP Type1', 'fontsize' ,12);
xlabel('Firing rate (Hz)','fontsize', 12);
ylabel('Number of UP Type1','fontsize', 12);
Mean_A_UP1 = mean(A_UP1/numNeurons)
%%%ylim([min max(MaxHistogram3,MaxHistogram4)]);
SEM_UP1_FiringRate = std(A_UP1/numNeurons)/ sqrt(length(A_UP1/numNeurons))




hold on;

axcd2 = subplot(1,2,2);

H4 = histogram(A_UP2/numNeurons, edgesx1);
MaxHistogram4= max(H4.Values);
title('Firing rate of UP Type2', 'fontsize' ,12);
xlabel('Firing rate (Hz)','fontsize', 12);
ylabel('Number of UP Type2','fontsize', 12);
Mean_A_UP2 = mean(A_UP2/numNeurons)
%%%%%%ylim([min MaxHistogram4]);
SEM_UP2_FiringRate = std(A_UP2/numNeurons)/ sqrt(length(A_UP2/numNeurons))

linkaxes([axcd1, axcd2], 'xy');


% % % % saveas(gcf, ['TwoUPsSpikesNumber_Extra_Sleep' num2str(Epoch_Select) '_Th' num2str(ThPer) 'Motionless.fig']);



[p1, h1] = ranksum (UP1_dur, UP2_dur);
[p2,h2] = ranksum(A_UP1', A_UP2');

UPsEquall = padcat(UP1_dur/1000, UP2_dur/1000);
UPsEquallUP1 = UPsEquall(1:end,1);
UPsEquallUP2 = UPsEquall(1:end,2);

% % % % % % % % % % % % % % % % %  figure;
% % % % % % % % % % % % % % % % %  p11 = ranksum(UPsEquallUP1, UPsEquallUP2);
% % % % % % % % % % % % % % % % %  [pp1, tbl1, stats1] = ranksum(UPsEquallUP1, UPsEquallUP2, 'off');
% % % % % % % % % % % % % % % % %  title('kruskalwallis cluster differences for UPs duration', 'fontsize' ,14);
% % % % % % % % % % % % % % % % %  xlabel('Number of UPs states','fontsize', 14);
% % % % % % % % % % % % % % % % %  ylabel('UPs distribution','fontsize', 14);
% % % % % % % % % % % % % % % % %  saveas(gcf, 'kruskalwallisClusterDifferencesTwoUPsDurationDistribution.fig');
% % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % %  figure;
% % % % % % % % % % % % % % % % %  c1 = multcompare(stats1);
% % % % % % % % % % % % % % % % %  title('kruskalwallis cluster differences for UPs duration', 'fontsize' ,14);
% % % % % % % % % % % % % % % % %  ylabel('Number of UPs states','fontsize', 14);
% % % % % % % % % % % % % % % % %  saveas(gcf, 'kruskalwallisClusterDifferencesTwoUPsDuration.fig');
% % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % %   
% % % % % % % % % % % % % % % % %  figure;
% % % % % % % % % % % % % % % % %   p22 = ranksum(padcat(A_UP1'/numNeurons, A_UP2'/numNeurons));
% % % % % % % % % % % % % % % % %  [pp2, tbl2, stats2] = ranksum(padcat(A_UP1'/numNeurons, A_UP2'/numNeurons), [], 'off');
% % % % % % % % % % % % % % % % %  title('kruskalwallis cluster differences for UPs firing rate', 'fontsize' ,14);
% % % % % % % % % % % % % % % % %  xlabel('Number of UPs states','fontsize', 14);
% % % % % % % % % % % % % % % % %  ylabel('UPs distribution','fontsize', 14);
% % % % % % % % % % % % % % % % %  saveas(gcf, 'kruskalwallisClusterDifferencesTwoUPsFiringRateDistribution.fig');
% % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % %  figure;
% % % % % % % % % % % % % % % % %  c2 = multcompare(stats2);
% % % % % % % % % % % % % % % % %  title('kruskalwallis cluster differences for UPs firing rate', 'fontsize' ,14);
% % % % % % % % % % % % % % % % %  ylabel('Number of UPs states','fontsize', 14);
% % % % % % % % % % % % % % % % %  saveas(gcf, 'kruskalwallisClusterDifferencesTwoUPFiringRates.fig');
% % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % %
% % % % % save(savefile,'UP1','UP1_full','UP1_dur','A_UP1','A_UP2','UP2','UP2_dur','UP2_full','filename','start_with_UP1','start_with_UP2','UP1_only','UP2_only')