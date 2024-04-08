%% This code was inspired from this github

%% https://github.com/vandenbroucke/PatchMatchMatlabTool


function [output1]= find_NNF(imageA,imageB,iteration,patchSize,mask)

% if ~ismatrix(imageA); image = rgb2gray(imageA); end
% if ~ismatrix(imageB); imageb = rgb2gray(imageB); end
image=im2double(imageA);
imageb=im2double(imageB);

[m,n,~]=size(image);
[mb,nb,~]=size(imageb);

randomXs = randi([1 mb-patchSize+1],m-patchSize+1,n-patchSize+1);
randomYs = randi([1 nb-patchSize+1],m-patchSize+1,n-patchSize+1);
%% initialization

for x = 1:size(randomXs,1)
    for y = 1:size(randomYs,2)
        if mask(randomXs(x,y),randomYs(x,y))~=1
            NNF(x,y,:) = [randomXs(x,y) randomYs(x,y)];
        else
            NNF(x,y,:)=[1 1];
        end
    end
end

%% propagation and random search


for it=1:iteration
    if mod(it,2) == 1          
         NNF = propOdd(image, imageb, patchSize, NNF, mb-patchSize+1, nb-patchSize+1, mask);
    else
         NNF = propEven(image, imageb, patchSize, NNF, mb-patchSize+1, nb-patchSize+1, mask);
    end
end

NNF(:,:,1:2)=NNF(:,:,2:-1:1);
        
output1=NNF;
        
        
             
                
    

    
