function desc = descriptorTriangle(channel)    
    [L, DC, H] = houghpoints(channel, [25:0.5:35]);
    desc.DLL = L;
    desc.DLDH = DC(1);
    desc.DLDV = DC(2);
    desc.DLH = H;
    
    [L, DC, H] = houghpoints(channel, [-35:0.5:-25]);
    desc.DRL = L;
    desc.DRDH = DC(1);
    desc.DRDV = DC(2);
    desc.DRH = H;
    
    [L, DC, H] = houghpoints(channel, [-85:-90, 84:89]);
    desc.DHL = L;
    desc.DHDH = DC(1);
    desc.DHDV = DC(2);
    desc.DHH = H;
end

function [L, DC, PH] = houghpoints(channel, angle)
    CE = edge(channel,'canny');

    width = size(channel,2);
    
    [H,theta,rho] = hough(CE, 'Theta', angle);
    P = houghpeaks(H,1, 'Theta', theta);
    lines = houghlines(CE,theta,rho,P,'MinLength', width/6);
    
    if isempty(lines)
        L = 0;
        DC = [1, 1];
        PH = 0;
        return;
    end

    p1 = struct2table(lines).point1(1,:);
    p2 = struct2table(lines).point2(1,:);
    
    L = pdist([p1; p2],'euclidean')/width;
    DC = (p1 + p2)/(2 * width);
    PH = H(P(1),P(2))/width;
end