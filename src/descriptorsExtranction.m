function [desc] = descriptorsExtranction(I) 

    I = preprocess(I);
    %I = resizeImage(I);
    desc = descriptors(I);
    
end