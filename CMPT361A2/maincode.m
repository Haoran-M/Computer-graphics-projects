
% pleasue run code by sections
%part1
fig1 = imread('S1-im1.png');
fig2 = imread("S2-im1.png");

mat1 = my_fast_detector(fig1);
mat2 = my_fast_detector(fig2);


figure;
imshow(fig1);
hold on;
[y1, x1] = find(mat1);
plot(x1, y1, 'r*', 'MarkerSize', 5); 
hold off;
saveas(gcf, 'S1-fast.png');

figure;
imshow(fig2);
hold on;
[y2, x2] = find(mat2); 
plot(x2, y2, 'r*', 'MarkerSize', 5); 
hold off;
saveas(gcf, 'S2-fast.png');


%% FASTR

fig1 = imread('S1-im1.png'); 
fig2 = imread('S2-im1.png'); 

process_image(fig1, 'S1');
process_image(fig2, 'S2');


function process_image(fig, image_name)
    fast_points = my_fast_detector(fig);

    [Ix, Iy] = gradient(double(rgb2gray(fig)));
    Ixx = Ix.^2;
    Iyy = Iy.^2;
    Ixy = Ix .* Iy;

    window = fspecial('gaussian', [3 3], 1);
    Sxx = conv2(Ixx, window, 'same');
    Syy = conv2(Iyy, window, 'same');
    Sxy = conv2(Ixy, window, 'same');

    k = 0.04; 
    detM = (Sxx .* Syy) - (Sxy.^2);
    traceM = Sxx + Syy;
    R = detM - k * (traceM).^2;

    harris_thresh = 1e6;
    fastr_points = (R > harris_thresh) & fast_points;

    [y_fast, x_fast] = find(fast_points); 
    [y_fastr, x_fastr] = find(fastr_points);

    figure;
    subplot(1, 2, 1);
    imshow(fig);
    hold on;
    plot(x_fast, y_fast, 'go', 'MarkerSize', 5, 'LineWidth', 1.5); 
    title([image_name ' - FAST Points']);
    hold off;

    subplot(1, 2, 2);
    imshow(fig);
    hold on;
    plot(x_fastr, y_fastr, 'ro', 'MarkerSize', 5, 'LineWidth', 1.5);  
    title([image_name ' - FASTR Points']);
    hold off;

    saveas(gcf, [image_name '-fastR.png']); 

    tic;
    my_fast_detector(fig); 
    fast_time = toc;

    tic;
    fastr_points = (R > harris_thresh) & fast_points;
    fastr_time = toc;

    fprintf('Average computation time - %s (FAST): %.4f seconds\n', image_name, fast_time);
    fprintf('Average computation time - %s (FASTR): %.4f seconds\n', image_name, fastr_time);
end


%% FAST and FASTR matching

image1 = imread('S1-im1.png');
image2 = imread('S1-im2.png');
grayimage1 = rgb2gray(image1);
grayimage2 = rgb2gray(image2);


fastPoints1 = my_fast_detector(image1); 
fastPoints2 = my_fast_detector(image2);

[y1, x1] = find(fastPoints1); 
[y2, x2] = find(fastPoints2);

keypoints1 = [x1, y1];
keypoints2 = [x2, y2];
orbPoints1 = ORBPoints(keypoints1);
orbPoints2 = ORBPoints(keypoints2);

[features1, validPoints1] = extractFeatures(grayimage1, orbPoints1, 'Method', 'ORB');
[features2, validPoints2] = extractFeatures(grayimage2, orbPoints2, 'Method', 'ORB');

indexPairs = matchFeatures(features1, features2);
matchedPoints1 = validPoints1(indexPairs(:, 1), :);
matchedPoints2 = validPoints2(indexPairs(:, 2), :);

