function displayChannels(I)
    [red, blue, yellow, black, white] = splitColor(I);
    montage({red, blue, yellow, black, white}, "Size", [1, 5]);
end