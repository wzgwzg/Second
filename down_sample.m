mov=VideoReader('data/processed1_mask.avi');
frame_len=mov.NumberOfFrames;
wobj=VideoWriter('data/down_processed1.avi');
wobj.FrameRate=25;
open(wobj);
num=floor(frame_len/2);
for i=1:num
    frame=read(mov,2*i);
    imshow(frame);
    writeVideo(wobj,frame);
end
close(wobj);
