% Define a cell array of file names
filelist = string([]);
pth = '/home/cog/Desktop/Alt/WithnetFiles/Envy/';
cd(pth);
fl = dir;
excl = ["152104.csv"]; %To exclude from analysis
a = 1;
for i = 1:length(fl)
    if fl(i).isdir; continue; end
    if ~isempty(regexp(fl(i).name,'\d\.csv$', 'once')) && ~any(contains(fl(i).name,excl))
        filelist(a) = fl(i).name;
        a = a + 1;
    end
end

disp('Got files...')

% Loop over each file in the list
for ii = 1:length(filelist)
    % Load the current file
    i = iRecAnalysis('file',filelist(ii),'dir',pth);
    i.measureRange = [-0.5 3.5];
    i.plotRange = i.measureRange;
    i.load;
    i.parse;
    
    % Get the reaction time data for the current file
    rt = [i.trials(:).deltaT];
    %figure;
    %histogram(rt);
    %title(filelist(ii));
    meanrt(ii) = mean(rt);
    allrt{ii} = rt;
    
    % Analyze saccade and microsaccade in ROI
    %roi = [0 0 5]; % define the ROI coordinates
    %i.parseROI(roi);
    %saccade = computeSaccades(i, roi);
    %microsaccade = computeMicrosaccades (i, roi);
    %meanFixationTime = mean(i.fixations(:).duration);
    
    % Other stuff
    d(ii).name = i.file;
    d(ii).meanrt = meanrt(ii);
    d(ii).rt = rt;
    %d(ii).saccade = saccade;
    %d(ii).microsaccade = microsaccade;
    %d(ii).meanFixationTime = meanFixationTime;
    
end