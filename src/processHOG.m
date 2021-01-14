trainPattern = fullfile('../images/Train/**', '*.png');
[train, trainLabels] = HOGFeatures(trainPattern);
writematrix([train, trainLabels], 'train_hog.csv');

testPattern = fullfile('../images/Test/**', '*.png');
[test, testLabels] = HOGFeatures(testPattern);
writematrix([test, testLabels], 'test_hog.csv');
