function trainingFeatures = hogDesc(mask, C)        
    C = mask & C;
    C = imresize(C, [50 50]);
    trainingFeatures = extractHOGFeatures(C,'CellSize',[8 8]);
end