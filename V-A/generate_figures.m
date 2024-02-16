clear all;
close all;
clc;
filedir = pwd;
files = dir(convertCharsToStrings(filedir)) ;
filenames = {files.name};
filenames = string(filenames);
paam_files_mb = filenames(contains(filenames, "paam_trace_mb.txt"));
direct_files = filenames(contains(filenames, "direct_trace.txt"));
np_direct_files = filenames(contains(filenames, "picas"));

paam_chain_history_mb = cell(1,1);
direct_chain_history = cell(1,1);
direct_chain_history_np = cell(1,1);

for i = 1:length(paam_files_mb)

    paam_chain_mb = importfile(paam_files_mb(i));
    paam_chain_latency_mb(i) = mean(table2array(paam_chain_mb(:,2)));
    paam_chain_latency_99_mb(i) = prctile(table2array(paam_chain_mb(:,2)),99);
    paam_chain_history_mb(i) = {paam_chain_mb};
    
    direct_chain = importfile(direct_files(i));
    direct_chain_latency(i) = mean(table2array(direct_chain(:,2)));
    direct_chain_latency_99(i) = prctile(table2array(direct_chain(:,2)),99);
    direct_chain_history(i) = {direct_chain};
    
    no_picas_chain = importfile(np_direct_files(i));
    no_picas_chain_latency(i) = mean(table2array(no_picas_chain(:,2)));
    no_picas_chain_latency_99(i) = prctile(table2array(no_picas_chain(:,2)),99);
    direct_chain_history_np(i) = {no_picas_chain};
end

% multiple buckets: 
% see the last column; chains 1 & 2 share the same bucket 0
data = [120 2 10 120 1 1 98 2 1 0;
          0 6 10   0 1 2 99 2 1 0; 
        120 2 10 120 2 1 95 3 2 0;
          0 8 10   0 2 2 96 3 2 0;
          0 9 10   0 2 3 97 3 2 0;
        220 6 10 220 3 1 91 4 3 1;
          0 8 10   0 3 2 92 4 3 1;
          0 4 10   0 3 3 93 4 3 1;
          0 8 10   0 3 4 94 4 3 1;
        260 5 10 260 4 1 88 5 4 2;
          0 7 10   0 4 2 89 5 4 2;
          0 2 10   0 4 3 90 5 4 2;
        320 2 10 320 5 1 85 6 5 3;
          0 1 10   0 5 2 86 6 5 3;
          0 7 10   0 5 3 87 6 5 3;
        360 2 10 360 6 1 83 7 6 4;
          0 7 10   0 6 2 84 7 6 4;
        120 2 10 120 7 1  0 6 7 5
          0 6 10   0 7 2  0 6 7 5
        220 6 10 220 8 1  0 7 8 5
          0 8 10   0 8 2  0 7 8 5
          0 4 10   0 8 3  0 7 8 5
          0 8 10   0 8 4  0 7 8 5
    ];

num_executors = max(data(:,9));
num_cpus = max(data(:,8));

num_chains = max(data(:, 5));
num_tasks = size(data, 1);

% Initialize cpus
for c = 1 : num_cpus
    cpus(c) = Cpu(c);
end

% Initialize executors
for e = 1 : num_executors
    executors(e) = Executor(e);
end

% Initialize callbacks & chains
chains = []; chain_idx = 0;
for c = 1 : size(data, 1)
    callbacks(c) = Callback(c, data(c, 1), data(c, 2), data(c, 3), data(c, 5), data(c, 6), data(c, 7), data(c, 8), data(c, 9), data(c, 10));
    callbacks(c).chain_on_cpu = true;
    callback_prio = data(c, 7);
    if length(chains) < callbacks(c).chain_id
        chain_idx = chain_idx+ 1;
        chains = [chains Chain(chain_idx, callback_prio)];
    end
    chains(callbacks(c).chain_id) = chains(callbacks(c).chain_id).add_callback(callbacks(c));
end

