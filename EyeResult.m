% Define a cell array of file names
filelist = string([]);
pth = '/home/cog/Desktop/Alt/WithnetFiles/Envy/';
cd(pth);
fl = dir;
excl = ["152104.csv"]; %to exclude from analysis
a = 1;
for ii = 1:length(fl)
    if fl(ii).isdir; continue; end
    if ~isempty(regexp(fl(ii).name,'\d\.csv$', 'once')) && ~any(contains(fl(ii).name,excl))
        filelist(a) = fl(ii).name;
        a = a + 1;
    end
end

ROI = [-5 -5 5 5];

disp('Got files...')

% Loop over each file in the list
for ii = 1:length(filelist)
    % Load the current file
    i = iRecAnalysis('file',filelist(ii),'dir',pth);
    i.relativeMarkers = true;
    i.measureRange = [-1 2];
    i.plotRange = i.measureRange;
    i.load;
    i.parse;

    %This is our extracted data structure of each file
    d(ii).name = i.file;

    fprintf('===>>> %i -- Parsing File: %s\n',ii, i.file);
    
    % Get the reaction time data for the current file
    d(ii).rt = [i.trials(:).deltaT];
    d(ii).meanrt = mean(d(ii).rt);

    for j = 1:length(i.trials)
        if isempty(i.trials(j).data); continue; end
        s = i.trials(j).data.saccade;
        f = i.trials(j).data.fixation;
        ont = i.trials(j).times(s.on);
        offt = i.trials(j).times(s.off);

        dd = [];
        dd.preidx = find(ont < 0);
        dd.prestimtime = abs(i.trials(j).times(1));
        dd.prestimsacc = length(dd.preidx);
        dd.prestimavg = dd.prestimsacc / dd.prestimtime;

        dd.responseidx = find(ont >= 0 & ont <= i.trials(j).deltaT);
        dd.responsetime = i.trials(j).deltaT;
        dd.responsesacc = length(dd.responseidx);
        dd.responseavg = dd.responsesacc / dd.responsetime;

        dd.postresponseidx = find(ont > i.trials(j).deltaT);
        dd.postresponsetime = i.trials(j).endsampletime - i.trials(j).entime;
        dd.postresponsesacc = length(dd.postresponseidx);
        dd.postavg = dd.postresponsesacc / dd.postresponsetime;

        preepa = s.endPointAzi(dd.preidx);
        preepe = s.endPointEle(dd.preidx);
        dd.npreROI = preepa > ROI(1) & preepa < ROI(3) & preepe > ROI(2) & preepe < ROI(4);

        preepa = s.endPointAzi(dd.responseidx);
        preepe = s.endPointEle(dd.responseidx);
        dd.nrespROI = preepa > ROI(1) & preepa < ROI(3) & preepe > ROI(2) & preepe < ROI(4);

        preepa = s.endPointAzi(dd.postresponseidx);
        preepe = s.endPointEle(dd.postresponseidx);
        dd.npostROI = preepa > ROI(1) & preepa < ROI(3) & preepe > ROI(2) & preepe < ROI(4);

        %fixations
        ont = i.trials(j).times(f.on);
        offt = i.trials(j).times(f.off);

        % assign data to structure

        d(ii).trial(j) = dd;

    end
    
    [d(ii).totalpss, d(ii).totalpsse] = analysisCore.stderr([d(ii).trial(:).prestimavg]);
    [d(ii).totalrss, d(ii).totalrsse] = analysisCore.stderr([d(ii).trial(:).responseavg]);
    [d(ii).totalposs, d(ii).totalposse] = analysisCore.stderr([d(ii).trial(:).postavg]);
    d(ii).ROIPreSum = sum(d(ii).npreROI);
    d(ii).ROIDuringSum = sum(d(ii).npreROI);
    d(ii).ROIAfterSum = sum(d(ii).npreROI);

    
end