%author: Jason Jincheng Tu
%Testure Synthesis
%
%IMPORTANT!!! Please clean your workspace before you run this program
%

%Ask for user input
filename = input('What is the name of the input file(path)? ', 's');
patch_size = input('\nWhat is the texton neighborhood diameter\n(need to be smaller than half of the input image size)? ');
output_size = input('\nWhat is the output size\n(need to be larger than the input image)? ');

%initialized all the valuable
input = imread(filename);
[Y, X, C] = size(input);    %get the size of our input image
output_size = max(output_size, round(1.5*Y)); 

%the width of a patch and make sure that it is with the range
patch_size = min(max(patch_size, round(min(Y,X)/20)), round(min(Y,X)/2));
overlap = round(patch_size/5);  %overlap width between two patch
num_set = 2000;            %the amount of patch in consideration
            
%seperate each channel since some function only work on 2D matrix
output_R = zeros(output_size, output_size,'uint8');
output_G = zeros(output_size, output_size,'uint8');
output_B = zeros(output_size, output_size,'uint8');

%seperate each channel since some function only work on 2D matrix
input_R = input(:,:,1);
input_G = input(:,:,2);
input_B = input(:,:,3);

disp('Please be patient, output image is generating.');
%loop through the output image to put patch on it
for r = 1:patch_size-overlap:output_size-overlap
        
    for c = 1:patch_size-overlap:output_size-overlap
        
        %get the end of this patch
        r_end = min(r+patch_size-1,output_size);
        c_end = min(c+patch_size-1,output_size);
        
        %edge case for the first patch
        if r==1 && c==1
            %get a random one for the first patch
            starty = round(rand()*(Y-patch_size-1)+1);
            startx = round(rand()*(X-patch_size-1)+1);
            
            %copy the pixel to output
            output_R(r:r+overlap, c:c+overlap) = input_R(starty:starty+overlap, startx:startx+overlap);
            output_G(r:r+overlap, c:c+overlap) = input_G(starty:starty+overlap, startx:startx+overlap);
            output_B(r:r+overlap, c:c+overlap) = input_B(starty:starty+overlap, startx:startx+overlap);
            
        else 
            %Texton starts here            
            %get all the random points
            cand_y = round(rand(num_set,1)*(Y-patch_size-patch_size)+patch_size);
            cand_x = round(rand(num_set,1)*(X-patch_size-patch_size)+patch_size);
            
            %initialize the distance between texton
            distance = ones(num_set, 1, 'double');
            
            %check if there is other patch above the current one
            if r~=1
                for i=1:num_set
                    %caculate all the diatance using correlation
                    distance(i) = distance(i)* corr2(output_R(r-patch_size+overlap:r+overlap, c:c_end)...
                    ,input_R(cand_y(i)-patch_size+overlap:cand_y(i)+overlap, cand_x(i):cand_x(i)+c_end-c));
                    distance(i) = distance(i)* corr2(output_G(r-patch_size+overlap:r+overlap, c:c_end)...
                    ,input_G(cand_y(i)-patch_size+overlap:cand_y(i)+overlap, cand_x(i):cand_x(i)+c_end-c));
                    distance(i) = distance(i)* corr2(output_B(r-patch_size+overlap:r+overlap, c:c_end)...
                    ,input_B(cand_y(i)-patch_size+overlap:cand_y(i)+overlap, cand_x(i):cand_x(i)+c_end-c));
                    
                end
            end
            
            %check if there is other patch one the left of the current one
            if c~=1
                for i=1:num_set
                    %caculate all the diatance using correlation
                    distance(i) = distance(i)* corr2(output_R(r:r_end, c-patch_size+overlap:c+overlap)...
                    ,input_R(cand_y(i):cand_y(i)+r_end-r, cand_x(i)-patch_size+overlap:cand_x(i)+overlap));
                    distance(i) = distance(i)* corr2(output_G(r:r_end, c-patch_size+overlap:c+overlap)...
                    ,input_G(cand_y(i):cand_y(i)+r_end-r, cand_x(i)-patch_size+overlap:cand_x(i)+overlap));
                    distance(i) = distance(i)* corr2(output_B(r:r_end, c-patch_size+overlap:c+overlap)...
                    ,input_B(cand_y(i):cand_y(i)+r_end-r, cand_x(i)-patch_size+overlap:cand_x(i)+overlap));
                end
            end
            
            %get the most similar one
            [val, key] = max(distance);            
            starty = cand_y(key);
            startx = cand_x(key);
            
            %interpolate the corner of the patch
            for i=r:r+overlap
                i_r = (i-r)/overlap;
                for j=c:c+overlap
                    %get the ratio for the relative location
                    ratio = (j-c)/overlap*i_r;
                    output_R(i, j) = round(output_R(i, j)*(1-ratio) + input_R(starty+i-r, startx+j-c)*ratio);
                    output_G(i, j) = round(output_G(i, j)*(1-ratio) + input_G(starty+i-r, startx+j-c)*ratio);
                    output_B(i, j) = round(output_B(i, j)*(1-ratio) + input_B(starty+i-r, startx+j-c)*ratio);
                end
            end
        end
        
        %handle the top overlapping
        if r==1 %on the top edge
            output_R(r:r+overlap, c+overlap:c_end) = input_R(starty:starty+overlap, startx+overlap:startx+c_end-c);
            output_G(r:r+overlap, c+overlap:c_end) = input_G(starty:starty+overlap, startx+overlap:startx+c_end-c);
            output_B(r:r+overlap, c+overlap:c_end) = input_B(starty:starty+overlap, startx+overlap:startx+c_end-c);
        else
            for i=r:r+overlap
               %get the ratio for the relative location
               ratio = (i-r)/overlap;
               output_R(i, c+overlap:c_end) = round(output_R(i, c+overlap:c_end)*(1-ratio)...
                   + input_R(starty+i-r, startx+overlap:startx+c_end-c)*ratio);
               output_G(i, c+overlap:c_end) = round(output_G(i, c+overlap:c_end)*(1-ratio)...
                   + input_G(starty+i-r, startx+overlap:startx+c_end-c)*ratio);
               output_B(i, c+overlap:c_end) = round(output_B(i, c+overlap:c_end)*(1-ratio)...
                   + input_B(starty+i-r, startx+overlap:startx+c_end-c)*ratio);     
            end
        end
        
        %handle the left overlapping
        if c==1        %on the left edge    
            output_R(r+overlap:r_end, c:c+overlap) = input_R(starty+overlap:starty+r_end-r, startx:startx+overlap);
            output_G(r+overlap:r_end, c:c+overlap) = input_G(starty+overlap:starty+r_end-r, startx:startx+overlap);
            output_B(r+overlap:r_end, c:c+overlap) = input_B(starty+overlap:starty+r_end-r, startx:startx+overlap);
        else            
            for i=c:c+overlap
                %get the ratio for the relative location
                ratio = (i-c)/overlap;
                output_R(r+overlap:r_end, i) = round(output_R(r+overlap:r_end, i)*(1-ratio)...
                    + input_R(starty+overlap:starty+r_end-r, startx+i-c)*ratio);
                output_G(r+overlap:r_end, i) = round(output_G(r+overlap:r_end, i)*(1-ratio)...
                    + input_G(starty+overlap:starty+r_end-r, startx+i-c)*ratio);
                output_B(r+overlap:r_end, i) = round(output_B(r+overlap:r_end, i)*(1-ratio)...
                    + input_B(starty+overlap:starty+r_end-r, startx+i-c)*ratio);
            end
        end
        
        %copy the rest of patch that is not overlapping to the output image
        output_R(r+overlap:r_end, c+overlap:c_end) = input_R(starty+overlap:starty+r_end-r, startx+overlap:startx+c_end-c);
        output_G(r+overlap:r_end, c+overlap:c_end) = input_G(starty+overlap:starty+r_end-r, startx+overlap:startx+c_end-c);     
        output_B(r+overlap:r_end, c+overlap:c_end) = input_B(starty+overlap:starty+r_end-r, startx+overlap:startx+c_end-c);
    end
    disp('Please be patient, output image is generating.');
end

%combine all the output channel
output(:,:,1) = output_R;
output(:,:,2) = output_G;
output(:,:,3) = output_B;

%display the output image
imtool(output)
disp('output image is displaying.');
disp('If there is problem, please change your patch size.');

imwrite(output,'output.jpg');
disp('the output image has been save to file as output.jpg');



