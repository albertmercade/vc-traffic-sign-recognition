function rp = descriptors(shape, prominenceTh)
    if nargin < 2
        prominenceTh = 0.03;
    end
    
    % Remove artifacts that touch borders
    shape = imclearborder(shape);
    
    % select largest area
    shape = bwareafilt(shape, 1);
    
    % region props
    rp = regionprops(shape,'Centroid','Circularity', 'Extent', 'EulerNumber');
    
    totalPixels = numel(shape);
    numWhitePixels = sum(shape(:));
    ratio = numWhitePixels  / totalPixels;
    
    if (ratio < 0.05 || isempty(rp))
        rp = struct('Circularity', {-1}, 'Extent', {-1}, 'EulerNumber', {-1},'numPeaks', {-1}, 'maxMinDiff', {-1}, 'ratioArea', {ratio});
        return;
    end
    
    cent = rp.Centroid;
    
    % shape boundaries
    b = cell2mat(bwboundaries(shape,'noholes'));
    
    % euclidean distance
    sign = sqrt((b(:, 1) - cent(1)).^2 + (b(:, 2) - cent(2)).^2);
    
    % shift values so that min is the first element & scale in [0..1]
    [~,idx] = min(sign);
    sign = circshift(sign, -idx)/max(sign);
    
    % smooth curve
    sign = smoothdata(sign, 'sgolay');
    
    % count peaks with promincene threshold
    numPeaks = sum(islocalmax(sign, 'MinProminence', prominenceTh));
    
    % new descriptors
    rp.numPeaks = numPeaks;
    rp.maxMinDiff = max(sign) - min(sign);
    rp.ratioArea = ratio;
    
    % remove unnecesary field
    rp = rmfield(rp,'Centroid');
end