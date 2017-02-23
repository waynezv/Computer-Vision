function warp_im2 = warpA( im_gray, A, out_size )

t = -30*pi/180;
tform = affine2d([cos(t) -sin(t) 0; sin(t) cos(t) 0; 0 0 1]);
warp_im2 = imwarp(im_gray, tform);

end



