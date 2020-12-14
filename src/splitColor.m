function [red, blue, yellow, black, white] = splitColor(img, maxDist)
    if (nargin < 2)
        maxDist = 0.5;
    end
    
    [H,S,V] = imsplit(rgb2hsv(img));
    
    avgS = mean2(S);
    Saux = S < avgS;
    avgV = mean2(V(Saux));
    
    black = V < avgV;
    white = V >= avgV & S < avgS;
    
    r = num2cell([0.0139, 0.786, 0.786]);
    b = num2cell([0.5889, 0.78, 0.61]);
    y = num2cell([0.1583, 0.68, 1]);
    k = num2cell([0, 0, 0]);
    w = num2cell([0, 0, 1]);
    
    rD = distance(r{:}, H, S, V);
    bD = distance(b{:}, H, S, V);
    yD = distance(y{:}, H, S, V);
    kD = distance(k{:}, H, S, V);
    wD = distance(w{:}, H, S, V);
    
    red    = rD < bD & rD < yD & rD < kD & rD < wD & rD < maxDist;
    blue   = bD < rD & bD < yD & bD < kD & bD < wD & bD < maxDist;
    yellow = yD < rD & yD < bD & yD < kD & yD < wD & yD < maxDist;
end

function [dist] = distance(H, S, V, H2, S2, V2)
    cos1 = cos(2*pi * H) .* S;
    sin1 = sin(2*pi * H) .* S;
    
    cos2 = cos(2*pi * H2) .* S2;
    sin2 = sin(2*pi * H2) .* S2;

    dist = sqrt((cos2 - cos1).^2 + (sin2 - sin1).^2);
end