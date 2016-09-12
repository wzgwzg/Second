function [bg]=maskrgb2(bg,all_image,mask)
[m,n,q]=size(bg);
bg1=bg(:,:,1);
bg2=bg(:,:,2);
bg3=bg(:,:,3);
all_image1=all_image(:,:,1);
all_image2=all_image(:,:,2);
all_image3=all_image(:,:,3);

bg1(find(mask)) = all_image1(find(mask));
bg2(find(mask)) = all_image2(find(mask));
bg3(find(mask)) = all_image3(find(mask));

bg(:,:,1)=reshape(bg1,[m,n]);
bg(:,:,2)=reshape(bg2,[m,n]);
bg(:,:,3)=reshape(bg3,[m,n]);