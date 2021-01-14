function [desc] = newDescriptors(I)
    G = rgb2gray(I);
    
    desc = descriptorTriangle(G);
    desc = descriptorCircle(desc, G);
    
    [mask, colors] = maskFinder(I);
    desc = maskDescriptors(desc, mask);
    desc = descriptorColors(desc, colors, mask);
end

function [desc] = maskDescriptors(desc, shape) 
    % shape boundaries
    b = cell2mat(bwboundaries(shape,'noholes'));
    
    cent = size(shape)/2;
    
    % euclidean distance
    sign = sqrt((b(:, 1) - cent(1)).^2 + (b(:, 2) - cent(2)).^2);
    
    % shift values so that min is the first element & scale in [0..1]
    [~,idx] = min(sign);
    sign = circshift(sign, -idx)/max(sign);
    
    % smooth curve
    sign = smoothdata(sign, 'sgolay');
    
    % count peaks with promincene threshold
    numPeaks = sum(islocalmax(sign, 'MinProminence', 0.03));
    
    % new descriptors
    desc.numPeaks = numPeaks;
    desc.maxMinDiff = max(sign) - min(sign);
end