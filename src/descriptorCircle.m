function [desc, centre, radius] = descriptorCircle(desc, I)
    [height, width] = size(I);
    [centre, radius] = imfindcircles(I, [int16(width/4) int16(width/2)], 'Sensitivity', 0.9);
    
    if isempty(centre)
        [centre, radius] = imfindcircles(I, [int16(width/4) int16(width/2)], 'ObjectPolarity', 'dark', 'Sensitivity', 0.9);
        if isempty(centre)
            centre = [0 0];
            radius = 0;
        end
    end
    
    centre = centre(1,:);
    radius = radius(1);
    
    desc.CC = pdist([[height/2 width/2]; centre],'euclidean')/width;
    desc.R = radius/width;
end