trainPattern = fullfile('../images/Train/**', '*.png');
train = allFeatures(trainPattern);
writematrix(train, 'train_desc_all.csv');

testPattern = fullfile('../images/Test/**', '*.png');
test = allFeatures(testPattern);
writematrix(test, 'test_desc_all.csv');