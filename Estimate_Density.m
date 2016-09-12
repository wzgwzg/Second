density_mov=VideoReader('data/cheng1_mask.avi');
frame_rate=density_mov.FrameRate;
frame_length=density_mov.NumberOfFrames;
partition_number1=10; %partition the active area into 5 * 5 subblocks
partition_number2=15;
block_number=partition_number1*partition_number2; %number of subblocks of active area

x=10; %x coordinate of left up corner of active area
y=75; %y coordinate of left up corner of active area
width=710; %The width of active area
height=500; %The height of active area
m=floor(width/partition_number2); %subblock width
n=floor(height/partition_number1); %subblock height

block_threshhold=0.08*m*n; %The threshhold to determine whether a subblock is active
num_threshhold=floor(block_number*0.25); %The threshhold to determine whether the current scene is crowded
frame_index=[]; %The vector to record the crowded frames' indexes
findex=1; %The index of frame_index

for num=1:frame_length
    frame=read(density_mov,num);
    disp(num2str(num));
    judge_matrix=zeros(partition_number1,partition_number2);
    %record active pixel in each subblock
    for i=1:partition_number1 %can be modified to parfor
        for j=1:partition_number2
            for k=(i-1)*n+x+1:i*n+x
                for p=(j-1)*m+y+1:j*m+y
                    if(frame(k,p)>0)
                        judge_matrix(i,j)=judge_matrix(i,j)+1;
                    end
                end
            end
        end
    end
    %statistics
    active_block=numel(find(judge_matrix>block_threshhold));
    if(active_block>num_threshhold)
        frame_index(findex)=num;
        findex=findex+1;
        %         col_sum=sum(judge_matrix);
        %         variance=std(col_sum);
        %         if(variance<20000)
        %             frame_index(findex)=num;
        %             findex=findex+1;
        %         end
        
    end
end

