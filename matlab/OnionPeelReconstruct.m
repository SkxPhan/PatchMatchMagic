function  imageOut = OnionPeelReconstruct(imageIn,mask,windowSize,search_iterations)
%%% Pyramid level scaling
% Starting scale
[m,n,~] = size(imageIn);
firstScale = -ceil(log2(min(m,n))) + 5;
scale = 2^(firstScale);

% Scale image to firstScale
I = imresize(imageIn,scale); % Scale imageIn and store it in I
M = imresize(mask,scale);   % Scale mask
M(M>0)=1;

%%% Reconstruc in the onion way
[m,n,~] = size(I);
M3 = repmat(M,[1 1 3])==1; % Build 3D matrix mask (RGB) that will be used to keep the non-occlusion area 
distT = bwdist(~M); % Compute distance transform matrix
D = I;  
D(M3)=0;    % Build data base D for Patchmatch
I(M3)=255;  % Replace the hole area by white pixels
imshow(I)
pause(0.001)

for o = 1:ceil(max(distT(:))) % Reconstruct the occlusion area starting from the boundaries  
    k = 1;
    R = zeros(size(I));
    Rcount = zeros(m,n);
    Rdata = zeros(1,5);
    
    % Compute NNF with Patchmatch
    NNF = Patchmatch(I,D,search_iterations,windowSize,M);
    
    I = double(I)./255; % Convert the image I to double precision for computation
    for i = 1:m-windowSize+1
        for j = 1:n-windowSize+1
            pi = i:i+windowSize-1;
            pj = j:j+windowSize-1;
            distTemp = distT(pi,pj);
            if any(ceil(distTemp(:)==o)) && ~any(ceil(distTemp(:)==o+1))
                patch = I(pi,pj,:);
                 
                i2 = NNF(i,j,2);
                j2 = NNF(i,j,1);                
%                 [i2,j2] = BruteForceSearch([i,j],I,M,windowSize);
                
                pi2 = i2:i2+windowSize-1;
                pj2 = j2:j2+windowSize-1;
                patch2 = I(pi2,pj2,:);
                
                M2 = ~(distTemp==o);
                patch = patch.*M2;
                patch2temp = patch2.*M2;
    
                d = sum( (patch(:)-patch2temp(:)).^2 );
                Rdata(k,1:4) = [i,j,i2,j2];
                Rdata(k,5) = d;
                k = k+1;
            end
        end
    end
    sigma = prctile(Rdata(:,5),75);
    Rdata(:,5) = exp( -Rdata(:,5) ./ (2*sigma^2) );  % Compute sim
    for raw = 1:k-1
       pi = Rdata(raw,1):Rdata(raw,1)+windowSize-1; %Wi_x
       pj = Rdata(raw,2):Rdata(raw,2)+windowSize-1; %Wi_y
       pi2 = Rdata(raw,3):Rdata(raw,3)+windowSize-1; %Vi_x
       pj2 = Rdata(raw,4):Rdata(raw,4)+windowSize-1; %Vi_y
       R(pi,pj,:) = R(pi,pj,:) + Rdata(raw,5)*(1.3.^(-distT(pi,pj)).*I(pi2,pj2,:)); %Sim_i*alpha_i*c_i
       Rcount(pi,pj) = Rcount(pi,pj) + Rdata(raw,5)*1.3.^(-distT(pi,pj)); %Sim_i*alpha_i
    end
    
    % Divide : c = (NUM/DEM)
    Rcount = repmat(Rcount,[1 1 3]);
    R(Rcount>0) = R(Rcount>0) ./ Rcount(Rcount>0);
    
    % Keep initial pixels that are outside of the hole
    R(~M3) = I(~M3);
    I = R;
    I = uint8(255*I);
    imshow(I)
    pause(0.001)
    title(sprintf('Completion...\nOnion Peel'));
end

[m,n,~] = size(imageIn); % Rescale image I to the initial size
I = imresize(I,[m n]);

%Outside of the hole, I is equal to the original image
M3 = repmat(mask,[1 1 3])==1;
I(~M3) = imageIn(~M3);
imageOut = I;
end
