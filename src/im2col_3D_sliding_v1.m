function [out,out2,lidx_3D] = im2col_3D_sliding_v1(A,blocksize,stepsize,mask)

%// Store blocksizes
nrows = blocksize(1);
ncols = blocksize(2);

%// Store stepsizes along rows and cols
d_row = stepsize(1);
d_col = stepsize(2);

%// Get sizes for later usages
[m,n,r] = size(A);

%// Start indices for each block
start_ind = reshape(bsxfun(@plus,[1:d_row:m-nrows+1]',[0:d_col:n-ncols]*m),[],1); %//'

%// Row indices
lin_row = permute(bsxfun(@plus,start_ind,[0:nrows-1])',[1 3 2]);  %//'

%// 2D linear indices
lidx_2D = reshape(bsxfun(@plus,lin_row,[0:ncols-1]*m),nrows*ncols,[]);

if (nargin==4)
    lidx_2D = lidx_2D(mask==1,:);
end

%// 3D linear indices
lidx_3D = bsxfun(@plus,lidx_2D,m*n*permute((0:r-1),[1 3 2]));

%// Get linear indices based on row and col indices and get desired output
out = A(lidx_3D);

if (nargin~=4)
    out2 = reshape(out,[nrows*ncols m-nrows+1 n-ncols+1 r]);
else
    out2 = out;
end

return;