for ch = 1 : length(chains)
    for c = 1 : length(chains(ch).t_callback)
        cpu_id = chains(ch).t_callback(c).cpu;
        executor_id = chains(ch).t_callback(c).executor;
        executors(executor_id) = executors(executor_id).add_callbacks(chains(ch).t_callback(c));
    end
    for c = 1 : length(chains(ch).r_callbacks)
        cpu_id = chains(ch).r_callbacks(c).cpu;
        executor_id = chains(ch).r_callbacks(c).executor;
        executors(executor_id) = executors(executor_id).add_callbacks(chains(ch).r_callbacks(c));
    end
end

for e = 1 : length(executors)
    cpu_id = executors(e).cpu;
    cpus(cpu_id) = cpus(cpu_id).assign_executor(executors(e));
end

[chains, latency] = response_time_callbacks(chains, cpus);
latency(1,7:8) = 0;

direct_chain_distr_np = vertcat(direct_chain_history_np{:});
d1_method=cell(height(direct_chain_distr_np), 1);
direct_chain_distr = vertcat(direct_chain_history{:});
d2_method=cell(height(direct_chain_distr), 1);
%paam_chain_distr = vertcat(paam_chain_history{:});
%d3_method=cell(height(paam_chain_distr), 1);
paam_chain_distr_mb = vertcat(paam_chain_history_mb{:});
d4_method=cell(height(paam_chain_distr_mb), 1);
d1_method(:) = {'ROS2-1'};
d2_method(:) = {'ROS2-2'};
%d3_method(:) = {'ROS2-3'};
d4_method(:) = {'ROS2-4'};
chainOrder = unique(direct_chain_distr_np.init)';

Chain = [cellstr(string(table2cell(direct_chain_distr_np(:,1)))); ...
    cellstr(string(table2cell(direct_chain_distr(:,1)))); ...
    %cellstr(string(table2cell(paam_chain_distr(:,1)))); ...
    cellstr(string(table2cell(paam_chain_distr_mb(:,1))))];% dummy_chain'; dummy_chain'];
Latency = [table2array(direct_chain_distr_np(:,2)); ...
    table2array(direct_chain_distr(:,2)); ...
    %table2array(paam_chain_distr(:,2)); ...
    table2array(paam_chain_distr_mb(:,2))]/1000;

%Method = [d1_method; d2_method; d3_method; d4_method];%
Method = [d1_method; d2_method; d4_method];%
T = table(Chain, Method, Latency);
chainOrder= cellstr(chainOrder);

T.Chain = categorical(T.Chain, chainOrder);

figure(); hold on;
colormap lines
b = boxchart(T.Chain, T.Latency, 'GroupbyColor', T.Method, 'MarkerStyle', 'o', 'BoxFaceAlpha', 0.4, 'LineWidth', 0.5, 'MarkerSize', 4);
%h = findobj(b, 'Marker','*')
%set(h,'LineWidth',0.1)
%b(3).BoxFaceColor = [0.4940 0.1840 0.5560];
%b(3).MarkerColor = [0.4940 0.1840 0.5560];
ylim([0 400]);
ax = gca;
ax.XTickLabel = {'Chain 1', 'Chain 2', 'Chain 3', 'Chain 4', 'Chain 5', 'Chain 6', 'BE 1', 'BE 2'};
ax.YGrid = 'on';
yticks([0 50 100 150 200 250 300 350 400]);
fontsize(14, "points")
%set(gca, 'FontName', 'Times New Roman', 'FontSize', 20);
%set(gca, 'Position', [0.045 0.08 0.94 0.88]);
%set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 0.50]);
ylabel('End-to-end latency (ms)');

bar_analy = zeros(5, 8);
bb = bar(categorical(chainOrder), bar_analy, 0.5);
bb(4).FaceColor = [0.4940 0.1840 0.5560];
bb(4).FaceAlpha = 0.5;
bb(5).FaceColor = [0.39,0.83,0.07];
bb(5).FaceAlpha = 0.5;
%ylim([0,300])
ylim([0,250])
%legend('PAAM (single queue)   ', 'PAAM Chains (multiple queue)   ', 'Direct Chains (PiCAS Executor)   ', 'Direct Chains (ROS 2 Executor)'   );
%lgd = legend('ROS 2', 'PiCAS', 'PAAM-S', 'PAAM');
lgd = legend('ROS 2', 'PiCAS', 'PAAM');
%lgd.NumColumns = 4;
lgd.NumColumns = 3;
lgd.Location = 'northwest'

