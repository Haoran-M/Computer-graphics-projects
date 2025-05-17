imagehp = imread('sfu.jpg');
imagelp = imread('apple.jpg');
resized_hp = imresize(imagehp,[500,500]);
resized_lp = imresize(imagelp,[500,500]);
greyhp = rgb2gray(resized_hp);
greylp = rgb2gray(resized_lp);
imwrite(greyhp,'HP.png');
imwrite(greylp,"LP.png");
%section 2 
imglp = imread('LP.png');
imghp = imread('HP.png');
fft_lp = fft2(imglp);
fft_hp = fft2(imghp); 
fft_lp_shifted = fftshift(fft_lp);
fft_hp_shifted = fftshift(fft_hp);
log_hp = log(1 + fft_hp_shifted); 
log_lp = log(1 + fft_lp_shifted);
% used auto brightness adjust, and saved the image
imshow(log_lp,[]);
saveas(gcf,'LP-freq.png');
imshow(log_hp,[]);
saveas(gcf,'HP-freq.png');

%section 3
sobel_horizontal = [-1, 0, 2; -1, 0, 1; -1, 0, 2];

gauskern = fspecial('gaussian',21,2.5);

DoGkern = imfilter(gauskern,sobel_horizontal);

hpgaus = imfilter(greyhp,gauskern);
lpgaus = imfilter(greylp,gauskern);
imwrite(hpgaus,"HP-flit.png");
imwrite(lpgaus,"LP-flit.png");
hpgausf = fftshift(fft2(hpgaus));
lpgausf = fftshift(fft2(lpgaus));
loghpgausf = log(1 + abs(hpgausf));
loglpgausf = log(1 + abs(lpgausf));
imshow(loghpgausf,[]);
saveas(gcf,"HP-filt-freq.png");
imshow(loglpgausf,[]);
saveas(gcf,"LP-filt-freq.png");
% part2
DoGkern_freq = fftshift(fft2(DoGkern, 500, 500));
hpDogFreq = fftshift(fft2(greyhp));
lpDogFreq = fftshift(fft2(greylp));
imshow(hpDogFreq)
saveas(gcf,"HP-dogfilt-freq.png")
imshow(lpDogFreq)
saveas(gcf,"LP-dogfilt-freq.png")

hpDogfiltfreq = hpDogFreq .* DoGkern_freq;
lpDogfiltfreq = lpDogFreq .* DoGkern_freq;
hpDogspatial = ifft2(ifftshift(hpDogfiltfreq));
lpDogspatial = ifft2(ifftshift(lpDogfiltfreq));
imshow(hpDogspatial,[]);
saveas(gcf,"HP-dogfilt.png")
imshow(lpDogspatial,[])
saveas(gcf,"LP-dogfilt.png");


%section 4
hpsub2 = greyhp(1:2:end, 1:2:end);
lpsub2 = greylp(1:2:end, 1:2:end);
imwrite(hpsub2,"HP-sub2.png");
imwrite(lpsub2,"LP-sub2.png");
hpsub2freq = fftshift(fft2(hpsub2));
lpsub2freq = fftshift(fft2(lpsub2));
loghpsub2freq = log(1+abs(hpsub2freq));
loglpsub2freq = log(1+abs(lpsub2freq));
imshow(loghpsub2freq,[]);
saveas(gcf,"HP-sub2-freq.png")
imshow(loglpsub2freq,[]);
saveas(gcf,"LP-sub2-freq.png")

hpsub4 = greyhp(1:4:end, 1:4:end);
lpsub4 = greylp(1:4:end, 1:4:end);
imwrite(hpsub2,"HP-sub4.png");
imwrite(lpsub2,"LP-sub4.png");
hpsub4freq = fftshift(fft2(hpsub4));
lpsub4freq = fftshift(fft2(lpsub4));
loghpsub4freq = log(1+abs(hpsub4freq));
loglpsub4freq = log(1+abs(lpsub4freq));
imshow(loghpsub4freq,[]);
saveas(gcf,"HP-sub4-freq.png")
imshow(loglpsub4freq,[]);
saveas(gcf,"LP-sub4-freq.png")

gaussfilt2 = fspecial("gaussian", 11,1.5);
gaussfilt4 = fspecial("gaussian",21,2);
hpgausfilt2 = imfilter(greyhp,gaussfilt2);
hpgausfilt4 = imfilter(greyhp,gaussfilt4);
hpaasub2 = hpgausfilt2(1:2:end, 1:2:end);
hpaasub4 = hpgausfilt4(1:4:end, 1:4:end);
imwrite(hpaasub2,"HP-aa-sub2.png");
imwrite(hpaasub4,"HP-aa-sub4.png");


hpaafreq2 = fftshift(fft2(hpgausfilt2));
hpaafreq4 = fftshift(fft2(hpgausfilt4));
loghpaafreq2 = log(1+abs(hpaafreq2));
loghpaafreq4 = log(1+abs(hpaafreq4));
imshow(loghpaafreq2,[]);
saveas(gcf,"HP-aa-sub2-freq.png");
imshow(loghpaafreq4,[]);
saveas(gcf,"HP-aa-sub4-freq.png");

%part 5

[~, threshold] = edge(greyhp, 'Canny');
low_threshold = threshold(1);
high_threshold = threshold(2);
%for the above gained optimal threshold
%lowopt = 0.0813;
%highopt = 0.2031;
hpoptimal = edge(greyhp,'canny',[0.0813,0.2031]);
imwrite(hpoptimal,"HP-canny-optimal.png");
% lower lower threshold will be 0.06
hplowlow = edge(greyhp,"canny", [0.06,0.2031]);
imwrite(hplowlow,"HP-canny-lowlow.png");
%higher lower threshold will be 0.1
hphighlow = edge(greyhp,"canny",[0.1,0.2031]);
imwrite(hphighlow,"HP-canny-highlow.png");
%lower higher threshold will be 0.18
hplowhigh = edge(greyhp, "canny",[0.0813,0.18]);
imwrite(hplowhigh, "HP-canny-lowhigh.png");
%higher higher threshold will be 0.22
hphighhigh = edge(greyhp,"canny",[0.0813,0.22]);
imwrite(hphighhigh,"HP-canny-highhigh.png");

% for lp
%matlab optimal is [0.0125, 0.0312]
lpoptimal = edge(greylp,'canny',[0.0125,0.0312]);
imwrite(lpoptimal,"LP-canny-optimal.png");
% lower lower threshold will be 0.0095
lplowlow = edge(greylp,"canny", [0.0095,0.0312]);
imwrite(lplowlow,"LP-canny-lowlow.png");
%higher lower threshold will be 0.015
lphighlow = edge(greylp,"canny",[0.015,0.0312]);
imwrite(lphighlow,"LP-canny-highlow.png");
%lower higher threshold will be 0.0285
lplowhigh = edge(greylp, "canny",[0.0125,0.0285]);
imwrite(lplowhigh, "LP-canny-lowhigh.png");
%higher higher threshold will be 0.0350
lphighhigh = edge(greylp,"canny",[0.0125,0.0350]);
imwrite(lphighhigh,"LP-canny-highhigh.png");
