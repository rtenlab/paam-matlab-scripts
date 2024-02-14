function [response_time] = sched_calc(data)

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

% Compute response time of callbacks
[chains, response_time] = response_time_callbacks(chains, cpus);



end
