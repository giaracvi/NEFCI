function writeColorMap(im,namePath)
    % Create indexed image, explicitly using 256 colors
    imInd=gray2ind(im,256);
    % Convert indexed image to RGB using 256-colors jet map
    hotRGB=ind2rgb(imInd,hot(256));
    % Save image
    imwrite(hotRGB,namePath);
end