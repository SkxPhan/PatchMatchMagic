clc;clear;close all;
addpath(genpath('Images'));
addpath(genpath('Patchmatch'));

image = 'test.jpg';

imageIn = imread(image);
% binaryMask = SelectTarget(imageIn);
load testmask1.mat

tic
A = inpaint(imageIn,binaryMask);
toc

figure
imshow(A);
title('Finito!')