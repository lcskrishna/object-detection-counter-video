function [ct] = how_many ( prefix, ct_f, num_f )

%% Background Training and Extraction.

count =0;
for i=1:num_f
    fileName = sprintf('%sFRM_%05d.png%', prefix, i );
    input_im = imread(fileName);
    input_im = rgb2gray(input_im);
    
    if(i==1)
        mean_im = single(input_im);
    else
        mean_im = mean_im+ single(input_im);
    end
    count = count+1;
end
mean_im = uint8(mean_im/count);
bgimage = mean_im;

for x=1:numel(ct_f)
    
    %% Background Subtraction.
    fileName = sprintf('%sFRM_%05d.png%', prefix, ct_f(x) );
    gray_im = imread(fileName);
    gray_im = rgb2gray(gray_im);
    
    
    differenceImage = uint8(abs(int16 ( gray_im ) - int16 ( bgimage )));
    differenceImage = medfilt2(differenceImage,[7 7]);
    
    
    %% Thresholding.
    
    total = size(differenceImage,1)* size(differenceImage,2);
    hist = imhist(differenceImage);
    sumBackground = 0;
    weightBackground = 0;
    maximum = 0.0;
    sum1 = 0;
    for a = 0:255
        sum1 = sum1 + a*hist(a+1);
    end
    
    for ii = 1:256
        weightBackground = weightBackground + hist(ii);
        if (weightBackground == 0)
            continue;
        end
        weightForeground = total - weightBackground;
        if (weightForeground == 0)
            break;
        end
        sumBackground = sumBackground + (ii-1)*hist(ii);
        meanBackground = sumBackground/weightBackground;
        meanForeground = (sum1 - sumBackground)/weightForeground;
        between = weightBackground*weightForeground*(meanBackground - meanForeground)*(meanBackground - meanForeground);
        if (between >= maximum)
            level = ii;
            maximum = between;
        end
    end
    
    
    th = differenceImage > 0.9 * level;
    
    
    
    
    %% Morphological Operations.
    
    %Remove the border pixels.
    th= imclearborder(th);
    
    g= imfill(th,'holes');
    g= bwareaopen(g,110);
    
    %% Connected Component Labelling.
    CC = bwconncomp(g,4);
    ct(x)= CC.NumObjects;
    
end

end
