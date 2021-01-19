function [M] = allFeatures(filePattern)
    theFiles = dir(filePattern);

    hogBlack = zeros(length(theFiles), 900, 'single');
    hogWhite = zeros(length(theFiles), 900, 'single');
    shapeDesc = zeros(length(theFiles), 77, 'single');
    trainingLabels = zeros(length(theFiles), 1, 'single');

    parfor k = 1 : length(theFiles)
        baseFileName = theFiles(k).name;
        fullFileName = fullfile(theFiles(k).folder, baseFileName);

        splited = split(fullFileName, ["/", "."]);
        cat = str2double(cell2mat(splited(end-3)));
        trainingLabels(k) = cat;

        disp(fullFileName)

        I = imread(fullFileName);
        I = preprocess(I);

        [desc, mask, colors] = descriptors(I);

        shapeDesc(k, :) = struct2array(desc)';

        hogBlack(k, :) = hogDesc(mask, colors.black);
        hogWhite(k, :) = hogDesc(mask, colors.black);
    end

    M = [shapeDesc, hogBlack, hogWhite, trainingLabels];
end
