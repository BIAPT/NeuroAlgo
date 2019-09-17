function summaryInfo = mff_getSummaryInfo(filePath,datType)

if nargin <= 1
    datType = 0;
end

% create the MFFFile object
mfffileObj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_MFFFile, [], filePath);

if datType == 0 %EEG
    [binObj blocks] = getEEGBlocks(mfffileObj, filePath);
elseif datType == 1 %PIB
    [binObj blocks] = getPIBBlocks(mfffileObj, filePath);
end
numblocks = binObj.getNumberOfBlocks();
if numblocks > 0 % Should always be
    blockObj = blocks.get(0); %zero based
    % Assumes sampling rate is the same in all blocks. Unpredictable if
    % does change.
    sampRate = double(blockObj.signalFrequency(1)); % 1 based
    nChans = blockObj.numberOfSignals;
    [epochType epochBeginSamps epochNumSamps epochFirstBlocks epochLastBlocks epochLabels epochTime0] = getEpochInfos(mfffileObj, filePath, sampRate);
    summaryInfo.sampRate = sampRate;
    summaryInfo.nChans = nChans;
    summaryInfo.binObj = binObj;
    summaryInfo.blocks = blocks;
    summaryInfo.epochType = epochType;
    summaryInfo.epochBeginSamps = epochBeginSamps;
    summaryInfo.epochNumSamps = epochNumSamps;
    summaryInfo.epochFirstBlocks = epochFirstBlocks;
    summaryInfo.epochLastBlocks = epochLastBlocks;
    summaryInfo.epochLabels = epochLabels;
    summaryInfo.epochTime0 = epochTime0;
    summaryInfo.mfffileObj = mfffileObj;
else
    % Error: Signal has 0 blocks
end
numblocks = binObj.getNumberOfBlocks();
for x = 0:numblocks-1
    blockObj = blocks.get(x);
    sampRate = double(blockObj.signalFrequency(1)); % 1 based
    nChans = blockObj.numberOfSignals;
    if sampRate ~= summaryInfo.sampRate;
        % Error: Inconsistent sampling rate
    end
    if nChans ~= summaryInfo.nChans;
        % Error: Inconsistent number of channels
    end
end

function [binObj blocks] = getEEGBlocks(mfffileObj, filePath)
% create Signal object and read in signal1.bin file
% !!!Replace with new call that returns EEG bin file.
eegFile = mff_getSignalFilename(mfffileObj, filePath, com.egi.services.mff.api.InfoN.kEEG);
binObj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_Signal, eegFile, filePath);

% inspect Signal file.  How many blocks, samples, etc.
% this can be done without reading in any of the actual data
blocks = binObj.getSignalBlocks();

function [binObj blocks] = getPIBBlocks(mfffileObj, filePath)
% create Signal object and read in signal1.bin file
% !!!Replace with new call that returns PIB bin file.
pibFile = mff_getSignalFilename(mfffileObj, filePath, com.egi.services.mff.api.InfoN.kPNSData);
binObj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_Signal, pibFile, filePath);

% inspect Signal file.  How many blocks, samples, etc.
% this can be done without reading in any of the actual data
blocks = binObj.getSignalBlocks();

function [epochType epochBeginSamps epochNumSamps epochFirstBlocks epochLastBlocks epochLabels epochTime0] = getEpochInfos(mfffileObj, filePath, sampRate)

infoObj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_Info, 'info.xml', filePath);
mffver = infoObj.getMFFVersion;

epochList = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_Epochs, 'epochs.xml', filePath);
epochListArray = epochList.getEpochs;
numEpochs = epochListArray.size;
epochBeginSamps = zeros(1,numEpochs);
epochNumSamps = zeros(1,numEpochs);
epochFirstBlocks = zeros(1,numEpochs);
epochLastBlocks = zeros(1,numEpochs);
epochTime0 = zeros(1,numEpochs);
epochLabels = cell(1,numEpochs);

