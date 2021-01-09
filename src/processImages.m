filePattern = fullfile('../images/Train/**', '*.png');
theFiles = dir(filePattern);

M = zeros(length(theFiles), 30);

for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    
    disp(fullFileName)
    
    I = imread(fullFileName);

    desc = descriptorsExtranction(I);
    desc = reshape(cell2mat(struct2cell(desc)), 1, []);
    
    M(k,:) = desc;
end

writematrix(M, 'M.csv')