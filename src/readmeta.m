function I = readmeta(i)    
    filename = sprintf('../images/Meta/%d.png', i);
    I = imread(filename);
end

