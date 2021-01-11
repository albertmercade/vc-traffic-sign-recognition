function [desc] = descriptorsExtranction(I, prominenceTh) 
    if nargin < 2
        prominenceTh = 0.03;
    end

    I = preprocess(I);
    I = resizeImage(I);
    
    colors = splitColor(I);
    
    desc = descriptors(colors(:,:,1), prominenceTh);
    for i = 2 : size(colors,3)
       rp = descriptors(colors(:,:,i), prominenceTh);
       desc(i) = rp;
    end
end