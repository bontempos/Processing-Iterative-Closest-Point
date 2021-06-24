# Processing Iterative Closest Point
 Iterative Closest Point (ICP) approach on P5


When running this sketch, click any key to move though the steps in the code, while also observing the console output.

In computer vision, Iterative Closest Point are used to match sets of points from point cloud scans.
In this example, a set of 2D points (Q) is duplicated (P) and perturbed (rigid transformation: translated, rotated)

The algorithm attempts to find move/rotate the set P so points aligns over Q.

The same algorithm can be expanded to 3D point sets.

This Processing version is a initial adaptation from:
https://nbviewer.jupyter.org/github/niosus/notebooks/blob/master/icp.ipynb

Inside ICP, there are numerous methods to achieve the goals.
Have more fun reading the material on the link above.