%fontsize(gcf,12,"points"); % for wide version
fontsize(gcf,11,"points");
fontsize(lgd,10,"points");
%fig_width = 14; fig_height = 3.4; % in inches, doubled (for wide version)
fig_width = 6.8; fig_height = 3.4; % in inches, doubled
set(gcf,'Units','inches');
set(gcf,'Position',[0 0 fig_width fig_height]);
ax = gca;
ax.LineWidth = 0.5;
ax.GridLineWidth = 0.05;
outerpos = get(ax,'OuterPosition');
ti = get(ax,'TightInset');
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
set(ax,'Position',[left bottom ax_width ax_height]);
set(gcf,'Position',[0 0 fig_width fig_height]);
screenposition = get(gcf,'Position')
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],'PaperSize',[screenposition(3:4)])
%print -dpdf -painters rtas-tc-avg-v2-1
print -dpdf -painters rtas-tc-avg-v2-1-narrow

hold off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h=figure();
hold on;
x = 1:num_chains;
%y = [paam_chain_latency_99./1000; latency_single;  paam_chain_latency_99_mb./1000; latency ; direct_chain_latency_99./1000; no_picas_chain_latency_99./1000];
%y = [no_picas_chain_latency_99./1000; direct_chain_latency_99./1000; paam_chain_latency_99./1000; latency_single;  paam_chain_latency_99_mb./1000; latency];
y = [no_picas_chain_latency_99./1000; direct_chain_latency_99./1000; paam_chain_latency_99_mb./1000; latency];
bb = bar(x,y, 'LineWidth', 0.5)
%bb.FaceAlpha = 0.4;

%xlabel("Chain");
xticklabels({'Chain 1','Chain 2','Chain 3', 'Chain 4', 'Chain 5', 'Chain 6', 'BE 1', 'BE 2'})
ylabel("End-to-end latency (ms)");
%lgd = legend({"PAAM (single queue)", "Analytical Bound (single queue)", "PAAM (multiple queue)" , "Analytical Bound (multiple queue)", "Direct Invocation (PiCAS Executor)", "Direct Invocation (ROS 2 Executor)"}, 'NumColumns',3)
%lgd = legend({"ROS 2     ", "PiCAS      ", "PAAM-S", "PAAM-S (analysis)", "PAAM" , "PAAM (analysis)", }, 'NumColumns',3)
lgd = legend({"ROS 2     ", "PiCAS      ", "PAAM" , "Analysis", }, 'NumColumns',3)
%lgd.NumColumns = 6; % for wide version
%lgd.NumColumns = 3;
lgd.NumColumns = 4;
lgd.Location = 'northwest'
%title("Worst Case Latency Comparison For Case Study")
fontsize(14,"points")
%grid minor;
%ylim([0, 400])
ylim([0, 350])

%fontsize(gcf,12,"points"); % for wide version
fontsize(gcf,11,"points");
fontsize(lgd,10,"points");
%fig_width = 14; fig_height = 3.4; % in inches, doubled (for wide version)
fig_width = 6.8; fig_height = 3.4; % in inches, doubled
set(gcf,'Units','inches');
set(gcf,'Position',[0 0 fig_width fig_height]);
ax = gca;
ax.LineWidth = 0.5;
ax.GridLineWidth = 0.05;
outerpos = get(ax,'OuterPosition');
ti = get(ax,'TightInset');
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
set(ax,'Position',[left bottom ax_width ax_height]);
set(gcf,'Position',[0 0 fig_width fig_height]);
screenposition = get(gcf,'Position')
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],'PaperSize',[screenposition(3:4)])
%print -dpdf -painters rtas-tc6-wc-v2-2
print -dpdf -painters rtas-tc6-wc-v2-2-narrow

hold off;