for p = 0:numEpochs-1
    anEpoch = epochListArray.get(p);
    epochBegin = anEpoch.getBeginTime();
    epochEnd = anEpoch.getEndTime();
    % Note: end time is first sample NOT in epoch.
    if mffver == 0
        epochBeginSamps(p+1) = mff_nanos2Sample(epochBegin, sampRate);
    else
        epochBeginSamps(p+1) = mff_micros2Sample(epochBegin, sampRate);
    end
    epochTime0(p+1) = epochBeginSamps(p+1);
    if mffver == 0
        epochNumSamps(p+1) = mff_nanos2Sample(epochEnd, sampRate) - epochBeginSamps(p+1);
    else
        epochNumSamps(p+1) = mff_micros2Sample(epochEnd, sampRate) - epochBeginSamps(p+1);
    end
    epochFirstBlocks(p+1) = anEpoch.getFirstBlock;
    epochLastBlocks(p+1) = anEpoch.getLastBlock;
    epochLabels{p+1} = 'epoch';
    %fprintf('epoch diff %f\n', epochEnd - epochBegin)
end

% assumes the following, which should be true: 1-1 mapping between segments
% and epochs, including quantity and begin times.
% !! add checks and error cases?
epochType = 'cnt';
categList = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_Categories, 'categories.xml', filePath);
if ~isempty(categList)    
    categListArray = categList.getCategories;
    numCategs = categListArray.size;
    for p = 0:numCategs-1
        aCateg = categListArray.get(p);
        categLabel = aCateg.getName;
        segList = aCateg.getSegments;
        numSegs = segList.size;
        totalNumSegs = totalNumSegs + numSegs;
        for q = 0:numSegs-1
            aSeg = segList.get(q);
            segBegin = aSeg.getBeginTime;
            %segEnd = aSeg.getEndTime;
            %fprintf('seg diff %f\n', segEnd - segBegin)
            segBeginSamp = mff_nanos2Sample(segBegin, sampRate);
            segInd = find(epochBeginSamps == segBeginSamp);
            if ~isempty(categLabel)
                epochLabels{segInd} = char(categLabel);
            end
            time0 = aSeg.getEventBegin;
            time0Samp = mff_nanos2Sample(time0, sampRate);
            time0Samp = (time0Samp - segBeginSamp) + 1;
            epochTime0(segInd) = time0Samp;
        end
    end
    epochType = 'seg';
    % if epoch lengths are different, yet there are categories, than it's
    % var(iable) epoch type.
    if size(unique(epochNumSamps),2) ~= 1 || size(unique(epochTime0),2) ~= 1
        epochType = 'var';
    end
end
%fprintf('totalNumSegs, numEpochs %d %d\n', totalNumSegs, numEpochs);

function signalFile = mff_getSignalFilename(mfffileObj, filePath, infoNType)
signalFile = [];
%infoFile = [];
binfiles = mfffileObj.getSignalResourceList(false);
% Java is zero based. 
for p = 0:size(binfiles)-1
    binFilename = binfiles.get(p);
    % All this to strip the number (binNumStr) from the signal file in order to apply
    % it to the info file. 
    prefix = 'signal';
    prefixLen = size(prefix,2);
    extension = '.bin';
    extensionLen = size(extension,2);
    binNumDigits = size(binFilename,2) - (prefixLen + extensionLen);
    binNumStr = binFilename(prefixLen+1:prefixLen + binNumDigits);

    infoObj = mff_getObject(com.egi.services.mff.api.MFFResourceType.kMFF_RT_InfoN, ['info' binNumStr '.xml'], filePath);
    fileType = infoObj.getInfoNFileType;

    if fileType == infoNType
%         infoFile = ['info' binNumStr '.xml'];
        signalFile = ['signal' binNumStr '.bin'];
        % can break here - assume only one item. 
        break;
    end
end
