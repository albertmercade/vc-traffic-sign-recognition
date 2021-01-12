function rp = descriptors(shape, prominenceTh)
    if nargin < 2
        prominenceTh = 0.03;
    end
    % Remove artifacts that touch borders
    shape = imclearborder(shape);

    % select largest area
    shape = bwareafilt(shape, 1);
    
    width = size(shape, 1);
    
    % region props
    rp = regionprops(shape, 'Centroid', 'Circularity', 'Eccentricity', 'EulerNumber', 'Extent');
    
    totalPixels = numel(shape);
    numWhitePixels = sum(shape(:));
    ratio = numWhitePixels  / totalPixels;
    
    if (ratio < 0.05 || isempty(rp))
        % EulerNumber = 2 (since in our case it ranges from -infty to 1)
        % Eccentricity = 2 (0 is circle, 1 is line)
        rp = struct('Circularity', {0}, 'Eccentricity', {2}, 'EulerNumber',  {2}, 'Extent', {0}, 'numPeaks', {0}, 'maxMinDiff', {0}, 'ratioArea', {ratio}, 'circles', {0});
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
    
    % Try to find a circle
    circles = imfindcircles(shape, [fix(width/4), fix(width/2)]);

    % new descriptors
    rp.numPeaks = numPeaks;
    rp.maxMinDiff = max(sign) - min(sign);
    rp.ratioArea = ratio;
    rp.circles = size(circles, 1);
    
    % remove unnecesary field
    rp = rmfield(rp,'Centroid');
end