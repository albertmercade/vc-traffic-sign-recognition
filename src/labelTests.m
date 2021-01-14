function [predictedLabels, expectedLabels] = labelTests(filePattern)
    theFiles = dir(filePattern);

    predictedLabels = zeros(length(theFiles), 1, 'single');
    expectedLabels = zeros(length(theFiles), 1, 'single');
    
    for k = 1 : length(theFiles)
        baseFileName = theFiles(k).name;
        fullFileName = fullfile(theFiles(k).folder, baseFileName);
        
        splited = split(fullFileName, ["/", "."]);
        cat = str2double(cell2mat(splited(end-3)));
        expectedLabels(k) = cat;
        
        disp(fullFileName);

        I = imread(fullFileName);
        predictedLabels(k) = labelSignal(I);
    end
end
