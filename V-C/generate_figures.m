clear all;
close all;
clc;

data = importfile("overhead_breakdown.csv");
total = 0;
building = [];
transport = [];
queueing = [];
worker = [];
popping = [];
awakening = [];
data = data(1+50*6:(end-36), :);

for i = 1:height(data)
    total = total + data.time(i);
    if(mod(i, 6) == 1)
        building = [building ;data.time(i)];
    elseif mod(i,6) == 2
       transport = [transport data.time(i)];
    elseif mod(i, 6) == 3
        queueing = [queueing; data.time(i)];
    elseif mod(i, 6) == 4
        worker = [worker; data.time(i)];
    elseif mod(i,6) == 5
        popping = [popping; data.time(i)];
    elseif(mod(i, 6) == 0)
        awakening = [awakening ; data.time(i)];
        latency(i/6) = total;
        total = 0;
    end
end

min_ov = [min(building); min(transport); min(queueing); min(worker); min(popping); min(awakening)];
avg_ov = [mean(building); mean(transport); mean(queueing); mean(worker); mean(popping); mean(awakening)];
max_ov = [prctile(building, 99); prctile(transport, 99); prctile(queueing, 99); prctile(worker, 99); prctile(popping, 99); prctile(awakening, 99)];
overhead_data = [max_ov, min_ov, avg_ov];
%X = categorical({'Max', 'Min', 'Average'});
X = categorical({'Max', 'Min', 'Average'}, {'Min', 'Average', 'Max'});
bar( X, overhead_data', "stacked")
ylabel("Elapsed Time (us)")
lgd=legend({"Client msg generation", "DDS transmission", "PAAM request queueing", "PAAM worker wake-up", "PAAM scheduling", "Client notification"}, 'NumColumns', 1);
lgd.Location = 'north';
lgd.NumColumns = 3;

%title("PAAM Overhead Breakdown")
grid minor;
ylim([0, 520])
fontsize(gcf,14,"points")

fontsize(gcf,12,"points");
fontsize(lgd,10,"points");
fig_width = 6.8; fig_height = 2.8; % in inches, doubled
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
print -dpdf -painters overhead
