clear all;
close all;
clc;

filedir = pwd;
files = dir(convertCharsToStrings(filedir)) ;
filenames = {files.name};
filenames = string(filenames);
multithreaded_files = filenames(contains(filenames, "multithreaded"));
singlethreaded_me_files = filenames(contains(filenames, "singlethreaded_me"));
tests = {'hot path latency', 'behavior planner period', 'hot path drops'};

singlethreaded_table = table;
for i = 1:length(singlethreaded_me_files)
    filelog = importfile(singlethreaded_me_files(i));
    latency = filelog(filelog.Statistics=="hot path latency", :);
    drops = filelog(filelog.Statistics=="hot path drops", :);
    period = filelog(filelog.Statistics=="behavior planner period",:);
    latency_name = table2array(latency(100:end, "Statistics"));
    period_name = table2array(period(100:end, "Statistics"));
    drop_name = table2array(drops(100:end, "Statistics"));

    latency_data = table2array(latency(100:end, "data"));
    period_data = table2array(period(100:end, "data"));
    drop_data = table2array(drops(100:end, "data"));

    data = [latency_data; period_data; drop_data];
    names = [latency_name; period_name; drop_name];
    testnames = names;
    testnames(:,1) = singlethreaded_me_files(i);
    graphtable = table(names, data, testnames);
    graphtable.names = categorical(graphtable.names, tests);
    singlethreaded_table = [singlethreaded_table; graphtable];
end

multithreaded_table = table;
for i = 1:length(multithreaded_files)
    filelog = importfile(multithreaded_files(i));
    latency = filelog(filelog.Statistics=="hot path latency", :);
    drops = filelog(filelog.Statistics=="hot path drops", :);
    period = filelog(filelog.Statistics=="behavior planner period",:);
    latency_name = table2array(latency(100:end, "Statistics"));
    period_name = table2array(period(100:end, "Statistics"));
    drop_name = table2array(drops(100:end, "Statistics"));
    latency_data = table2array(latency(100:end, "data"));
    period_data = table2array(period(100:end, "data"));
    drop_data = table2array(drops(100:end, "data"));

    data = [latency_data; period_data; drop_data];
    names = [latency_name; period_name; drop_name];
    testnames = names;
    testnames(:,1) = multithreaded_files(i);
    graphtable = table(names, data, testnames);
    graphtable.names = categorical(graphtable.names, tests);
    multithreaded_table = [multithreaded_table; graphtable];
end

latency_name = {'hot path latency'};
latency_table = [multithreaded_table(multithreaded_table.names=="hot path latency",:); singlethreaded_table(singlethreaded_table.names=="hot path latency",:)];
latency_table.names = categorical(latency_table.names, latency_name);
executor = table(latency_table.testnames);
for i = 1:height(executor)
    if contains(string(executor.Var1(i)), "singlethreaded")
        executor.Var1(i) = categorical("4xST");
    elseif contains(string(executor.Var1(i)), "multithreaded")
        executor.Var1(i) = categorical("MT");
    end
end
grouporder = table(latency_table.testnames);
for (i = 1:height(grouporder))
    if contains(string(grouporder.Var1(i)),"di_no_picas")
        grouporder.Var1(i) = categorical("Direct Invocation");
    elseif contains(string(grouporder.Var1(i)),"di_picas")
        grouporder.Var1(i) = categorical("PiCAS");
    elseif contains(string(grouporder.Var1(i)),"aamf")
        grouporder.Var1(i) = categorical("AAMF");
    end
end
grouporder = table(categorical(grouporder.Var1, {'Direct Invocation', 'PiCAS', 'AAMF'}));
executor.Var1 = categorical(executor.Var1, {'4xST', 'MT'});

figure();
hold on;
%h1 = boxchart(executor.Var1(executor.Var1 == categorical({'Multithreaded'})), latency_table.data(executor.Var1 == categorical({'Multithreaded'}), :), 'GroupByColor', grouporder.Var1(executor.Var1 == categorical({'Multithreaded'})));
%h2 = boxchart(executor.Var1(executor.Var1 == categorical({'Singlethreaded'})), latency_table.data(executor.Var1 == categorical({'Singlethreaded'}), :), 'GroupByColor', grouporder.Var1(executor.Var1 == categorical({'Singlethreaded'})));
b = boxchart(executor.Var1(:), latency_table.data(:), 'GroupbyColor', grouporder.Var1(:), 'MarkerStyle', 'o', 'BoxFaceAlpha', 0.4, 'LineWidth', 0.5, 'MarkerSize', 4);
fontsize(7, 'points')
lgd = legend(["ROS 2", "PiCAS", "AAMF"])
ylabel("Hot Path Latency (ms in logscale)")
grid minor
set(gca, 'YScale', 'log')
ylim([0, 1600])
yticks([0 100 200 400 800 1600]);

fontsize(gcf,12,"points");
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
print -dpdf -painters autoware_latency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

