function desc = descriptors(I)
    colors = splitColor(I);
    
    % Extract shape masks for background colors.
    [mask.white, shape.white] = shapeMask(colors.white);
    [mask.red, shape.red] = shapeMask(colors.red);
    [mask.blue, shape.blue] = shapeMask(colors.blue);
    
    % Mask for white signals with red border
    if string(shape.red) == string(shape.white)
        mask.redWhite = mask.red & mask.white;
    else
        if shape.red == "circle"
            mask.redWhite = mask.red;
        elseif shape.white == "circle"
            mask.redWhite = mask.white;
        else
            mask.redWhite = mask.red | mask.white;
        end
    end
    
    % Basic Signals (red white && blue)
    
    % Black on white (with red border)
    symbols.blackWhiteR = colors.black & mask.redWhite;
    % White on blue
    symbols.whiteBlue = colors.white & mask.blue;
    
    % Special signals
    
    % red on white (9, 10)
    symbols.redWhite = colors.red & mask.redWhite;
    % white on red (14, 17)
    symbols.whiteRed = colors.white & mask.red;
    % Black on white (41, 42) (Without red)
    symbols.blackWhite = colors.black & mask.white;
    
    % yellow on white (12)
    symbols.yellowWhite = colors.yellow & mask.white;
    
    emptyShape.fg = emptyAuxFgStruct();
    emptyShape.bg = emptyAuxBgStruct();
    
    desc.blackWhiteR = emptyShape;
    desc.redWhite = emptyShape;
    desc.blackWhite = emptyShape;
    desc.yellowWhite = emptyShape;
    desc.whiteBlue = emptyShape;
    desc.whiteRed = emptyShape;
    
    if shape.white ~= "empty"
        desc.blackWhiteR = descriptorsSymbols(symbols.blackWhiteR, mask.redWhite);
        desc.redWhite = descriptorsSymbols(symbols.redWhite, mask.redWhite);
        
        desc.blackWhite = descriptorsSymbols(symbols.blackWhite, mask.white);
        desc.yellowWhite = descriptorsSymbols(symbols.yellowWhite, mask.white);
    end
    
    if shape.blue ~= "empty"
        desc.whiteBlue = descriptorsSymbols(symbols.whiteBlue, mask.blue);
    end
    if shape.red ~= "empty"
        desc.whiteRed = descriptorsSymbols(symbols.whiteRed, mask.red);
    end
    
    desc.shape = shape;
    
    %desc.symbols = symbols;
    
end

function emptyAux = emptyAuxBgStruct()
    emptyAux = struct("Solidity", 2, "Eccentricity", 2, "EulerNumber", 2, "Extent", 0);
end


function emptyAux = emptyAuxFgStruct()
    emptyAux.numel = 0;
    
    for i = 1:4
        emptyAux.("CentroidDistanceX"+int2str(i)) = -1;
        emptyAux.("CentroidDistanceY"+int2str(i)) = -1;
        emptyAux.("Solidity"+int2str(i)) = 2;
        emptyAux.("Eccentricity"+int2str(i)) = 2;
        emptyAux.("EulerNumber"+int2str(i)) = 2;
        emptyAux.("Extent"+int2str(i)) = 0;
        emptyAux.("AreaCoverage" + int2str(i)) = 0;
    end
end

function desc = descriptorsSymbols(symbols, background)
    bg = bwareafilt(background==1, 1);
    background = imfill(bg, 'holes');
    
    bgProps = regionprops(background, ...
        'Centroid', 'Solidity', 'Eccentricity', 'EulerNumber', 'Extent', 'Area', 'BoundingBox');
    
    if isempty(bgProps)
        desc.fg = emptyAuxFgStruct();
        desc.bg = emptyAuxBgStruct();
        return;
    end

    bgWidth = bgProps(1).BoundingBox(3);

    symbols = bwareaopen(symbols, fix(bgProps(1).Area*0.02));
    
    symbols = bwmorph(symbols, 'close');
    symbols = bwareafilt(symbols, 4);
    
    fgProps = regionprops(symbols, ...
        'Centroid', 'Solidity', 'Eccentricity', 'EulerNumber', 'Extent', 'Area');
    
    newFgProps.numel = size(fgProps,1);
    
    for i = 1:4
        newFgProps.("CentroidDistance"+int2str(i)) = -1;
        newFgProps.("Solidity"+int2str(i)) = 2;
        newFgProps.("Eccentricity"+int2str(i)) = 2;
        newFgProps.("EulerNumber"+int2str(i)) = 2;
        newFgProps.("Extent"+int2str(i)) = 0;
        newFgProps.("AreaCoverage" + int2str(i)) = 0;
    end
    
    fgAux = struct2array(fgProps);
    fgAux = reshape(fgAux,7,[])';
    for i = 1:size(fgAux,1)
        newFgProps.("CentroidDistanceX"+int2str(i)) = (fgAux(i,2) - bgProps.Centroid(1))/bgWidth;
        newFgProps.("CentroidDistanceY"+int2str(i)) = (fgAux(i,3) - bgProps.Centroid(2))/bgWidth;
        newFgProps.("Solidity"+int2str(i)) = fgAux(i,7);
        newFgProps.("Eccentricity"+int2str(i)) = fgAux(i,4);
        newFgProps.("EulerNumber"+int2str(i)) = fgAux(i,5);
        newFgProps.("Extent"+int2str(i)) = fgAux(i,6);
        newFgProps.("AreaCoverage" + int2str(i)) = fgAux(i,1)/bgProps.Area;
    end

    desc.bg = rmfield(bgProps,["Centroid", "Area", "BoundingBox"]);    
    desc.fg = newFgProps;
end


function [mask, shape] = shapeMask(channel)
    [height, width] = size(channel);
    
    [centre, radius] = imfindcircles(channel,[int16(width/7),int16(width/2)]);
    
    if (size(centre, 1) > 0 && sum((centre(1,:) - [height, width]/2).^2)^0.5 < width/5)
        shape = 'circle';
        mask = circleMask(centre(1,:), radius(1,:), [height, width]);
    else
        shape = 'poly';
        mask = polyMask(channel, height, width, 5, 2.5);
        if size(mask,1) == 1
            shape = 'empty';
            mask = false(height,width);
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
    
    try
        k = convhull(Pch);
    catch
        maskP = zeros(1);
        return;
    end
    
    X = Pch(k,1);
    Y = Pch(k,2);

    maskP = poly2mask(X,Y,height,width);
end