function opts = genOpts()
%% Reading data
opts = struct();
opts.file = 'MissionTrailsLoop.csv';
opts.resolution = 150;
%% Plotting data
opts.show_path = true;
opts.show_terrain = true;
opts.show_image = false;
opts.export = true;
opts.local = true; % Option to include js rendering
opts.alt_gain = 30; % Amount to add to altitude so scatter points are not below mountain
end