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
            bg = shit.(names(i)).bg;
            gNames = string(fieldnames(fg));
            for j = 1:length(gNames)
                
                if isempty(bg)
                    bgShit = {};
                else
                    bgShit = bg.(gNames(j));
                end
                if isempty(fg)
                    fgShit = {};
                else
                    fgShit = fg.(gNames(j));
                end
                flat.(names(i) + "_fg_" + gNames(j)) = fgShit;
                flat.(names(i) + "_bg_" + gNames(j)) = bgShit;
            end
        end
    end
end