% Calcula accuracy i matrius de confusio pels models

load('models.mat'); % carrega de models

%% Classificador combinar
% expected i predict del combinat (triga molt en calcular)
load('expect.mat'); 
load('pred.mat');
% (Per calcular fer servir testModelComplet.m

confMat = confusionmat(expectedLabels, predictedLabels);
sum(expectedLabels == predictedLabels)/size(expectedLabels,1);


%% Classificador general
test_data = readtable('test_desc.csv');

% convetim strings a nombres
categories = ["speed", "speed", "speed", "speed", "speed", "speed", "end", "speed", ...
    "speed", "pass", "pass", "tri", "sq", "ceda", "stop", "emptyC", "speed", ...
    "direcPro", "tri", "tri", "tri", "tri", "tri", "tri", "tri", "tri", "triS", ...
    "tri", "tri", "tri", "tri", "tri", "end", "direc", "direc", "direc", ...
    "direc", "direc", "direc", "direc", "direc", "end", "end"];

[categories, gNames, gL] = grp2idx(categories);
test_data.GeneralSign = arrayfun(@(x) categories(x+1), test_data.Sign);

confMatGeneral = confusionmat(test_data.GeneralSign, label);
sum(test_data.GeneralSign == label)/size(label,1);


%% Classificadors de HOG
hog_test = readmatrix('test_hog.csv');

% Cercles vermells
gNames(1)
[expected, label] = labelHOGtest(modelRedC, hog_test, [0:5, 7,8, 16]);
confMatRedC = confusionmat(expected, label);
accuracyRedC = sum(expected == label)/size(label,1);

% Cercles blancs
gNames(2)
[expected, label] = labelHOGtest(modelCircleEnd, hog_test, [6,32,41,42]);
confMatWhiteC = confusionmat(expected, label);
accuracyWhiteC = sum(expected == label)/size(label,1);

% Triangles
gNames(4)
[expected, label] = labelHOGtest(modelTriangle, hog_test, [11,18:31]);
confMatTri = confusionmat(expected, label);
accuracyTri = sum(expected == label)/size(label,1);

% Cercles blaus
gNames(11)
[expected, label] = labelHOGtest(modelBlueC, hog_test, [33:40]);
confMatBlueC = confusionmat(expected, label);
accuracyBlueC = sum(expected == label)/size(label,1);