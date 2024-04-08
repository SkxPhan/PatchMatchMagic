function [coord] = randomSearch(Patch, imgB, patchSize, coord, mask)

i = 0;
[mb,nb,~]=size(imgB);
w = max([mb,nb]);
a = 0.5;
r = w*(a^i);

while (r > 1)   
    %% dimension for window search
    r = round(r);
    ry = randi([-r r]);
    rx = randi([-r r]);
    
    %% adding random offset
    coords = [coord(1)+rx, coord(2)+ry];
    coords(1) = min(max(1,coords(1)),mb-patchSize+1);
    coords(2) = min(max(1,coords(2)),nb-patchSize+1);
    
    %% must compare previous best patch to a new one
    centerPatch = imgB(coord(1):coord(1)+patchSize-1,coord(2):coord(2)+patchSize-1,:);
    err= centerPatch(:)-Patch(:);
    dist = sum(err.^2);
    
    %% computing new candidate patch
    candidatePatch = imgB(coords(1):coords(1)+patchSize-1,coords(2):coords(2)+patchSize-1,:);
    errCandi=candidatePatch(:)-Patch(:);
    candidateDistance= sum(errCandi.^2);
    
    %% comparaison and validation
    if candidateDistance < dist && mask(coords(1),coords(2))~=1
        coord = coords;
    end
    
    i = i+1;
    r = w*(a^i);
end
end