Pandemo - Panorama stitching in Matlab
v1.0 (Jan 2009)

by
Pascal Steingrube (steingrube@i6.informatik.rwth-aachen.de)
Tobias Weyand     (weyand@i6.informatik.rwth-aachen.de)

Requirements
------------
  To use this software, you need:

  - A webcam
  - Matlab (R2008b was used for development, but older versions might still work)
  - The Image Acquisition Toolbox for Matlab (optional, for webcam capturing)
  - The Image Processing Toolbox for Matlab
  - The free demo version of David Lowe's SIFT detector, available from:
    http://www.cs.ubc.ca/~lowe/keypoints/

  Unfortunately, binaries for the SIFT demo are only available for Linux and
  Windows. If you want to use this demo under MacOS X, you have to use a
  different interest point detector and a different feature descriptor.

Installation
------------
  Download David Lowe's SIFT demo and extract it into the pandemo directory.

Usage
-----
  - Connect the webcam
  - Edit webcam.m and adjust the settings to your webcam
  - Create a webcam object by issuing
      cam=webcam(1);
  - Start the demo:
      perform1by1FromCam(cam, 3);

    The second parameter is the number of subsequent frames that are captured.

  Other demos:
    - img = performImages(imread('demoimages/demo1.png'),imread('demoimages/demo2.png'));
    - img = performFolder('performFolderDemo');

  You can compare affine and homography matching by trying out demo.m or editing
  perform*.m


Have Fun!