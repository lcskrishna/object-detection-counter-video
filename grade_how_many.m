% 1.  Initialize an array with the prefix names to be tested
prefix = {'video1/'; ...
    'video2/'};

% gt files
gtFiles = {'video1/gt.xlsx';...
    'video2/gt.xlsx'};

% 2.  Load the frame numbers to be tested from each video.
numFrame = [00001, 00100; 00001,00299];

total_score = 0; % Final Score


% 3.  Test
% For each video
for i = 1:size(prefix,1)
    t = cputime; % start timer
    
    % Get end frame for current video
    f1 = numFrame(i,2);
    
    %load gt
    gt_all = xlsread(char(gtFiles(i)));
    
    gt_ct = gt_all(1:10,1:2);
    
    
    %frames for grading
    ct_f = gt_all(1:10,1)';
    
    % Call the algorithm.
    ctr = how_many(char(prefix(i)), ct_f, f1);
    
    execution_time =  cputime - t;
    
    if execution_time > 300 % 5 minutes per video
        fprintf ( 'video[%d] Took > 5 minutes and is not considered for grade.\n', i);
        continue
    end
    
    gt = gt_all(1:10, 2)';
    for j = 1:numel(ctr)
        points = 0; %Points for each image tested
        diff = abs(gt(j)-ctr(j)); %Absolute difference between gt and result of how_many.m
        if diff == 0
            points = 10;
            total_score = total_score + points;
        elseif diff <= 1
            points = 5;
            total_score = total_score + points;
        elseif diff <= 5
            points = 2;
            total_score = total_score + points;
        elseif diff <= 10
            points = 1;
            total_score = total_score + points;
        else
            total_score = total_score + points;
        end
        fprintf ( 'video[%d] - frame[%d] - GT[%d] vs ME[%d] - score[%d] - total score[%d]\n', i ,ct_f(j),gt(j),ctr(j) ,points, total_score);
    end
    fprintf ( 'video[%d] - took [%f]sec\n', i ,execution_time);
    
        
end

fprintf ( 'Total score [%f]\n', total_score);