period_name = {'behavior planner period'};
period_table = [multithreaded_table(multithreaded_table.names=="behavior planner period",:); singlethreaded_table(singlethreaded_table.names=="behavior planner period",:)];
period_table.names = categorical(period_table.names, period_name);
executor = table(period_table.testnames);
for i = 1:height(executor)
    if contains(string(executor.Var1(i)), "singlethreaded")
        executor.Var1(i) = categorical("4xST");
    elseif contains(string(executor.Var1(i)), "multithreaded")
        executor.Var1(i) = categorical("MT");
    end
end
grouporder = table(period_table.testnames);
for (i = 1:height(grouporder))
    if contains(string(grouporder.Var1(i)),"di_no_picas")
        grouporder.Var1(i) = categorical("Direct Invocation");
    elseif contains(string(grouporder.Var1(i)),"di_picas")
        grouporder.Var1(i) = categorical("PiCAS");
    elseif contains(string(grouporder.Var1(i)),"aamf")
        grouporder.Var1(i) = categorical("AAMF");
    end
end
grouporder = table(categorical(grouporder.Var1, {'Direct Invocation', 'PiCAS', 'AAMF'}));
%executor.Var1 = categorical(executor.Var1, {'Multithreaded', 'Singlethreaded'});
executor.Var1 = categorical(executor.Var1, {'4xST', 'MT'});
figure();
hold on;
%h1 = boxchart(executor.Var1(executor.Var1 == categorical({'Multithreaded'})), period_table.data(executor.Var1 == categorical({'Multithreaded'}), :), 'GroupByColor', grouporder.Var1(executor.Var1 == categorical({'Multithreaded'})));
%h2 = boxchart(executor.Var1(executor.Var1 == categorical({'Singlethreaded'})), period_table.data(executor.Var1 == categorical({'Singlethreaded'}), :), 'GroupByColor', grouporder.Var1(executor.Var1 == categorical({'Singlethreaded'})));
b = boxchart(executor.Var1(:), period_table.data(:), 'GroupbyColor', grouporder.Var1(:), 'MarkerStyle', 'o', 'BoxFaceAlpha', 0.4, 'LineWidth', 0.5, 'MarkerSize', 4);
fontsize(14, 'points')
legend(["ROS 2", "PiCAS", "AAMF"])
ylabel("Period (ms)")
grid minor
ylim([0, 300])

fontsize(gcf,12,"points");
fig_width = 3.35; fig_height = 3.4; % in inches, doubled
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
print -dpdf -painters bh_period
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

drops_name = {'hot path drops'};
drops_table = [multithreaded_table(multithreaded_table.names=="hot path drops",:); singlethreaded_table(singlethreaded_table.names=="hot path drops",:)];
drops_table.names = categorical(drops_table.names, drops_name);
executor = table(drops_table.testnames);
for i = 1:height(executor)
    if contains(string(executor.Var1(i)), "singlethreaded")
        executor.Var1(i) = categorical("4xST");
    elseif contains(string(executor.Var1(i)), "multithreaded")
        executor.Var1(i) = categorical("MT");
    end
end
grouporder = table(drops_table.testnames);
for (i = 1:height(grouporder))
    if contains(string(grouporder.Var1(i)),"di_no_picas")
        grouporder.Var1(i) = categorical("Direct Invocation");
    elseif contains(string(grouporder.Var1(i)),"di_picas")
        grouporder.Var1(i) = categorical("PiCAS");
    elseif contains(string(grouporder.Var1(i)),"aamf")
        grouporder.Var1(i) = categorical("AAMF");
    end
end
grouporder = table(categorical(grouporder.Var1, {'Direct Invocation', 'PiCAS', 'AAMF'}));
%executor.Var1 = categorical(executor.Var1, {'Multithreaded', 'Singlethreaded'});
executor.Var1 = categorical(executor.Var1, {'4xST', 'MT'});
figure();
hold on;
%h1 = boxchart(executor.Var1(executor.Var1 == categorical({'Multithreaded'})), drops_table.data(executor.Var1 == categorical({'Multithreaded'}), :), 'GroupByColor', grouporder.Var1(executor.Var1 == categorical({'Multithreaded'})));
%h2 = boxchart(executor.Var1(executor.Var1 == categorical({'Singlethreaded'})), drops_table.data(executor.Var1 == categorical({'Singlethreaded'}), :), 'GroupByColor', grouporder.Var1(executor.Var1 == categorical({'Singlethreaded'})));
b = boxchart(executor.Var1(:), drops_table.data(:), 'GroupbyColor', grouporder.Var1(:), 'MarkerStyle', 'o', 'BoxFaceAlpha', 0.4, 'LineWidth', 0.5, 'MarkerSize', 4);
fontsize(14, 'points')
legend(["ROS 2", "PiCAS", "AAMF"])
ylabel("Drops")
grid minor
ylim([0, 5])

fontsize(gcf,12,"points");
fig_width = 3.35; fig_height = 3.4; % in inches, doubled
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
print -dpdf -painters autoware_drops
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



