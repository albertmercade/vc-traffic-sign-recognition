function display_split(I)
    II = preprocess(I);
    [mask, colors] = maskFinder(II);
    montage({I, II, colors.black, colors.red, colors.blue, colors.white, mask})
end