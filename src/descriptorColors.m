function desc = descriptorColors(desc, colors, mask)
    names = ["white", "black"];
    for i = 1:length(names)
        C = colors.(names(i)) & mask;
        
        C = bwareafilt(C, 4);
        
        rp = regionprops(C, ...
        'Centroid', 'Solidity', 'Eccentricity', 'EulerNumber', 'Extent');
    
        desc.numel = size(rp,1);

        for j = 1:4
            desc.(names(i)+"CentroidDistance"+int2str(j)) = -1;
            desc.(names(i)+"Solidity"+int2str(j)) = 2;
            desc.(names(i)+"Eccentricity"+int2str(j)) = 2;
            desc.(names(i)+"EulerNumber"+int2str(j)) = 2;
            desc.(names(i)+"Extent"+int2str(j)) = 0;
        end

        rpAux = struct2array(rp);
        rpAux = reshape(rpAux,6,[])';
        for j = 1:size(rpAux,1)
            desc.(names(i)+"CentroidDistance"+int2str(j)) = pdist([rpAux(j,1:2);size(C)/2],'euclidean')/size(C,2);
            desc.(names(i)+"Solidity"+int2str(j)) = rpAux(j,6);
            desc.(names(i)+"Eccentricity"+int2str(j)) = rpAux(j,3);
            desc.(names(i)+"EulerNumber"+int2str(j)) = rpAux(j,4);
            desc.(names(i)+"Extent"+int2str(j)) = rpAux(j,5);
        end
    end
    
    names = ["blue", "red"];
    for i = 1:length(names)
        C = colors.(names(i)) & mask;
        
        C = bwareafilt(C, 1);
        
        rp = regionprops(C, ...
        'Centroid', 'Solidity', 'Eccentricity', 'EulerNumber', 'Extent');
    
        if isempty(rp)
            desc.(names(i)+"CentroidDistance") = -1;
            desc.(names(i)+"Solidity") = 2;
            desc.(names(i)+"Eccentricity") = 2;
            desc.(names(i)+"EulerNumber") = 2;
            desc.(names(i)+"Extent") = 0;
            continue;
        end
        
        rpAux = struct2array(rp);
    
        desc.(names(i)+"CentroidDistance") = pdist([rpAux(1:2);size(C)/2],'euclidean')/size(C,2);
        desc.(names(i)+"Solidity") = rpAux(6);
        desc.(names(i)+"Eccentricity") = rpAux(3);
        desc.(names(i)+"EulerNumber") = rpAux(4);
        desc.(names(i)+"Extent") = rpAux(5);
    end
end