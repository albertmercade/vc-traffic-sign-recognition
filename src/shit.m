load('models.mat');

categories = ["speed", "speed", "speed", "speed", "speed", "speed", "end", "speed", ...
    "speed", "pass", "pass", "tri", "sq", "ceda", "stop", "emptyC", "speed", ...
    "direcPro", "tri", "tri", "tri", "tri", "tri", "tri", "tri", "tri", "triS", ...
    "tri", "tri", "tri", "tri", "tri", "end", "direc", "direc", "direc", ...
    "direc", "direc", "direc", "direc", "direc", "end", "end"];

[categories, gNames, gL] = grp2idx(categories);

testPattern = fullfile('../images/Test/**', '*.png');

theFiles = dir(testPattern);

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

    I = preprocess(I);

    desc = newDescriptors(I);
    desc = struct2table(desc, 'AsArray', true);

    label = modelGeneral.predictFcn(desc);

    label = string(gNames(label));

    if label == "speed"
        finalLabel = modelRedC.predictFcn(getFeat(I, "black"));
    elseif label == "end"
        finalLabel = modelCircleEnd.predictFcn(getFeat(I, "black"));
    elseif label == "pass"
        % TODO
        finalLabel = 9;
    elseif label == "tri"
        finalLabel = modelTriangle.predictFcn(getFeat(I, "black"));
    elseif label == "sq"
        finalLabel = 12;
    elseif label == "ceda"
        finalLabel = 13;
    elseif label == "stop"
        finalLabel = 14;
    elseif label == "emptyC"
        finalLabel = 15;
    elseif label == "direcPro"
        finalLabel = 17;
    elseif label == "triS"
        finalLabel = 26;
    elseif label == "direc"
        finalLabel = modelCircleEnd.predictFcn(getFeat(I, "white"));
    else
        predictedLabels(k) = 404;
        warning("404 - Not Found")
        continue
    end

    predictedLabels(k) = finalLabel;
end

writematrix(predictedLabels, 'predlabels.csv');
writematrix(expectedLabels, 'expectedlabels.csv');

function feat = getFeat(I, color)
    [mask, colors] = maskFinder(I);
    feat = hogDesc(mask, colors.(color));
end
