warning('off', 'images:bwfilt:tie');

trainPattern = fullfile('../images/Train/**', '*.png');
train = processFolder(trainPattern);
writematrix(train, 'train_desc.csv');

testPattern = fullfile('../images/Test/**', '*.png');
test = processFolder(testPattern);
writematrix(test, 'test_desc.csv');