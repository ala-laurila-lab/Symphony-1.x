function test(~, data, fig)
%TEST Summary of this function goes here
%   Detailed explanation goes here
spikeMap =   data.Source.model.spikeDetectorMap;
channels = data.Source.model.channels;
spike = spikeMap(channels{1});
if isempty(fig)
    fig = figure;
end
if spike.enabled
    set(fig, 'Visible', 'on');
end
end

