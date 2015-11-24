classdef ResponseStatistics < handle
    
    properties
        threshold               % spike threshold from GUI 
        smoothingWindow         % smoothing window for psth response from GUI
        enabled                 % spike detection status from GUI
    end
    
    properties(SetAccess = private)
        indices                 % containers.Map with 'key' as epoch id and 'value' as detected spike indices
        avgResponse             % cell array of struct for storing obj.avgOfRepeats 
    end
    
    properties(Access = private)
        amplifier
        avgOfRepeats            % average of repeats grouped by stmimuls intensity, Fields: r 'avg response', n 'count'
        initialPulseAmplitude   % below attribute act as metadata to optimize coding block for epoch parameters
        numberOfIntensities
        stimulusStart
        sampleRate
        scalingFactor
        epochLength
        startEpochId
        endEpochId
    end
    
    properties(Constant)
        BIN_WIDTH = 10
    end
    
    methods
        
        function obj = ResponseStatistics(amplifier)
            obj.amplifier = amplifier;
            obj.avgResponse = struct('r', [], 'n', 1);
        end
        
        function init(obj, epoch)
            [r, ~, ~] = epoch.response(obj.amplifier);
            obj.indices = containers.Map('KeyType', 'int32', 'ValueType', 'any');
            p = epoch.parameters;
            obj.initialPulseAmplitude = p.initialPulseAmplitude;
            obj.numberOfIntensities = p.numberOfIntensities;
            obj.stimulusStart = p.preTime * 1E-3; % TODO remove Hard coded unit
            obj.sampleRate = p.sampleRate;
            obj.scalingFactor = p.scalingFactor;
            obj.epochLength = length(r);
            obj.avgResponse = cell(obj.numberOfIntensities, 1);
        end
        
        function [indices, s] = detect(obj, epoch, id)
            
            if isempty(obj.startEpochId)
                obj.startEpochId = id;
            end
            [r, s, ~] = epoch.response(obj.amplifier);
            m = mean(r);
            r = r - m;
            indices = util.Signal.getIndicesByThreshold(r, obj.threshold, sign(obj.threshold));
            obj.indices(id) = indices;
            obj.endEpochId = id;
        end
        
        function computeAvgResponseForTrails(obj, epoch, id)
            stimulsIndex = mod(id, obj.numberOfIntensities);
            
            if stimulsIndex == 0
                stimulsIndex = obj.numberOfIntensities;
            end
            
            [r, ~, ~] =  epoch.response(obj.amplifier);
            r = r - mean(r(1: obj.stimulusStart * obj.sampleRate));
            
            if isempty(obj.avgResponse{stimulsIndex})
                obj.avgOfRepeats.n = 1;
                obj.avgOfRepeats.r = r;
                obj.avgResponse{stimulsIndex} = obj.avgOfRepeats;
                return;
            end
            n = obj.avgResponse{stimulsIndex}.n;
            sum = n *  obj.avgResponse{stimulsIndex}.r +  r;
            n = n + 1;
            obj.avgResponse{stimulsIndex}.r = sum/ n;
            obj.avgResponse{stimulsIndex}.n = n;
        end
        
        function [x,y] = getAvgResponse(obj, stimulsIndex)
            y = obj.avgResponse{stimulsIndex}.r;
            x = (1:numel(y))/obj.sampleRate - obj.stimulusStart;
        end
        
        function [x, count] = getPSTH(obj, stimulsIndex)
            trail = obj.getSpikeIndices(stimulsIndex);
            spikes = trail.spikes;
            bins = 1 : obj.getSampleSizePerBin : obj.epochLength;
            count = histc(spikes, bins);
            x = bins/obj.sampleRate - obj.stimulusStart;
            
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
            rate = round(obj.sampleRate / 1E3);
            n = round(obj.BIN_WIDTH * rate);
        end
        
        function trail = getSpikeIndices(obj, id)
            spikes = [];
            columns = (id : obj.numberOfIntensities : obj.endEpochId);
            columns = columns(columns >= obj.startEpochId);
            n = 0;
            for i = 1:length(columns)
                if isKey(obj.indices, columns(i))
                    spikes = [spikes, obj.indices(columns(i))];
                    n = n + 1;
                end
            end
            trail = struct();
            trail.spikes = spikes;
            trail.length = n;
        end
        
        function intensities = intensitiesToVoltages(obj)
            v = obj.initialPulseAmplitude;
            scale = obj.scalingFactor;
            exponent = (0 : obj.numberOfIntensities-1);
            intensities = arrayfun(@(n) round((scale^n)*v), exponent);
        end
    end
end