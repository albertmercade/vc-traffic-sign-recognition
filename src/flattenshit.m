function flat = flattenshit(shit)
    names = string(fieldnames(shit));
    for i = 1:length(names)
        if names(i) == "shape"
            shapes = shit.(names(i));
            shapeNames = string(fieldnames(shapes));
            for j = 1:length(shapeNames)
                flat.("shape_" + shapeNames(j)) = shapes.(shapeNames(j));
            end
        else
            fg = shit.(names(i)).fg;
            fgNames = string(fieldnames(fg));
            for j = 1:length(fgNames)
                if isempty(fg)
                    fgShit = {};
                else
                    fgShit = fg.(fgNames(j));
                end
                flat.(names(i) + "_fg_" + fgNames(j)) = fgShit;
            end
            
            bg = shit.(names(i)).bg;
            bgNames = string(fieldnames(bg));
            for j = 1:length(bgNames)
                if isempty(bg)
                    bgShit = {};
                else
                    bgShit = bg.(bgNames(j));
                end
                flat.(names(i) + "_bg_" + bgNames(j)) = bgShit;
            end
        end
    end
end