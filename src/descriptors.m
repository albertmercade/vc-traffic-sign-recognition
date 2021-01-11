function rp = descriptors(shape, prominenceTh)
    if nargin < 2
        prominenceTh = 0.03;
    end
    
    % Remove artifacts that touch borders
    shape = imclearborder(shape);
    
    % select largest area
    shape = bwareafilt(shape, 1);
    
    % region props
    rp = regionprops(shape,'Centroid', 'Circularity', 'Eccentricity', 'EulerNumber', 'Extent');
    
    totalPixels = numel(shape);
    numWhitePixels = sum(shape(:));
    ratio = numWhitePixels  / totalPixels;
    
    if (ratio < 0.05 || isempty(rp))
        % EulerNumber = 2 (since in our case it ranges from -infty to 1)
        % Eccentricity = 2 (0 is circle, 1 is line)
        rp = struct('Circularity', {0}, 'Eccentricity', {2}, 'EulerNumber',  {2}, 'Extent', {0}, 'numPeaks', {0}, 'maxMinDiff', {0}, 'ratioArea', {ratio});
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