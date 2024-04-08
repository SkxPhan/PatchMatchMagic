function [NNF] = propOdd(imgA, imgB, patchSize, NNF, Mb, Nb, mask)

%% propagation for odd iterations

for x=1:size(NNF,1)
    for y=1:size(NNF,2)
            
        Patch = imgA(x:x+patchSize-1,y:y+patchSize-1,:);
            
        coord=NNF(x,y,:);
        
        %% take left and up patch (avoiding index out of range)
        up = NNF(max(1,x-1),y,:);
        left = NNF(x,max(1,y-1),:);
        %% making sure (x,y)
        upCoord = [min(max(1,up(1)+1),Mb),up(2)];
        leftCoord = [left(1),min(max(1,left(2)+1),Nb)]; 
        
        %% computing the neccessary patches for comparaison

        centerPatch = imgB(coord(1):coord(1)+patchSize-1,coord(2):coord(2)+patchSize-1,:);
        upPatch = imgB(upCoord(1):upCoord(1)+patchSize-1,upCoord(2):upCoord(2)+patchSize-1,:);
        leftPatch = imgB(leftCoord(1):leftCoord(1)+patchSize-1,leftCoord(2):leftCoord(2)+patchSize-1,:);

        errDist=centerPatch(:)-Patch(:);
        dist = sum(errDist.^2);

        errDistUp=upPatch(:)-Patch(:);
        distUp = sum(errDistUp.^2);

        errDistLeft=leftPatch(:)-Patch(:);
        distLeft=sum(errDistLeft.^2);
        %% comparation between patches by computing distances
        if distUp < dist && mask(upCoord(1),upCoord(2))~=1
            coord=upCoord;
        end
        if distLeft < dist && mask(leftCoord(1),leftCoord(2))~=1
            coord=leftCoord;
        end
        
        NNF(x,y,:) = randomSearch(Patch, imgB, patchSize, coord, mask);
    end
end
end