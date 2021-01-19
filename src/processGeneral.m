trainPattern = fullfile('../images/Train/**', '*.png');
train = processFolder(trainPattern);
writetable(train, 'train_desc.csv');

testPattern = fullfile('../images/Test/**', '*.png');
test = processFolder(testPattern);
writetable(test, 'test_desc.csv');
