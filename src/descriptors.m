function desc = descriptors(I)
    colors = splitColor(I);
    
    % Extract shape masks for background colors.
    [mask.white, shape.white] = shapeMask(colors.white);
    [mask.red, shape.red] = shapeMask(colors.red);
    [mask.blue, shape.blue] = shapeMask(colors.blue);
    
    % Mask for white signals with red border
    mask.redWhite = mask.red & mask.white;
    
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
    
    emptyAux = emptyAuxStruct();
    emptyShape.fg = emptyAux;
    emptyShape.bg = emptyAux;
    
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

function emptyAux = emptyAuxStruct()
    emptyAux = struct("Circularity", 2, "Eccentricity", 2, "EulerNumber", 2, "Extent", 0);
end

function desc = descriptorsSymbols(symbols, background)
    bg = bwareafilt(background==1, 1);
    background = imfill(bg, 'holes');
    
    bgProps = regionprops(background, ...
        'Centroid', 'Circularity', 'Eccentricity', 'EulerNumber', 'Extent', 'Area');

    if ~isempty(bgProps)
        symbols = bwareaopen(symbols, fix(bgProps(1).Area*0.02));
    end
    
    symbols = bwmorph(symbols, 'close');
    symbols = bwareafilt(symbols, 1);
    
    fgProps = regionprops(symbols, ...
        'Centroid', 'Circularity', 'Eccentricity', 'EulerNumber', 'Extent', 'Area');

    desc.bg = rmfield(bgProps,["Centroid", "Area"]);
    desc.fg = rmfield(fgProps,["Centroid", "Area"]);
    
    if isempty(desc.bg)
        desc.bg = emptyAuxStruct();
    end
    
    if isempty(desc.fg)
        desc.fg = emptyAuxStruct();
    end
    
    if desc.bg.Circularity > 5
        desc.bg.Circularity = 5;
    end
    
    if desc.fg.Circularity > 5
        desc.fg.Circularity = 5;
    end
end


function [mask, shape] = shapeMask(channel)
    [height, width] = size(channel);
    
    [centre, radius] = imfindcircles(channel,[int16(width/5),int16(width/2)]);
    
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