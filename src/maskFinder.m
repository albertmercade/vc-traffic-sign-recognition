function [mask, colors, took] = maskFinder(I)
    colors = splitColor(I);
    
    took = "circle white";
    [mask, ok] = circleMask(colors.white);
    if ok; return; end
    
    took = "circle blue";
    [mask, ok] = circleMask(colors.blue);
    if ok; return; end
    
    took = "circle red";
    [mask, ok] = circleMask(colors.red);
    if ok; return; end

    cr = imclose(colors.red, strel('line', 3, 60));
    cr = imclose(cr, strel('line', 3, 120));
    cr = imclose(cr, strel('line', 3, 0));
    
    took = "poly red inv";
    mask = reconMask(~cr);
    mask = mask | reconMask(colors.white);
    if validateMask(mask); return; end
    
    took = "poly red";
    mask = reconMask(colors.red);
    if validateMask(mask); return; end
        
    took = "poly white";
    mask = reconMask(colors.white);
    if validateMask(mask); return; end
    
    took = "poly blue";
    mask = reconMask(colors.blue);
    if validateMask(mask); return; end
    
    took = "Diff";
    mask = colors.red;    
    F = imfill(mask, 'holes');
    mask = F - mask;
    
    mask = bwmorph(mask, 'open');
    mask = bwconvhull(mask);
    
    if validateMask(mask); return; end
    
    took = "clearborder red";
    mask = imclearborder(colors.red, 4);
    mask = bwconvhull(mask);
    
    if validateMask(mask); return; end
    
    took = "clearborder blue";
    mask = imclearborder(colors.blue, 4);
    mask = bwconvhull(mask);
    
    if validateMask(mask); return; end
    
    took = "fallback";
    mask = true(size(colors.red));
    
    return;
end

function mask = reconMask(C)
    marker = false(size(C));
    [h, w] = size(C);

    marker(fix(h/2), fix(w/2)) = true;
    
    marker(fix(h/3), fix(w/2)) = true;
    marker(fix(2*h/3), fix(w/2)) = true;
    
    marker(fix(2*h/3), fix(w/3)) = true;
    marker(fix(2*h/3), fix(2*w/3)) = true;

    C = imfill(C, 'holes');

    mask = imreconstruct(marker, C, 4);
    mask = bwmorph(mask, 'open');
    mask = bwconvhull(mask);
end

function ok = validateMask(mask)

    [h, w] = size(mask);

    if mask(fix(h/2), fix(w/2)) ~= true
        ok = false;
        return
    end
    
    topEdge = mask(1, :);
    bottomEdge = mask(end,:);
    leftEdge = mask(:, 1);
    rightEdge = mask(:, end);
    
    ok = ~(any(topEdge) || any(bottomEdge) || any(leftEdge) || any(rightEdge));
end

function [mask, ok] = circleMask(I)
    [h, w] = size(I);
    ok = true;
    [centre, radius] = imfindcircles(I, [int16(w/4) int16(w/2)], 'Sensitivity', 0.9);
    
    if isempty(centre)
        ok = false;
        mask = [];
        return;
    end
    
    centre = centre(1,:);
    radius = radius(1,:);
    
    [xx,yy] = ndgrid((1:h)-centre(2), (1:w)-centre(1));
    mask = (xx.^2 + yy.^2)<(radius^2);
end