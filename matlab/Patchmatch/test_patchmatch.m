%test patchmatch
aind2=imread('effeil.jpg');
aind=imread('eiffel-tower-day.jpg');
im=im2double(aind);
im2=im2double(aind2);
[m,n,p]=size(aind);
[mb,nb,pb]=size(aind2);
mask=zeros(mb,nb);
% H=[105 153 ;75 145];
% mask(H(1,1):H(1,2),H(2,1):H(2,2),:)=1;
dim_wind=8;
width=floor(dim_wind/2);
tic;
[NNF]=Patchmatch(im,im2,4,dim_wind,mask);
%% test
im_next=zeros(m,n,p);
im_next2=zeros(m,n,p);

for k=1:m-dim_wind
    for h=1:n-dim_wind
        coords=NNF(k,h,:);
        x_b=coords(2);
        y_b=coords(1);
        im_next(k,h,:)=double(aind2(x_b,y_b,:))./255;

    end
end
toc;

% im_next=rgb2gray(im_next);
% im_next2=rgb2gray(im_next2);
subplot(1,3,1)
imshow((aind))
title('imageA')
subplot(1,3,2)
imshow((aind2))
title('imageB')
subplot(1,3,3)
imshow((im_next))
title('Reconstruction')
