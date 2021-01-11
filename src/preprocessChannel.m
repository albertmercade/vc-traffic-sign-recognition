function img = preprocessChannel(channel)
    aux = imopen(channel,strel('disk', 1));
    aux = imclearborder(aux,4);
    aux = imclose(aux,strel('disk', 2));
    aux = imfill(aux, 'holes');
    img = bwareafilt(aux,1);
end