figure; ax = axes;
showMatchedFeatures(grayimage1, grayimage2, matchedPoints1, matchedPoints2, 'montage', 'Parent', ax);
title('Matched Points between Image 1 and Image 2');
legend('Matched Points in Image 1', 'Matched Points in Image 2');
saveas(gcf, 'S1-fastMatch.png');



    [Ix1, Iy1] = gradient(double(rgb2gray(image1)));
    Ixx1 = Ix1.^2;
    Iyy1 = Iy1.^2;
    Ixy1 = Ix1 .* Iy1;

    [Ix2, Iy2] = gradient(double(rgb2gray(image2)));
    Ixx2 = Ix2.^2;
    Iyy2 = Iy2.^2;
    Ixy2 = Ix2 .* Iy2;

    window = fspecial('gaussian', [3 3], 1);
    Sxx1 = conv2(Ixx1, window, 'same');
    Syy1 = conv2(Iyy1, window, 'same');
    Sxy1 = conv2(Ixy1, window, 'same');
    Sxx2 = conv2(Ixx2, window, 'same');
    Syy2 = conv2(Iyy2, window, 'same');
    Sxy2 = conv2(Ixy2, window, 'same');


    k = 0.04; 
    detM1 = (Sxx1 .* Syy1) - (Sxy1.^2);
    traceM1 = Sxx1 + Syy1;
    R1 = detM1 - k * (traceM1).^2;
    harris_thresh = 1e2;
    fastr_points1 = (R1 > harris_thresh) & fastPoints1; 
    [y_fastr1, x_fastr1] = find(fastr_points1);
    keyRpoints1 = [y_fastr1, x_fastr1];
    orbRPoints1 = ORBPoints(keyRpoints1);

    detM2 = (Sxx2 .* Syy2) - (Sxy2.^2);
    traceM2 = Sxx2 + Syy2;
    R2 = detM2 - k * (traceM2).^2;
    fastr_points2 = (R2 > harris_thresh) & fastPoints2; 
    [y_fastr2, x_fastr2] = find(fastr_points2);
    keyRpoints2 = [y_fastr2, x_fastr2];
    orbRPoints2 = ORBPoints(keyRpoints2);
[rfeatures1, rvalidPoints1] = extractFeatures(grayimage1, orbRPoints1, 'Method', 'ORB');
[rfeatures2, rvalidPoints2] = extractFeatures(grayimage2, orbRPoints2, 'Method', 'ORB');
indexRPairs = matchFeatures(rfeatures1, rfeatures2);
rmatchedPoints1 = rvalidPoints1(indexRPairs(:, 1), :);
rmatchedPoints2 = rvalidPoints2(indexRPairs(:, 2), :);

figure; ax = axes;
showMatchedFeatures(grayimage1, grayimage2, rmatchedPoints1, rmatchedPoints2, 'montage', 'Parent', ax);
title('Matched Points between Image 1 and Image 2');
legend('Matched Points in Image 1', 'Matched Points in Image 2');
saveas(gcf, 'S1-fastRMatch.png');


%%  FAST and FASTR matching for S2

image1 = imread('S2-im1.png');
image2 = imread('S2-im2.png');
grayimage1 = rgb2gray(image1);
grayimage2 = rgb2gray(image2);


fastPoints1 = my_fast_detector(image1); 
fastPoints2 = my_fast_detector(image2);

[y1, x1] = find(fastPoints1); 
[y2, x2] = find(fastPoints2);

keypoints1 = [x1, y1];
keypoints2 = [x2, y2];
orbPoints1 = ORBPoints(keypoints1);
orbPoints2 = ORBPoints(keypoints2);

[features1, validPoints1] = extractFeatures(grayimage1, orbPoints1, 'Method', 'ORB');
[features2, validPoints2] = extractFeatures(grayimage2, orbPoints2, 'Method', 'ORB');

indexPairs = matchFeatures(features1, features2);
matchedPoints1 = validPoints1(indexPairs(:, 1), :);
matchedPoints2 = validPoints2(indexPairs(:, 2), :);

