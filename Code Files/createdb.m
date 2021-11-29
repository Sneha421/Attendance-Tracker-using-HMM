function [myDatabase,minimax] = createdb()
data_folder_contents = dir ('./Image_Data');
myDatabase = cell(0,0);
person_index = 0;
max_coeffs = [-Inf -Inf -Inf];
min_coeffs = [ Inf  0  0];
h=56;
w=46;
l=uint8(h/10);
p=l-1;
t=uint8(((h-l)/(l-p))+1);
eps=.000001;
for person=1:size(data_folder_contents,1);
    if (strcmp(data_folder_contents(person,1).name,'.') || ...
        strcmp(data_folder_contents(person,1).name,'..') || ...
        (data_folder_contents(person,1).isdir == 0))
        continue;
    end
    person_index = person_index+1;
    person_name = data_folder_contents(person,1).name;
    myDatabase{1,person_index} = person_name;
%     fprintf([person_name,' ']);
    person_folder_contents = dir(['./Image_Data/',person_name,'/*.jpg']);
    blk_cell = cell(0,0);
    for face_index=1:10
        I = imread(['./Image_Data/',person_name,'/',person_folder_contents(face_index,1).name]);
        I = imresize(I,[h w]);
        I = ordfilt2(I,1,true(3));        
        blk_index = 0;
        for blk_begin=1:t
            blk_index=blk_index+1;
            blk = I(blk_begin:blk_begin+4,:);            
            [U,S,V] = svd(double(blk));
            blk_coeffs = [U(1,1) S(1,1) S(2,2)];
            max_coeffs = max([max_coeffs;blk_coeffs]);
            min_coeffs = min([min_coeffs;blk_coeffs]);
            blk_cell{blk_index,face_index} = blk_coeffs;
        end
    end
    myDatabase{2,person_index} = blk_cell;
%     if (mod(person_index,10)==0)
%         fprintf('\n');
%     end
end
delta = (max_coeffs-min_coeffs)./([18 10 7]-eps);
minimax = [min_coeffs;max_coeffs;delta];
for person_index=1:41
    for image_index=1:10
        for block_index=1:t
            blk_coeffs = myDatabase{2,person_index}{block_index,image_index};
            min_coeffs = minimax(1,:);
            delta_coeffs = minimax(3,:);
            qt = floor((blk_coeffs-min_coeffs)./delta_coeffs);
            myDatabase{3,person_index}{block_index,image_index} = qt;
            label = qt(1)*10*7+qt(2)*7+qt(3)+1;            
            myDatabase{4,person_index}{block_index,image_index} = label;
        end
        myDatabase{5,person_index}{1,image_index} = cell2mat(myDatabase{4,person_index}(:,image_index));
    end
end

transmat = ones(7,7) * eps;
transmat(7,7)=1;
% transmat=[0.5,0.5,0,0,0,0,0;
%           0,0.5,0.5,0,0,0,0;
%           0,0,0.5,0.5,0,0,0;
%           0,0,0,0.5,0.5,0,0;
%           0,0,0,0,0.5,0.5,0;
%           0,0,0,0,0,0.5,0.5;
%           0,0,0,0,0,0,1];
M=18*10*7;
N=7;
emissionmat = (1/M)*ones(N,M);
fprintf('\nTraining ...\n');
for person_index=1:41
    fprintf([myDatabase{1,person_index},' ']);
    seqmat = cell2mat(myDatabase{5,person_index});
    [ESTTR,ESTEMIT]=hmmtrain(seqmat,transmat,emissionmat,'Tolerance',.01,'Maxiterations',10,'Algorithm', 'BaumWelch');
    ESTTR = max(ESTTR,eps);
    ESTEMIT = max(ESTEMIT,eps);
    myDatabase{6,person_index}{1,1} = ESTTR;
    myDatabase{6,person_index}{1,2} = ESTEMIT;
   
end
fprintf('done.\n');
% save DATABASE myDatabase 
save('createdb.mat','minimax','myDatabase')