classdef SpikeStatistics < handle
    %SPIKEDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % UI properties
        threshold
        enabled = false
        indices
        activeIntensityIndex
    end
    
    properties(Access = private)
        amplifier
        % psth properites
        epochLength
        % Metadata to optimize coding block
        epochParams
        lastEpochId
    end
    
    
    properties(Constant)
        SPIKE_TIME = 'spikeTime'
        BIN_WIDTH = 10
        SMOOTHING_WINDOW = 0
    end
    
    
    methods
        
        function obj = SpikeStatistics(amplifier)
            obj.threshold = 0;
            obj.amplifier = amplifier;
            obj.indices = containers.Map;
            obj.lastEpochId = 0;
        end
        
        function [indices, s] = detect(obj, epoch, id)
            if obj.isvalid
                [data, s, ~] = epoch.response(obj.amplifier);
                m = mean(data);
                data = data - m;
                t = obj.threshold - m;
                indices = util.Signal.getIndicesByThreshold(data, t, sign(t));
                obj.indices(num2str(id)) = indices;
                obj.lastEpochId = id;
            end
        end
        
        function [x, count] = getPSTH(obj, epochId)
            sampleRate = obj.epochParams.sampleRate;
            stimStart = obj.epochParams.preTime*1E-3;
            
            trail = obj.getSpikeIndices(epochId);
            spikes = trail.spikes;
            bins = 1 : obj.getSampleSizePerBin : obj.epochLength;
            count = histc(spikes, bins);
            x = bins/sampleRate - stimStart;
            
            if isempty(count)
                count = zeros(1, length(bins));
            end
            %TODO migrate the piece of code to common util for further
            %felxibility
            if obj.SMOOTHING_WINDOW
                smoothingWindow_pts = round( obj.SMOOTHING_WINDOW / binWidth );
                w = gausswin(smoothingWindow_pts);
                w = w / sum(w);
                count = conv(count, w, 'same');
            end
            count = count / trail.length / (obj.BIN_WIDTH * 1E-3);
        end
        
        function reset(obj, epoch)
            obj.indices = containers.Map;
            obj.epochParams = epoch.parameters;
            [data, ~, ~] = epoch.response(obj.amplifier);
            obj.epochLength = length(data);
        end
        
        function n = getSampleSizePerBin(obj)
            rate = round(obj.epochParams.sampleRate / 1E3);
            n = round(obj.BIN_WIDTH * rate);
        end
        
        function trail = getSpikeIndices(obj, id)
            spikes = [];
            columns = (id : obj.epochParams.numberOfIntensities : obj.lastEpochId);
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
            exponent = (1 : obj.epochParams.numberOfIntensities);
            intensities = arrayfun(@(n) (scale^n)*v, exponent);
        end        
    end
    
    methods(Access = private)
        %TODO remove this method during refactoring
        function valid = isValid(obj)
            valid = ~isempty(obj.threshold);
        end
    end
end