figure; ax = axes;
showMatchedFeatures(grayimage1, grayimage2, matchedPoints1, matchedPoints2, 'montage', 'Parent', ax);
title('Matched Points between Image 1 and Image 2');
legend('Matched Points in Image 1', 'Matched Points in Image 2');
saveas(gcf, 'S2-fastMatch.png');



    [Ix1, Iy1] = gradient(double(rgb2gray(image1)));
    Ixx1 = Ix1.^2;
    Iyy1 = Iy1.^2;
    Ixy1 = Ix1 .* Iy1;

    [Ix2, Iy2] = gradient(double(rgb2gray(image2)));
    Ixx2 = Ix2.^2;
    Iyy2 = Iy2.^2;
    Ixy2 = Ix2 .* Iy2;

    window = fspecial('gaussian', [3 3], 1);
    Sxx1 = conv2(Ixx1, window, 'same');
    Syy1 = conv2(Iyy1, window, 'same');
    Sxy1 = conv2(Ixy1, window, 'same');
    Sxx2 = conv2(Ixx2, window, 'same');
    Syy2 = conv2(Iyy2, window, 'same');
    Sxy2 = conv2(Ixy2, window, 'same');


    k = 0.04; 
    detM1 = (Sxx1 .* Syy1) - (Sxy1.^2);
    traceM1 = Sxx1 + Syy1;
    R1 = detM1 - k * (traceM1).^2;
    harris_thresh = 1e2;
    fastr_points1 = (R1 > harris_thresh) & fastPoints1; 
    [y_fastr1, x_fastr1] = find(fastr_points1);
    keyRpoints1 = [y_fastr1, x_fastr1];
    orbRPoints1 = ORBPoints(keyRpoints1);

    detM2 = (Sxx2 .* Syy2) - (Sxy2.^2);
    traceM2 = Sxx2 + Syy2;
    R2 = detM2 - k * (traceM2).^2;
    fastr_points2 = (R2 > harris_thresh) & fastPoints2; 
    [y_fastr2, x_fastr2] = find(fastr_points2);
    keyRpoints2 = [y_fastr2, x_fastr2];
    orbRPoints2 = ORBPoints(keyRpoints2);
[rfeatures1, rvalidPoints1] = extractFeatures(grayimage1, orbRPoints1, 'Method', 'ORB');
[rfeatures2, rvalidPoints2] = extractFeatures(grayimage2, orbRPoints2, 'Method', 'ORB');
indexRPairs = matchFeatures(rfeatures1, rfeatures2);
rmatchedPoints1 = rvalidPoints1(indexRPairs(:, 1), :);
rmatchedPoints2 = rvalidPoints2(indexRPairs(:, 2), :);

figure; ax = axes;
showMatchedFeatures(grayimage1, grayimage2, rmatchedPoints1, rmatchedPoints2, 'montage', 'Parent', ax);
title('Matched Points between Image 1 and Image 2');
legend('Matched Points in Image 1', 'Matched Points in Image 2');
saveas(gcf, 'S2-fastRMatch.png');


%% RANSC and panorama 
function panorama = stitchImages(image1, image2, tform)
    [h1, w1, ~] = size(image1);
    [h2, w2, ~] = size(image2);

    [xlim1, ylim1] = outputLimits(tform, [1 w2], [1 h2]);
    
    xMin = min(1, xlim1(1));
    xMax = max(w1, xlim1(2));
    yMin = min(1, ylim1(1));
    yMax = max(h1, ylim1(2));

    width = round(xMax - xMin);
    height = round(yMax - yMin);

    panorama = zeros([height, width, 3], 'like', image1);
    
    panoramaView = imref2d([height, width], [xMin, xMax], [yMin, yMax]);

    warpedImage1 = imwarp(image1, projective2d(eye(3)), 'OutputView', panoramaView);
    warpedImage2 = imwarp(image2, tform, 'OutputView', panoramaView);
    
    mask1 = imwarp(true(size(image1, 1), size(image1, 2)), projective2d(eye(3)), 'OutputView', panoramaView);
    mask2 = imwarp(true(size(image2, 1), size(image2, 2)), tform, 'OutputView', panoramaView);

    panorama = imblend(warpedImage1, panorama, mask1, 'ForegroundOpacity', 1);
    panorama = imblend(warpedImage2, panorama, mask2, 'ForegroundOpacity', 1);
end


function createFastRPanorama(image1Path, image2Path, outputPath)
    image1 = imread(image1Path);
    image2 = imread(image2Path);

    grayImage1 = im2gray(image1);
    grayImage2 = im2gray(image2);

    orbRPoints1 = detectFastrPoints(grayImage1, my_fast_detector(image1));
    orbRPoints2 = detectFastrPoints(grayImage2, my_fast_detector(image2));

    [rfeatures1, rvalidPoints1] = extractFeatures(grayImage1, orbRPoints1, 'Method', 'ORB');
    [rfeatures2, rvalidPoints2] = extractFeatures(grayImage2, orbRPoints2, 'Method', 'ORB');

    indexRPairs = matchFeatures(rfeatures1, rfeatures2, 'Unique', true);
    rmatchedPoints1 = rvalidPoints1(indexRPairs(:, 1), :);
    rmatchedPoints2 = rvalidPoints2(indexRPairs(:, 2), :);

    rtform = estimateGeometricTransform2D(rmatchedPoints2, rmatchedPoints1, 'projective', ...
                                          'Confidence', 99.9, 'MaxNumTrials', 2000);

    rpanorama = stitchImages(image1, image2, rtform);

    figure;
    imshow(rpanorama);
    title('Panorama using FASTR Keypoints');
    saveas(gcf, outputPath);
