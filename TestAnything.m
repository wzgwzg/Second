for i=1:NN
    disp(num2str(i));
    rows=find(objects(:,1)==i);
    video_len=numel(rows);
    wobj=VideoWriter(strcat('Test3/SoloID',num2str(i),'.avi'));
    wobj.FrameRate=frame_rate;
    open(wobj);
    v=objects(rows,2);
    
    for j=1:video_len
        n=v(j);
        n_senconds=fix(n/frame_rate);
        an1=fix(n_senconds/3600);
        an2=fix(n_senconds/60)-60*an1;
        an3=fix(n_senconds-3600*an1-60*an2);
        tmp_image=read(mov,n+57);
        frame_mask_ind=find(TTube(i).frame==n);
        newmask=TTube(i).mask(:,:,frame_mask_ind);
        
        bg=Background;
        bg=maskrgb2(bg,tmp_image,newmask);
        
        cur_row=rows(j); %the current rows of objects
        if(objects(cur_row,4)<90)
            bg = insertObjectAnnotation(bg,'rectangle',[objects(cur_row,3:4)+[0 objects(cur_row,6)] 0 0],['Id:',num2str(i),' N:',num2str(n),' ', num2str(an1),':',num2str(an2),':',num2str(an3)],'TextBoxOpacity',0,'Fontsize',18);
        else
            bg = insertObjectAnnotation(bg,'rectangle',[objects(cur_row,3:4) 0 0],['Id:',num2str(i),' N:',num2str(n),' ', num2str(an1),':',num2str(an2),':',num2str(an3)],'TextBoxOpacity',0,'Fontsize',18);
        end
        
        imshow(bg);
        writeVideo(wobj,bg);
    end
    close(wobj);
end