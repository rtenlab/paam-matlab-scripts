classdef Callback
    
    properties
        id, type, T, C, G, epsilon, D, executor, priority, cpu, bucket, ...
            chain_id, chain_order, chain_T, ...
            chain_c, ...
            wcrt, ...
            job_index, jobs,
            segment_flag, segment_C, segment_G, chain_on_cpu, gpu_waiting, gpu_handling, segment_gpu_handling, segment_n_callbacks    % for analysis purpose
            % gpu_waiting: beta, gpu_handling: beta^{GPU}
    end
    
    methods
        function obj = Callback(id, period, execution, gpu_execution, chain_id, order, callback_prio, cpu_id, executor_id, bucket)
            obj.id = id;
            obj.T = period;
            if period ~= 0
                obj.type = 'timer';
                obj.D = period;
            else
                obj.type = 'regular';
            end
            obj.C = execution;
            obj.G = gpu_execution;
            obj.epsilon = 0;    % miscellaneous gpu execution (including overhead by AAMF)
            obj.executor = 0;
            obj.priority = callback_prio;
            obj.chain_id = chain_id;
            obj.chain_order = order;
            obj.chain_c = 0;
            obj.wcrt = 0;
            obj.job_index = 1;
            obj.jobs = [];
            obj.segment_flag = false;
            obj.segment_C = 0;
            obj.segment_G = 0;
            obj.segment_gpu_handling = 0;
            obj.segment_n_callbacks = 0;
            obj.chain_on_cpu = false;
            obj.bucket = bucket;
            if nargin > 7
                obj.executor = executor_id;
                obj.cpu = cpu_id;
            end
        end
    end
end


