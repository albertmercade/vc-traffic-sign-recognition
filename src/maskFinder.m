function [mask, colors] = maskFinder(I)
    colors = splitColor(I);
    
    R = colors.red;    
    F = imfill(R,'holes');
    R = F - R;
    
    Y = colors.yellow;
    Y = imclearborder(Y);
    Y = bwareafilt(Y,1);
    Y = imfill(Y,'holes');
    
    maskR = circleMask(colors.red, size(R));
    maskB = circleMask(colors.blue, size(R));
    maskW = circleMask(colors.white, size(R));
    mask = R | Y | maskR | maskB | maskW;
    
    mask = bwareafilt(mask,1);
    mask = imfill(mask, 'holes');
end

function maskC = circleMask(I, size)
    [centre, radius] = imfindcircles(I, [int16(size(2)/4) int16(size(2)/2)], 'Sensitivity', 0.9);
    
    if isempty(centre)
        maskC = false(size);
        return;
    end
    
    [xx,yy] = ndgrid((1:size(1))-centre(2),(1:size(2))-centre(1));
    maskC = uint8((xx.^2 + yy.^2)<(radius^2));
end