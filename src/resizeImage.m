function resizedI = resizeImage(I)
    colors = splitColors(I);
    
    maxArea = 0;
    bb = [];
    for i = 1 : size(colors,3)
       rC = preprocessChannel(colors(:,:,i));
       rp = regionprops(rC, 'Area', 'BoundingBox');
       if (rp.Area > maxArea)
           maxArea = rp.Area;
           bb = rp.BoundingBox;
       end
    end
    
    height = size(I,1);
    width = size(I, 2);

    newWidth = int16(bb(3)/bb(4) * width);

    resizedI = imresize(I,[height, newWidth]);
end