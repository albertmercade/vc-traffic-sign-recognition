% Llegeix una imatge i la passa a labelSignal per clasficar
% despres mostra el resultat

warning('off', 'images:bwfilt:tie');

disp("loading models...")
tic
load('model_combined.mat', 'model');
toc
disp("models loaded")

while true
    pause
    select_and_label(model)
end

function select_and_label(model)
    file = uigetimagefile();
    I = imread(file);
    display_split(I);
    [final, mid] = labelSignal(I, model);

    fprintf("%s\n", file);
    fprintf("Label = %d; (%s) \n", final, mid);
end