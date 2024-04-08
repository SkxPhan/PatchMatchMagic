function  imageOut = PyramidReconstruct(imageIn,mask,windowSize,thresholdScale,iterations,search_iterations)
%%% Pyramid level scaling
% Starting scale
[m,n,~] = size(imageIn);
firstScale = -ceil(log2(min(m,n))) + 5;
scale = 2^(firstScale);

% Scale image to firstScale
I = imresize(imageIn,scale); % Scale imageIn and store it in I
M = imresize(mask,scale);   % Scale mask
M(M>0)=1;

[m,n,~] = size(I);
M3 = repmat(M,[1 1 3])==1; % Build 3D matrix mask (RGB) that will be used to keep the non-occlusion area
distT = bwdist(~M); % Compute distance transform matrix

%%% Completion
for logscale = firstScale:-1 % Change -1 to 0 if FinalReconstruction.m is not applied in inpaint.m
    scale = 2^(logscale);
    for iter = 1:iterations
        imshow(I);
        title(sprintf('Completion...\nScale = %d\nIteration %2d/%2d',-logscale,iter,iterations));
        pause(0.001)
        
        D = I;      
        D(M3)=0;    % Build data base D for Patchmatch
        R = zeros(size(I));
        Rcount = zeros(m,n);
        Rdata = zeros(1,5);
        k = 1;
        
        % Compute NNF with Patchmatch
        NNF = Patchmatch(I,D,search_iterations,windowSize,M);
        
        % Convert the image I to double precision for computation
        I = double(I)./255;
        
        % Completion
        for i = 1:m-windowSize+1
            for j = 1:n-windowSize+1
                pi = i:i+windowSize-1;
                pj = j:j+windowSize-1;
                MTemp = M(pi,pj); 
                if any(MTemp(:) == 1)
                    patch = I(pi,pj,:);
                    
                    i2 = NNF(i,j,2);
                    j2 = NNF(i,j,1);
%                     [i2,j2] = BruteForceSearch([i,j],I,M,windowSize);

                    pi2 = i2:i2+windowSize-1;
                    pj2 = j2:j2+windowSize-1;
                    patch2 = I(pi2,pj2,:);
                    
                    d = sum( (patch(:)-patch2(:)).^2 );
                    Rdata(k,1:4) = [i,j,i2,j2];
                    Rdata(k,5) = d; % Store RGB distance d in Rdata to compute sigma
                    k = k+1; 
                end
            end
        end
        sigma = prctile(Rdata(:,5),75);
        Rdata(:,5) = exp( -Rdata(:,5) ./ (2*sigma^2) ); % Compute sim
        % Mshift = MeanShift(I, Rdata, sigma, 1, 0.1);
        for raw = 1:k-1
           pi = Rdata(raw,1):Rdata(raw,1)+windowSize-1; %Wi_x
           pj = Rdata(raw,2):Rdata(raw,2)+windowSize-1; %Wi_y
           pi2 = Rdata(raw,3):Rdata(raw,3)+windowSize-1; %Vi_x
           pj2 = Rdata(raw,4):Rdata(raw,4)+windowSize-1; %Vi_y
           R(pi,pj,:) = R(pi,pj,:) + Rdata(raw,5)*(1.3.^(-distT(pi,pj)).*I(pi2,pj2,:)); %Sim_i*alpha_i*c_i
           Rcount(pi,pj) = Rcount(pi,pj) + Rdata(raw,5)* 1.3.^(-distT(pi,pj)); %Sim_i*alpha_i
        end
        
        % Divide : c = (Sim_i*alpha_i*c_i)/(Sim_i*alpha_i)
        Rcount = repmat(Rcount,[1 1 3]);
        R(Rcount>0) = R(Rcount>0) ./ Rcount(Rcount>0);
        
        % Keep initial pixels that are outside of the hole 
        R(~M3)=I(~M3);
        Iprev = 255*I;
        I = uint8(255*R);
        if iter>1
            % Check convergence
            diff = sum( (double(I(:))-double(Iprev(:))).^2 ) / sum(M(:)>0);
            if diff < thresholdScale
                break;
            end
        end
    end
    
    % Upscale I for the next scale
    if logscale < 0
        Inextscale = imresize(imageIn,2*scale);
        [m,n,~] = size(Inextscale);
        I = imresize(I,[m n]);
        
        M = imresize(mask,[m n]);
        M(M>0)=1;
        M3 = repmat(M,[1 1 3])==1;
        distT = bwdist(~M);
        
        %Outside of the hole, I is equal to the original image
        I(~M3) = Inextscale(~M3);
    end
end
imageOut = I;
end