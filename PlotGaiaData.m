function PlotGaiaData(opts)

load([opts.file(1:end-4) '_processed']);

f = figure;
axis equal tight
hold on

%% Plot path
if opts.show_path
    long = cell2mat(hiker.LON);
    lat = cell2mat(hiker.LAT);
    alt = cell2mat(hiker.ALT);
    time = hiker.TIME;
    
    p_y = (lat-min(lat))*69.172*1609.34; % in m
    p_x = lat(end)*pi/180*69.172*(long-min(long))*1609.34;
    p_z = alt;
    
    mat2cell(lat,length(lat),1);
    % b=[sprintf('%s_',ans(1:end-1)),ans(end)]
    
    loc = [lat long];
    
    p_x = p_x';
    p_y = p_y';
    p_z = p_z'+opts.alt_gain;
    
    scatter3(p_x,p_y,p_z,...x
        20*ones(size(time)),time,'filled')
end

%% Plot terrain
m_long = terrain.LON;
m_lat = terrain.LAT;
m_alt = terrain.ALT;

y = (m_lat-min(m_lat))*69.172*1609.34; % in m
x = m_lat(end)*pi/180*69.172*(m_long-min(m_long))*1609.34;
if opts.show_terrain
    
    z=reshape(m_alt,opts.resolution,opts.resolution);
    
    % scatter3(m_long, m_lat, m_alt,5*ones(size(m_long)),5*ones(size(m_long)),'filled')
    [lo, la] = meshgrid(linspace(x(1), x(end),opts.resolution),linspace(y(1), y(end),opts.resolution));
    
    s = surf(lo,la, z);
    alpha(.5)
    set(s,'edgecolor','none')
    
end

%% Overlay Image
if opts.show_image
    [lo, la] = meshgrid(linspace(x(1), x(end),opts.resolution),linspace(y(1), y(end),opts.resolution));
    
    warp(lo,la, reshape(m_alt,opts.resolution,opts.resolution), rot90(photo,1))
    
end
%% Export Data
if opts.export
    save('tmp','lo','la','z','p_x','p_y','p_z','opts')
    system('python plotData.py')
end
end