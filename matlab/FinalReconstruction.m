function  imageOut = FinalReconstruction(imageIn,mask,windowSize,iterations,search_iterations)
% Final reconstruction as proposed by Newson et al.
% We just take the pixel proposed by the window Vi that has the higher
% similitude amoung all windows Vi that also contain the targeted pixel 
I = imageIn;
M = mask;
M(M>0)=1;

[m,n,~] = size(I);
M3 = repmat(M,[1 1 3])==1;
distT = bwdist(~M);

for iter = 1:iterations
    imshow(I);
    title(sprintf('Completion...\nFinal Scale\nIteration %2d/%2d',iter,iterations));
    pause(0.001)

    D = I;
    D(M3)=0;    % Build data base D for Patchmatch
    R = zeros(size(I));
    Rcount = 10*ones(m,n);

    % Compute NNF with Patchmatch
    NNF = Patchmatch(I,D,search_iterations,windowSize,M);

    % Convert the image I to double precision for computation
    I = double(I)./255;
    for i = 1:m-windowSize+1
        for j = 1:n-windowSize+1
            pi = i:i+windowSize-1;
            pj = j:j+windowSize-1;
            MTemp = M(pi,pj);
            if any(MTemp(:) == 1)
                patch = I(pi,pj,:);
                
                i2 = NNF(i,j,2);
                j2 = NNF(i,j,1);
%                 [i2,j2] = BruteForceSearch([i,j],I,M,windowSize);
                
                pi2 = i2:i2+windowSize-1;
                pj2 = j2:j2+windowSize-1;
                patch2 = I(pi2,pj2,:);

                distTemp = distT(pi,pj)+1;
                distTemp = repmat(distTemp,[1 1 3]);
                d = sum( distTemp(:).*(patch(:)-patch2(:)).^2);
                
                % Check if the new distance d computed from the window
                % Vi(=patch2) is lower and we only update the pixels that
                % have a higher d than the new one.
                RcountToUpdate = Rcount(pi,pj)>=d;
                Rcount(pi,pj) = Rcount(pi,pj).*~RcountToUpdate;
                Rcount(pi,pj) = Rcount(pi,pj)+d*RcountToUpdate;
                R(pi,pj,:) = R(pi,pj,:).*~RcountToUpdate;
                R(pi,pj,:) = R(pi,pj,:) + RcountToUpdate.*patch2; 
            end
        end
    end 
    R(~M3)=I(~M3);
    I = uint8(255*R);
end
imageOut = I;
imshow(I);
title(sprintf('Finito!'));
pause(0.001)
end