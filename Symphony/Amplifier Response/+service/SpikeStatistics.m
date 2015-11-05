classdef SpikeStatistics < handle
    %SPIKEDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % UI properties
        threshold
        enabled = false
        indices
        activeIntensityIndex
        smoothingWindow
        avgResponse % cell array for storing each response by trails
    end
    
    properties(Access = private)
        amplifier
        % psth properites
        epochLength
        % Metadata to optimize coding block
        epochParams
        lastEpochId
        startEpochId
        % average response by trail  
        avgResponseByTrail = struct('r', [], 'n', 1);
    end
    
    
    properties(Constant)
        SPIKE_TIME = 'spikeTime'
        BIN_WIDTH = 10
    end
    
    
    methods
        
        function obj = SpikeStatistics(amplifier)
            obj.threshold = 0;
            obj.amplifier = amplifier;
            obj.indices = containers.Map;
            obj.lastEpochId = 0;
            obj.startEpochId = 0;
            obj.smoothingWindow = 0;
        end
        
        function init(obj, epoch)
            obj.indices = containers.Map;
            obj.epochParams = epoch.parameters;
            [data, ~, ~] = epoch.response(obj.amplifier);
            obj.epochLength = length(data);
            obj.avgResponse = cell(epoch.parameters.numberOfIntensities, 1);
        end
        
        function [indices, s] = detect(obj, epoch, id)
            
            if obj.startEpochId == 0
                obj.startEpochId = id;
            end
            [data, s, ~] = epoch.response(obj.amplifier);
            m = mean(data);
            data = data - m;
            t = obj.threshold - m;
            indices = util.Signal.getIndicesByThreshold(data, t, sign(t));
            obj.indices(num2str(id)) = indices;
            obj.lastEpochId = id;
        end
        
        function computeAvgResponseForTrails(obj, epoch, id)
            numberOfIntensities = obj.epochParams.numberOfIntensities;
            trailId = mod(id, numberOfIntensities)+1;
            if isempty(obj.avgResponse{trailId})
                obj.avgResponseByTrail.r = epoch.response(obj.amplifier);
                obj.avgResponseByTrail.n = 1;
                obj.avgResponse{trailId} = obj.avgResponseByTrail;
                return;
            end
            c = obj.avgResponse{trailId}.n;
            sum = c *  obj.avgResponse{trailId}.r +  epoch.response(obj.amplifier);
            c = c + 1;
            obj.avgResponse{trailId}.r = sum/ c;
            obj.avgResponse{trailId}.n = c;
        end
        
        function [x,y] = getAvgResponse(obj, stimulsIndex)
            y = obj.avgResponse{stimulsIndex}.r;
            x = (1:numel(y))/obj.epochParams.sampleRate;
        end
        
        function [x, count] = getPSTH(obj, stimulsIndex)
            sampleRate = obj.epochParams.sampleRate;
            stimStart = obj.epochParams.preTime*1E-3;
            
            trail = obj.getSpikeIndices(stimulsIndex);
            spikes = trail.spikes;
            bins = 1 : obj.getSampleSizePerBin : obj.epochLength;
            count = histc(spikes, bins);
            x = bins/sampleRate - stimStart;
            
            if isempty(count)
                count = zeros(1, length(bins));
            end
            %TODO migrate the piece of code to common util for further
            %felxibility
            if obj.smoothingWindow
                smoothingWindow_pts = round( obj.smoothingWindow / obj.BIN_WIDTH);
                w = gausswin(smoothingWindow_pts);
                w = w / sum(w);
                count = conv(count, w, 'same');
            end
            count = count / trail.length / (obj.BIN_WIDTH * 1E-3);
        end
        
        function n = getSampleSizePerBin(obj)
            rate = round(obj.epochParams.sampleRate / 1E3);
            n = round(obj.BIN_WIDTH * rate);
        end
        
        function trail = getSpikeIndices(obj, id)
            spikes = [];
            columns = (id : obj.epochParams.numberOfIntensities : obj.lastEpochId);
            columns = columns(columns >= obj.startEpochId);
            n = length(columns);
            for i = 1:n
                spikes = [spikes, obj.indices(num2str(columns(i)))'];
            end
            trail = struct();
            trail.spikes = spikes;
            trail.length = n;
        end
        
        function intensities = intensitiesToVoltages(obj)
            v = obj.epochParams.pulseAmplitude;
            scale = obj.epochParams.scalingFactor;
            exponent = (0 : obj.epochParams.numberOfIntensities-1);
            intensities = arrayfun(@(n) (scale^n)*v, exponent);
        end
    end
end

