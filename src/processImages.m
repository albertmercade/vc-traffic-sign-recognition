warning('off', 'images:bwfilt:tie');

desc = ["Circularity", "Eccentricity", "EulerNumber", "Extent", "numPeaks", "maxMinDiff", "ratioArea"];
colors = ["red", "blue", "yellow", "black", "white"];

[m, n] = ndgrid(desc, colors);
varNames = join([n(:), m(:)], '_');
varNames(end+1) = "Sign";

trainPattern = fullfile('../images/Train/**', '*.png');
train = processFolder(trainPattern);

train = array2table(train);
train.Properties.VariableNames = varNames;
writetable(train, 'train_desc.csv');

testPattern = fullfile('../images/Test/**', '*.png');
test = processFolder(testPattern);

test = array2table(test);
test.Properties.VariableNames = varNames;

writetable(test, 'test_desc.csv');
