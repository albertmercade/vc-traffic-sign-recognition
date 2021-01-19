% Clasifica la imatge

% finalLabel es la label final
% label es la intermitja (classificador general)

function [finalLabel, label] = labelSignal(I, model)

    categories = ["speed", "speed", "speed", "speed", "speed", "speed", "end", "speed", ...
        "speed", "pass", "pass", "tri", "sq", "ceda", "stop", "emptyC", "speed", ...
        "direcPro", "tri", "tri", "tri", "tri", "tri", "tri", "tri", "tri", "triS", ...
        "tri", "tri", "tri", "tri", "tri", "end", "direc", "direc", "direc", ...
        "direc", "direc", "direc", "direc", "direc", "end", "end"];

    [~, gNames] = grp2idx(categories);

    I = preprocess(I);

    desc = descriptors(I);
    desc = struct2table(desc, 'AsArray', true);

    label = model.General.predictFcn(desc);

    label = string(gNames(label));

    if label == "speed"
        finalLabel = labelRefine(I, model.RedC, "black");
    elseif label == "end"
        finalLabel = labelRefine(I, model.CircleEnd, "black");
    elseif label == "pass"
        % TODO
        finalLabel = 9;
    elseif label == "tri"
        finalLabel = labelRefine(I, model.Triangle, "black");
    elseif label == "sq"
        finalLabel = 12;
    elseif label == "ceda"
        finalLabel = 13;
    elseif label == "stop"
        finalLabel = 14;
    elseif label == "emptyC"
        finalLabel = 15;
    elseif label == "direcPro"
        finalLabel = 17;
    elseif label == "triS"
        finalLabel = 26;
    elseif label == "direc"
        finalLabel = labelRefine(I, model.BlueC, "white");
    else
        finalLabel = 404;
        warning("404 - Not Found")
        return
    end
end

function finalLabel = labelRefine(I, model, color)
    [mask, colors] = maskFinder(I);
    features = hogDesc(mask, colors.(color));
    finalLabel = model.predictFcn(features);
end
