% function rp = descriptors(shape, prominenceTh)
%     if nargin < 2
%         prominenceTh = 0.03;
%     end
%     % Remove artifacts that touch borders
%     shape = imclearborder(shape);
% 
%     % select largest area
%     shape = bwareafilt(shape, 1);
%     
%     width = size(shape, 1);
%     
%     % region props
%     rp = regionprops(shape, 'Centroid', 'Circularity', 'Eccentricity', 'EulerNumber', 'Extent');
%     
%     totalPixels = numel(shape);
%     numWhitePixels = sum(shape(:));
%     ratio = numWhitePixels  / totalPixels;
%     
%     if (ratio < 0.05 || isempty(rp))
%         % EulerNumber = 2 (since in our case it ranges from -infty to 1)
%         % Eccentricity = 2 (0 is circle, 1 is line)
%         rp = struct('Circularity', {0}, 'Eccentricity', {2}, 'EulerNumber',  {2}, 'Extent', {0}, 'numPeaks', {0}, 'maxMinDiff', {0}, 'ratioArea', {ratio}, 'circles', {0});
%         return;
%     end
%     
%     cent = rp.Centroid;
%     
%     % shape boundaries
%     b = cell2mat(bwboundaries(shape,'noholes'));
%     
%     % euclidean distance
%     sign = sqrt((b(:, 1) - cent(1)).^2 + (b(:, 2) - cent(2)).^2);
%     
%     % shift values so that min is the first element & scale in [0..1]
%     [~,idx] = min(sign);
%     sign = circshift(sign, -idx)/max(sign);
%     
%     % smooth curve
%     sign = smoothdata(sign, 'sgolay');
%     
%     % count peaks with promincene threshold
%     numPeaks = sum(islocalmax(sign, 'MinProminence', prominenceTh));
%     
%     % Try to find a circle
%     circles = imfindcircles(shape, [fix(width/4), fix(width/2)]);
% 
%     % new descriptors
%     rp.numPeaks = numPeaks;
%     rp.maxMinDiff = max(sign) - min(sign);
%     rp.ratioArea = ratio;
%     rp.circles = size(circles, 1);
%     
%     % remove unnecesary field
%     rp = rmfield(rp,'Centroid');
% end



function mask = descriptors(channel)
    [height, width] = size(channel);
    
    [centre, radius] = imfindcircles(channel,[int16(width/5),int16(width/2)]);
    
    if (size(centre,1) > 0 && sum((centre - [height, width]/2).^2)^0.5 < width/5)
        mask = circleMask(centre,radius,[height, width]);
    else
        mask = polyMask(channel, height, width, 5, 2.5);
        if size(mask,1) == 1
            mask = zeros(height,width);
            % mask = preprocessChannel(channel);
        end
    end

end

function maskC = circleMask(centre, radius, size)
    [xx,yy] = ndgrid((1:size(1))-centre(2),(1:size(2))-centre(1));
    maskC = uint8((xx.^2 + yy.^2)<(radius^2));
end

function maskP = polyMask(channel, height, width, fg, ml)
    CE = edge(channel,'canny');

    [H,theta,rho] = hough(CE);
    P = houghpeaks(H,5);
    lines = houghlines(CE,theta,rho,P,'FillGap', width/fg,'MinLength', width/ml);
    
    p1 = struct2table(lines).point1;
    p2 = struct2table(lines).point2;
    Pch = [p1;p2];
    
    if length(Pch) < 3
        maskP = zeros(1);
        return;
    end
    
    k = convhull(Pch);
    X = Pch(k,1);
    Y = Pch(k,2);

    maskP = poly2mask(X,Y,height,width);
end