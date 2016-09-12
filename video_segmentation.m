function video_segmentation(videopath,savepath)
directory=dir(strcat(videopath,'*.avi'));
num=length(directory);
parfor i=1:num
    filename=directory(i).name;
    filename=strcat(videopath,filename);
    mov=VideoReader(filename);
    frame_rate=ceil(mov.FrameRate);
    frames=mov.NumberOfFrames;
    interval=2*frame_rate;
    number_of_segments=ceil(frames/interval);
    folder_name=filename(1:end-4);
    disp(folder_name);
    mkdir(folder_name);
    
    for j=1:number_of_segments-1
        wobj=VideoWriter(strcat(folder_name,'\',num2str(j),'.avi'));
        wobj.FrameRate=frame_rate;
        open(wobj);
        for k=interval*(j-1)+1:interval*j
            cur_frame=read(mov,k);
            writeVideo(wobj,cur_frame);
        end
        close(wobj);
    end
    
    wobj=VideoWriter(strcat(folder_name,'\',num2str(number_of_segments),'.avi'));
    wobj.FrameRate=frame_rate;
    open(wobj);
    for k=interval*(number_of_segments-1)+1:frames
        cur_frame=read(mov,k);
        writeVideo(wobj,cur_frame);
    end
    close(wobj);
end
end