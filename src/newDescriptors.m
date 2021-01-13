function [desc] = newDescriptors(I)
    G = rgb2gray(I);
    
    desc = descriptorTriangle(G);
    [desc] = descriptorCircle(desc, G);
    
    [mask, colors] = maskFinder(I);    
    desc = descriptorColors(desc, colors, mask);
end