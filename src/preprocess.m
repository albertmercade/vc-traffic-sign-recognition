function O = preprocess(I)
    A = imcomplement(I);
    % B = imreducehaze(A, 'ContrastEnhancement', 'none');
    B = imreducehaze(A, 'Method','approx','ContrastEnhancement','boost');
    O = imcomplement(B);
end

