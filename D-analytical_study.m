%% Fixed utilization, callbacks per chains, varying number of chains per chainset
clear all;
clc;
trials = 50;
num_chains = 4;
num_callbacks = 4;
cpu_util = 0.1;
var_period_test=[];
X = [];
num_chains_per_chainset = 1:1:12;
chainset_size_test = [];
util_chainset_size_test = [];
%i = 1;
util_test = 0.05:0.05:0.7;
for util = util_test
    parfor num_chains = num_chains_per_chainset
        %i = find(util_test, util, first);
        var_period_test = [];
        for trial = 1:1:trials
            test_config = [];
            chains_schedulable = [];
            deadlines = [];
            sched_percentage = [];
            schedulable = [];
            chain_period = [];
            for i = 1:num_chains
                period_rand = round(randi([100 1000]),-1);
                prio = 99-i;
                bucket = round((prio/17), 0);
                for j = 1:num_callbacks
                    if j == 1 % params
                        chain_config = [period_rand, period_rand*util/2/num_callbacks, ...
                            period_rand*util/2/num_callbacks, period_rand, i, j, prio, 2+mod(i,6), i , bucket];
                        chain_period = [chain_period; period_rand];
                    else
                        chain_config = [0,  period_rand*util/2/num_callbacks, ...
                            period_rand*util/2/num_callbacks, 0, i, j, prio, 2+mod(i,6), i , bucket];
                    end
                    test_config = [test_config; chain_config]; % update chain config list
                end
            end
            test_response_time = sched_calc(test_config); %calculate response time for this trial
            deadlines = nonzeros(test_config(:,1))'; % get deadlines for each chain
            schedulable = deadlines - test_response_time; % test to see if periods and deadlines align
            chains_schedulable = schedulable >= 0; % see if we meet  the deadlines
            sched_percentage = sum(nonzeros(chains_schedulable == 1),1)*100 / size(schedulable, 2); %Calculate percentage of chains schedulable
            sched_percentage = sched_percentage == 100;
            var_period_test = [var_period_test ; sched_percentage];
        end
        chainset_size_test(:,num_chains) =sum(var_period_test == 1, 1)*100 / size(var_period_test,1);
    end
    util_chainset_size_test = [util_chainset_size_test; chainset_size_test];
end
figure();
hold on;
for i = 1:length(util_test)/2
    plot(num_chains_per_chainset', util_chainset_size_test(2*i,:),'LineWidth',0.5);
end
legend("U=10%", "U=20%", "U=30%", "U=40%", "U=50%", "U=60%", "U=70%");
hold off;
xlabel("Number of Chains per Chainset");
ylabel("Percentage Schedulable");
xlim([1 12]);
ylim([0 100]);
grid minor;
fontsize(gcf,14,"points")


%% Varying percentage of gpu execution time
clear all;
clc;
trials = 50;
num_chains = 4;
num_callbacks = 4;
cpu_util = 0.1;
total_util = 0.20;
var_period_test=[];
X = [];
num_chains_per_chainset = 1:1:12;
chainset_size_test = [];
util_chainset_size_test = [];
%i = 1;
util_test = 0.05:0.05:0.7;
util_proportion = 0.05:0.05:1.0;
for util = util_proportion
    parfor k = 1:length(util_test) 
    total_util = util_test(k);
    var_period_test = [];
    for trial = 1:1:trials
        test_config = [];
        chains_schedulable = [];
        deadlines = [];
        sched_percentage = [];
        schedulable = [];
        chain_period = [];
        for i = 1:num_chains
            period_rand = round(randi([100 1000]),-1);
            temp_util = period_rand*total_util;
            prio = 99-i;
            bucket = round(prio/17, 0);
            for j = 1:num_callbacks
                if j == 1 % params
                    chain_config = [period_rand, temp_util*(1-util)/num_callbacks, ...
                        temp_util*util/num_callbacks, period_rand, i, j, prio, 2+mod(i, 6), i , bucket];
                    chain_period = [chain_period; period_rand];
                else
                    chain_config = [0,  temp_util*(1-util)/num_callbacks, ...
                        temp_util*util/num_callbacks, 0, i, j, prio, 2+mod(i,6), i , bucket];
                end
                test_config = [test_config; chain_config]; % update chain config list
            end
        end
        test_response_time = sched_calc(test_config); %calculate response time for this trial
        deadlines = nonzeros(test_config(:,1))'; % get deadlines for each chain
        schedulable = deadlines - test_response_time; % test to see if periods and deadlines align
        chains_schedulable = schedulable >= 0; % see if we meet  the deadlines
        sched_percentage = sum(nonzeros(chains_schedulable == 1),1)*100 / size(schedulable, 2); %Calculate percentage of chains schedulable
        sched_percentage = sched_percentage == 100;
        var_period_test = [var_period_test ; sched_percentage];
    end
    chainset_size_test(:,k)= sum(var_period_test == 1, 1)*100 / size(var_period_test,1);
    end
    util_chainset_size_test = [util_chainset_size_test; chainset_size_test];
end
figure();
hold on;
for i = 1:length(util_test)/2
plot(util_test'*100, util_chainset_size_test(2*i,:),'LineWidth',0.5);
end
legend("U=10%", "U=20%", "U=30%", "U=40%", "U=50%", "U=60%", "U=70%");
hold off;
xlabel("Ratio of GPU Utilization to CPU Utilization");
ylabel("Percentage Schedulable");
xticks([10 20 30 40 50 60 70]);
xticklabels( ["1:9", "2:8", "3:7", "4:6", "5:5", "6:4", "7:3"]);
xlim([10 70]);
ylim([0 100]);
grid minor;
fontsize(gcf,14,"points")


