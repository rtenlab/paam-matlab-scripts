classdef Executor
    properties
        id, type, priority, callbacks, cpu, ready_queue, ...
            util
    end
    
    methods
        % function obj = Executor(id, prio)
        function obj = Executor(id)
            obj.id = id;
            obj.priority = 0;
            obj.callbacks = [];
            obj.type = '';
            obj.cpu = [];
            obj.ready_queue = [];
            obj.util = 0;
        end
        
        function [obj, tasks] = add_callbacks(obj, tasks)
%             obj.callbacks = [obj.callbacks tasks];
            cpu_id = [];
            for t = 1 : length(tasks)
                obj.util = obj.util + tasks(t).C/tasks(t).chain_T;            
                tasks(t).executor = obj.id;
                obj.callbacks = [obj.callbacks tasks(t)];
                if length(cpu_id) == 0 
                    cpu_id = tasks(t).cpu;
                elseif cpu_id ~= tasks(t).cpu                    
                    disp('CPU ID error');
                end
                if obj.priority < tasks(t).priority
                    obj.priority = tasks(t).priority
                end
            end
            obj.cpu = cpu_id;
        end
        
        function [obj, callback] = assign(obj, callback)
            obj.callbacks = [obj.callbacks callback];
            callback.executor = obj.id;
            callback.priority = obj.priority;
            if isempty(obj.type)
                if callback.chain_id ~= 0
                    obj.type = 'chain';
                else
                    obj.type = 'single';
                end
%             else
%                 disp('The executor type is already defined.');
            end
        end
        
        function ready_cb = sort_ready_callbacks(obj, prev_core_t_id, prev_core_idx)
            ready_cb = [];
            if ~isempty(obj.ready_queue)
                % check if prev_core callback exist, it has the highest
                % priority because it's nonpreemptable within executor
                for i = 1 : length(obj.ready_queue)
                    if obj.ready_queue(i).task_id == prev_core_t_id && obj.ready_queue(i).index == prev_core_idx
                        ready_cb = obj.ready_queue(i);
                        return;
                    end
                end
                
                
                t_cb = []; r_cb = [];
                for i = 1 : length(obj.ready_queue)
                    if obj.ready_queue(i).timer_cb
                        t_cb = [t_cb obj.ready_queue(i)];
                    else
                        r_cb = [r_cb obj.ready_queue(i)];
                    end
                end

                % before priotizing callbacks, check whether there exists a
                % resumable job instances or not. Because a resumable job
                % has a higher priority than timer callback
                if ~isempty(t_cb)
                    [~, idx] = sort([t_cb.index], 'ascend');
                    t_cb = t_cb(idx);
                    
                    for i = 1 : length(t_cb)
                        if t_cb(i).current_exe ~= 0
                            ready_cb = t_cb(i);
                            return;
                        end
                    end
                end
                
                if ~isempty(r_cb)
                    [~, idx] = sort([r_cb.index], 'ascend');
                    r_cb = r_cb(idx);
                    
                    for i = 1 : length(r_cb)
                        if r_cb(i).current_exe ~= 0
                            ready_cb = r_cb(i);
                            return;
                        end
                    end
                end
                
                % Now, check new timer callback, then regular callbacks
                % which are ready
                if ~isempty(t_cb)
                    [~, idx] = sort([t_cb.index], 'ascend');
                    t_cb = t_cb(idx);
                    
                    ready_cb = t_cb(1);
                    return;
                end
                
                if ~isempty(r_cb)
                    [~, idx] = sort([r_cb.index], 'ascend');
                    r_cb = r_cb(idx);
                    
                    ready_cb = r_cb(1);
                    return;
                end

            end
        end
    end
end


