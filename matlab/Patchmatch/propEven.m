function [NNF] = propEven(imgA, imgB, patchSize, NNF, Mb, Nb, mask)

%% propagation for even iterations

for x=size(NNF,1):-1:1
    for y=size(NNF,2):-1:1
            
        Patch = imgA(x:x+patchSize-1,y:y+patchSize-1,:);            
        coord=NNF(x,y,:);

        down = NNF(min(x+1,size(NNF,1)), y,:);
        right = NNF(x,min(y+1,size(NNF,2)),:);

        downCoord = [min(max(1,down(1)-1),Mb),down(2)];
        rightCoord = [right(1),min(max(1,right(2)-1),Nb)];
        
        %% computing the neccessary patches for comparaison
        
        centerPatch = imgB(coord(1):coord(1)+patchSize-1,coord(2):coord(2)+patchSize-1,:);
        downPatch = imgB(downCoord(1):downCoord(1)+patchSize-1,downCoord(2):downCoord(2)+patchSize-1,:);
        rightPatch = imgB(rightCoord(1):rightCoord(1)+patchSize-1,rightCoord(2):rightCoord(2)+patchSize-1,:);

        errDist=centerPatch(:)-Patch(:);
        dist = sum(errDist.^2);
    
        errDownDist=downPatch(:)-Patch(:);
        distDown = sum(errDownDist.^2);

        errRightDist=rightPatch(:)-Patch(:);
        distRight = sum(errRightDist.^2);

        %% comparation between patches by computing distances

        if distDown < dist && mask(downCoord(1),downCoord(2))~=1
            coord=downCoord;
        end
        if distRight < dist && mask(rightCoord(1),rightCoord(2))~=1
            coord=rightCoord;
        end
        
        NNF(x,y,:) = randomSearch(Patch, imgB, patchSize, coord,mask);
    end
end
end