end

function orbPoints = detectFastrPoints(grayImage, fastPoints)

    [Ix, Iy] = gradient(double(grayImage));
    Ixx = Ix.^2;
    Iyy = Iy.^2;
    Ixy = Ix .* Iy;

    window = fspecial('gaussian', [3 3], 1);
    Sxx = conv2(Ixx, window, 'same');
    Syy = conv2(Iyy, window, 'same');
    Sxy = conv2(Ixy, window, 'same');

    detM = (Sxx .* Syy) - (Sxy.^2);
    traceM = Sxx + Syy;
    k = 0.04;
    R = detM - k * (traceM).^2;

    harris_thresh = 1e2;
    fastrPoints = (R > harris_thresh) & fastPoints;

    [y, x] = find(fastrPoints);
    orbPoints = ORBPoints([x, y]);
end

createFastRPanorama('S1-im1.png', 'S1-im2.png', 'S1-panorama.png');
createFastRPanorama('S2-im1.png', 'S2-im2.png', 'S2-panorama.png');
createFastRPanorama('S3-im1.png', 'S3-im2.png', 'S3-panorama.png');
createFastRPanorama('S4-im1.png', 'S4-im2.png', 'S4-panorama.png');


%% 4 Image Stitching

function createFourImagePanorama(imagePaths, outputPath)
    images = cell(1, length(imagePaths));
    grayImages = cell(1, length(imagePaths));
    
    for i = 1:length(imagePaths)
        images{i} = imread(imagePaths{i});
        grayImages{i} = im2gray(images{i});
    end

    rtform1 = stitchTwoImages(images{1}, images{2}, grayImages{1}, grayImages{2});

    rtform2 = stitchTwoImages(images{3}, images{4}, grayImages{3}, grayImages{4});

    [height1, width1, ~] = size(images{1});
    [height2, width2, ~] = size(images{3});
    canvasHeight = max(height1, height2);
    canvasWidth = width1 + width2 + 50; % Adding some padding

    finalPanorama = uint8(255 * ones(canvasHeight, canvasWidth, 3));

    panorama = stitchImages(images{1}, images{2}, rtform1);
    finalPanorama(1:height(panorama), 1:width(panorama), :) = panorama;

    panorama2 = stitchImages(images{3}, images{4}, rtform2);
    finalPanorama(1:height(panorama2), (width(panorama) + 51):(width(panorama) + 50 + width(panorama2)), :) = panorama2;

    figure;
    imshow(finalPanorama);
    title('Final Panorama of Four Images');
    saveas(gcf, outputPath);
end

function rtform = stitchTwoImages(image1, image2, grayImage1, grayImage2)

    orbRPoints1 = detectFastrPoints(grayImage1, my_fast_detector(image1));
    orbRPoints2 = detectFastrPoints(grayImage2, my_fast_detector(image2));

    [rfeatures1, rvalidPoints1] = extractFeatures(grayImage1, orbRPoints1, 'Method', 'ORB');
    [rfeatures2, rvalidPoints2] = extractFeatures(grayImage2, orbRPoints2, 'Method', 'ORB');
    
    indexRPairs = matchFeatures(rfeatures1, rfeatures2, 'Unique', true);
    rmatchedPoints1 = rvalidPoints1(indexRPairs(:, 1), :);
    rmatchedPoints2 = rvalidPoints2(indexRPairs(:, 2), :);


    rtform = estimateGeometricTransform2D(rmatchedPoints2, rmatchedPoints1, 'projective', ...
                                          'Confidence', 99.9, 'MaxNumTrials', 2000);
end

createFourImagePanorama({'S4-im1.png', 'S4-im2.png', 'S4-im3.png', 'S4-im4.png'}, 'Final-Panorama.png');

