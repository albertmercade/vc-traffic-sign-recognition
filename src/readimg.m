function I = readimg(sign, n, frame)
    if nargin < 3
        frame = 0;
    end
    
    if sign <= 17
        train = 1;
    else
        train = 2;
    end
    
    filename = sprintf('../images/Train%d/%d/%05d_%05d_%05d.png', ...
        train, sign, sign, n, frame);
    I = imread(filename);
end