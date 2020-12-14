function [numPeaks, sign] = shapeSignature(shape, prominenceTh)
    if nargin < 2
        prominenceTh = 0.03;
    end
    
    % shape centroid
    rp = regionprops(shape,'Centroid');
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
end