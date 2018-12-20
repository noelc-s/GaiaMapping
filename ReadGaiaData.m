function ReadGaiaData(opts)
% READGAIADATA - Processes Gaia csv files
%
% This function takes in a file name of an exported gaia csv and processes 
% the data into a usable format.
%
% ex:
% ReadGaiaData('./Data/GaiaFile.csv')

%% Read CSV Data
fprintf('Reading CSV Data from file: %s\n',opts.file)
fileID = fopen(opts.file);
header = fgetl(fileID);
% Convert the string into a cell array
header = str2data(split(header,','));
fgetl(fileID); % Remove additional line with no data
C = textscan(fileID,'%s %s %s %s %s %s %s %s %s %s %s','Delimiter',',');

data={};
for i = 1:length(C)
    data = [data C{i}];
end
% Convert the string into a table
hiker = cell2table(str2data(data),'VariableNames',header);

hiker.TIME = getTime(hiker.TIME); % Convert to usable time (decimal format)
hiker{:,3:end} = num2cell(getData(hiker{:,3:end})); % Get rid of strings
fclose(fileID);

%% Get Map data
fprintf('Getting surrounding altitude data from Mapquest\n')

long = cell2mat(hiker.LON);
lat = cell2mat(hiker.LAT);
alt = cell2mat(hiker.ALT);
time = hiker.TIME;

loc = [lat long];

terrain = [];

res = opts.resolution;

min_lat = min(loc(:,1));
max_lat = max(loc(:,1));
min_long = min(loc(:,2));
max_long = max(loc(:,2));

lat_query = linspace(min(loc(:,1)),max(loc(:,1)),res);
long_query = linspace(min(loc(:,2)),max(loc(:,2)),res);

% Get key for mapquest API
f = fopen('key.txt');
eval(fgetl(f));
fclose(f);

for i = 1:res
    
    loc_query = [lat_query' linspace(long_query(i),long_query(i),res)'];
    
    index = [1 res];
    latlongcollection = [sprintf('%f,',loc_query(index(1):index(2)-1,:)') num2str(loc_query(index(2),1)) ...
        ',' num2str(loc_query(index(2),2))];
    
    url = ['http://open.mapquestapi.com/elevation/v1/profile?key=' key '&shapeFormat=raw&latLngCollection=' latlongcollection];
    
    % web(url)
    flag = false;
    num_try = 0;
    while ~flag
        try
            num_try = num_try+1;
            str = urlread(url,'UserAgent', 'Mozilla/5.0','Timeout',10);
            flag = true;
        catch
            warning(['Request failed on query number ' num2str(num_try) ', trying again'])
            flag = false;
        end
    end
    
    u = split(str,'distance');
    u = split(u(2:end),'height');
    %     dist = cell2mat(cellfun(@(t) str2double(t(3:end-2)), u(:,1),'UniformOutput',false));
    elev = cell2mat(cellfun(@(t) str2double(strtok(t(3:end),'}')), u(:,2),'UniformOutput',false));
    
    terrain = [terrain; loc_query elev];
end
terrain = array2table(terrain,'VariableNames',{'LAT','LON','ALT'})
%% Image
fprintf('Getting surrounding image data from Mapquest\n')
center = [max(lat_query) min(long_query) min(lat_query) max(long_query)];

photo = webread(['https://open.mapquestapi.com/staticmap/v5/map?key=' key ...
    '&boundingBox=' num2str(center(1)) ',' num2str(center(2)) ',' num2str(center(3)) ',' num2str(center(4)) '&size=@2x&margin=-50&type=sat']);

% imshow(cont)
%%
save(['Data/PROCESSED/' opts.file(1:end-4) '_processed'],'hiker','terrain','photo');
end

function time = getTime(in)
[~,t] = strtok(in,'T');
t = str2data(t); % This time, it removes the T and Z strings
for i = 1:length(t)
    x = t(i,:);
    y = str2double(regexp(x{:},':','split'));
    time(i,1) = y*[1;1/60;1/(60*60)];
end
end

function data = getData(in)
data = cellfun(@(t) sprintf('%.6f',str2num(t)), in,'UniformOutput',false);
if isstring(data{1}) | ischar(data{1})
    data = str2double(data);
end
end

function data = str2data(in)
    data = cellfun(@(t) t(2:end-1), in,'UniformOutput',false);
end