function resizedI = resizeImage(I)
    colors = splitColor(I);
    
    maxArea = 0;
    bb = [1 1 1 1];
    for i = 1 : 3;
       rC = preprocessChannel(colors(:,:,i));
       rp = regionprops(rC, 'Area', 'BoundingBox');
       if isempty(rp)
           continue
       end
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