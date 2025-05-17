function mat = my_fast_detector(fig)

    fig = rgb2gray(fig);
    [height, width] = size(fig)

    figl = zeros(756,width+6);
    figl(4:753, 4:width+3) = fig;

    mat = zeros(750, width);

    thresh = 10;

    p = zeros(750, width, 16);

    p(:,:,1) = abs(figl(1:end-6, 4:end-3) - figl(4:end-3, 4:end-3));
    p(:,:,2) = abs(figl(1:end-6, 5:end-2) - figl(4:end-3, 4:end-3));
    p(:,:,3) = abs(figl(2:end-5, 6:end-1) - figl(4:end-3, 4:end-3));
    p(:,:,4) = abs(figl(3:end-4, 7:end) - figl(4:end-3, 4:end-3));
    p(:,:,5) = abs(figl(4:end-3, 7:end) - figl(4:end-3, 4:end-3));
    p(:,:,6) = abs(figl(5:end-2, 7:end) - figl(4:end-3, 4:end-3));
    p(:,:,7) = abs(figl(6:end-1, 6:end-1) - figl(4:end-3, 4:end-3));
    p(:,:,8) = abs(figl(7:end, 5:end-2) - figl(4:end-3, 4:end-3));
    p(:,:,9) = abs(figl(7:end, 4:end-3) - figl(4:end-3, 4:end-3));
    p(:,:,10) = abs(figl(7:end, 3:end-4) - figl(4:end-3, 4:end-3));
    p(:,:,11) = abs(figl(6:end-1, 2:end-5) - figl(4:end-3, 4:end-3));
    p(:,:,12) = abs(figl(5:end-2, 1:end-6) - figl(4:end-3, 4:end-3));
    p(:,:,13) = abs(figl(4:end-3, 1:end-6) - figl(4:end-3, 4:end-3));
    p(:,:,14) = abs(figl(3:end-4, 1:end-6) - figl(4:end-3, 4:end-3));
    p(:,:,15) = abs(figl(2:end-5, 2:end-5) - figl(4:end-3, 4:end-3));
    p(:,:,16) = abs(figl(1:end-6, 3:end-4) - figl(4:end-3, 4:end-3));
    p = p > thresh;
    mat = sum(p, 3);
    mat = mat > 15;
end