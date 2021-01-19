% Genera descriptors per la imatge donada

function [desc, mask, colors] = descriptors(I)
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

function desc = descriptorColors(desc, colors, mask)
    areaMask = sum(sum(mask));
    if areaMask == 0
        areaMask = 1;
    end

    names = ["white", "black"];
    for i = 1:length(names)
        C = colors.(names(i)) & mask;

        C = bwareafilt(C, 4);

        rp = regionprops(C, ...
        'Centroid', 'Solidity', 'Eccentricity', 'EulerNumber', 'Extent', 'Area');

        desc.numel = size(rp,1);

        for j = 1:4
            desc.(names(i)+"CentroidDistance"+int2str(j)) = -1;
            desc.(names(i)+"Solidity"+int2str(j)) = 2;
            desc.(names(i)+"Eccentricity"+int2str(j)) = 2;
            desc.(names(i)+"EulerNumber"+int2str(j)) = 2;
            desc.(names(i)+"Extent"+int2str(j)) = 0;
            desc.(names(i)+"Coverage"+int2str(j)) = 0;
        end

        rpAux = struct2array(rp);
        rpAux = reshape(rpAux,7,[])';
        for j = 1:size(rpAux,1)
            desc.(names(i)+"CentroidDistance"+int2str(j)) = pdist([rpAux(j,2:3);size(C)/2],'euclidean')/size(C,2);
            desc.(names(i)+"Solidity"+int2str(j)) = rpAux(j,7);
            desc.(names(i)+"Eccentricity"+int2str(j)) = rpAux(j,4);
            desc.(names(i)+"EulerNumber"+int2str(j)) = rpAux(j,5);
            desc.(names(i)+"Extent"+int2str(j)) = rpAux(j,6);
            desc.(names(i)+"Coverage"+int2str(j)) = rpAux(j,1)/areaMask;
        end
    end

    names = ["blue", "red"];
    for i = 1:length(names)
        C = colors.(names(i)) & mask;

        C = bwareafilt(C, 1);

        rp = regionprops(C, ...
        'Centroid', 'Solidity', 'Eccentricity', 'EulerNumber', 'Extent', 'Area');

        if isempty(rp)
            desc.(names(i)+"CentroidDistance") = -1;
            desc.(names(i)+"Solidity") = 2;
            desc.(names(i)+"Eccentricity") = 2;
            desc.(names(i)+"EulerNumber") = 2;
            desc.(names(i)+"Extent") = 0;
            desc.(names(i)+"Coverage") = 0;
            continue;
        end

        rpAux = struct2array(rp);

        desc.(names(i)+"CentroidDistance") = pdist([rpAux(2:3);size(C)/2],'euclidean')/size(C,2);
        desc.(names(i)+"Solidity") = rpAux(5);
        desc.(names(i)+"Eccentricity") = rpAux(4);
        desc.(names(i)+"EulerNumber") = rpAux(5);
        desc.(names(i)+"Extent") = rpAux(6);
        desc.(names(i)+"Coverage") = rpAux(1)/areaMask;
    end
end

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
