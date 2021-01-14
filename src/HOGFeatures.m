function [trainingFeatures, trainingLabels] = HOGFeatures(filePattern)
    theFiles = dir(filePattern);

    trainingFeatures = zeros(length(theFiles), 900, 'single');
    trainingLabels = zeros(length(theFiles), 1, 'single');
    
    parfor k = 1 : length(theFiles)
        baseFileName = theFiles(k).name;
        fullFileName = fullfile(theFiles(k).folder, baseFileName);
        
        splited = split(fullFileName, ["/", "."]);
        cat = str2double(cell2mat(splited(end-3)));
        trainingLabels(k) = cat;

        if ismember(cat, [0:5, 7:10, 16])
            C = "black";
        elseif ismember(cat, [6, 32, 41,42])
            C = "black";
        elseif ismember(cat, [11, 18:31])
            C = "black";
        elseif ismember(cat, 33:40)
            C = "white";
        else
            disp(fullFileName + " SKIP")
            continue
        end

        disp(fullFileName)
        
        I = imread(fullFileName);
        I = preprocess(I);
        [mask, colors] = maskFinder(I);
        trainingFeatures(k, :) = hogDesc(mask, colors.(C));
    end
end


