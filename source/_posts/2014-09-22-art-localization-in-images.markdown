---
layout: post
title: "Art Localization in Images"
date: 2014-09-22 10:28
comments: true
categories: [OpenCV, Image Processing]
author: Ilya Kavalerov
github-url: https://www.github.com/ilyakava
twitter-url: http://twitter.com/ilyakava
blog-url: http://ilyakavalerov.com
---

## Introduction

Artsy was recently given 5,000 images of art by the Indianapolis Museum of Art (IMA) in an un-cropped state, containing color swatches, frames, and diverse backgrounds, as shown below. The clutter in these images made them inappropriate to display on the Artsy website to end users, and invited an approach to automatically crop the images. This post explores some fully automated techniques to locate the piece of art within each photo in order to crop the images and make them displayable to Artsy users.

![Some samples from the IMA image dataset. The bold green shape indicates the best cropping choice found, and the thin yellow shapes are the alternative cropping choices.](http://f.cl.ly/items/2K2V2s2H2R090W2O1k1r/samples.png)

*Some samples from the IMA image dataset. The bold green shape indicates the best cropping choice found, and the thin yellow shapes are the alternative cropping choices.*

Our goal with this project was to find a rectangle that best contains the artwork within each photo. This requires a program that finds a rectangle small enough that excludes the backgrounds, color swatches, and (preferably) frames in the images, but also large enough to not exclude any of the artwork, even if the artwork contains regions of flat color similar to the background. Our goals also required that geometrical artworks, like those of [Josef Albers](https://artsy.net/artwork/josef-albers-i-s-lxxb), were not over-cropped.

![Cropping choices within a Josef Albers painting.](http://f.cl.ly/items/2A1t3h1K2l2q362f3A1Y/albers.png)

*Cropping choices within a Josef Albers painting.*

## Background

What follows is a summary of some useful background knowledge for interpreting the output of common image transformations. This information helped inform us on which parameters to tweak in order to improve performance within our dataset.

### Blur Transformations

#### Gaussian Blur

*Gaussian Smoothing* is a technique for reducing noise in an image by averaging each pixel with its surrounding pixels. To perform Gaussian Smoothing, an image is *convolved* with a square *filter matrix* (with an odd number of dimensions to ensure symmetry) whose values (*weights*) are defined by a Gaussian distribution with some standard deviation \\(\sigma\\). The filter matrix is also called a *kernel* in the context of convolution. Shown below is a \\(3\times3\\) kernel with a \\(\sigma\\) of 0:

$$\frac{1}{16}\begin{bmatrix}1 & 2 & 1
\\\\\
2 & 4 & 2
\\\\\
1 & 2 & 1  \end{bmatrix}$$

Convolution is a matrix multiplication technique commonly used in image processing. An interpretation of convolution is that it is a technique to decompose one matrix (an output matrix) into a sum of shifted and scaled impulse functions (input matrix convolved with the kernel). The mechanics of convolution are beyond the scope of this post, and can be found [here](http://www.songho.ca/dsp/convolution/convolution2d_example.html) and described more generally [here](http://www.songho.ca/dsp/convolution/convolution.html#convolution_2d).

The intended effect of Gaussian blur for our purposes is to disturb smaller boundaries and edges more than larger ones.

#### Median Blur Filter

The *Median Filter* is a technique where each pixel in an image is replaced by the median valued pixel within a square neighborhood around that pixel, making it a non-linear noise reduction technique. Median filters do not blur edges, but they do damage thin lines and corners (Dawson-Howe).

### Edges

Edges in an image are defined to be where brightness changes abruptly. Edge detection is performed with 2D derivatives called gradients, either by finding maximums in first order gradients, or inflection points in second order gradients. Derivatives are usually continuous functions, but the gradients we will look at approximate the derivative at discrete points throughout the image by comparing each pixel to its neighborhood of pixels to establish a gradient vector (which points in the direction of maximum brightness change).

#### Sobel Filter

The *Sobel Filter* is an approximation to the first order gradient of an image. Using two orthogonal \\(3\times3\\) convolution matrices which each approximate a partial derivative of an image (in the x and y directions), it is possible to merge the results of the two convolutions to approximate the gradient of an image. The two relevant kernels to approximate the x and y direction gradient magnitudes are:

$$
\begin{bmatrix}1 & 2 & 1
\\\\\
0 & 0 & 0
\\\\\
-1 & -2 & -1  \end{bmatrix}
\ and\
\begin{bmatrix}1 & 0 & 1
\\\\\
2 & 0 & 2
\\\\\
1 & 0 & 1  \end{bmatrix}
$$

The variation in weights within the two kernels has the effect of incorporating smoothing, and is helpful for grayscale images where edge transitions are several pixels wide and where points along an edge might be slightly separated.

#### Canny Edges

The Canny edge detector is a multi-stage process that combines the first and second order gradients in a way that optimizes:

1. Detection - missing few edges (thanks to sensitivity of 2nd order gradient)
2. Localization - precision of edges detected (thanks to precision of 2nd order gradient)
3. Single Responses - 1 edge detected per real edge (thanks to suppressing non-maxima values)

A full description of this technique can be found [here](http://en.wikipedia.org/wiki/Canny_edge_detector#Stages_of_the_Canny_algorithm). The aspect of it that interests us here is its use of *hysteresis thresholding* that helps the continuity of edges. This is a process where in order to ensure the continuity of edge contours, the first order gradient is taken over two thresholds and then recombined. A high threshold is used for finding edge points with precision, and then a low threshold for connecting edge points to each other.

#### Hough Lines

The Hough Transform tries to find lines in an image explainable by the linear equation \\(y=mx + b\\). A more convenient way of expressing this equation on an image plane is with: \\( d=xcos(\theta) + ysin(\theta) \\) where a point \\((x,y)\\) is explained by the normal distance from the origin to the line (\\(d\\)) and the angle between that normal line and the x axis (\\(\theta\\)). To search for lines, we:

1. Decide on a resolution for \\(d\\) and \\(\theta\\) that we are interested in.
    - We know that: \\(0 \leq d \leq image\ diagonal\\), and \\(0 \leq \theta \leq 180\\) in degrees.
    - We choose a resolution that breaks up each of these continuous ranges into small enough discrete chunks, so that there are a total of \\(d^{n}\\) normal distances we will be interested in for each of \\(\theta^{n}\\) total angles.
2. We use this decision to create a matrix \\(H\\) called the Hough Space Accumulator that is \\(H \epsilon \mathbb{R}^{d^{n} \times \theta^{n}}\\).
3. For each edge point in our image:
    - increment \\(H\\) at every \\(d\\) and \\(\theta\\) pair that creates a line passing through that point
4. Pick the pairs of \\(d\\) and \\(\theta\\) that have an accumulator value in \\(H\\) above a certain threshold.

![The code used to generate this plot can be found [here](https://gist.github.com/ilyakava/c2ef8aed4ad510ee3987).](http://f.cl.ly/items/3A3i1q3D2i40310J3J2W/hough_by_hand.png)

*The code used to generate this plot can be found [here](https://gist.github.com/ilyakava/c2ef8aed4ad510ee3987).*

### Contour Search

The contour search we used is a [border following technique for binary images](http://stackoverflow.com/questions/10427474/what-is-the-algorithm-that-opencv-use-for-finding-contours). It was developed to extract the hierarchical topology of a binary image, but that information is discarded in our use.

## Experimental Evaluation

### Hough Lines

![Corner detection working well. A high contrast background and a lack of geometrical shapes in the artwork lead to occasional good performance.](http://f.cl.ly/items/2n110Q3d0q3w3k2q3u0r/corner_good_case.png)

*Corner detection working well. A high contrast background and a lack of geometrical shapes in the artwork lead to occasional good performance.*

An early attempt consisted of the following steps:

- Gaussian blur
- Combine x and y Sobel Filters (w/ scaling)
- Gaussian blur
- Canny edge detection
- Finding Hough lines
- Extrapolating the intersection of the Hough lines to get corners

This method struggled to find Hough lines for discontinuous borders, which were common in our dataset. Often, since the content within the artwork was of much greater contrast than the border between the artwork and background, the most prominent lines detected were within the artwork.

The chief problem with this approach was that once the sensitivity of the search was increased enough to find the correct edges, there were too many lines found at that point. It was hard to distinguish the right lines from the wrong lines since the desired border lines were not longer, more horizontal or vertical, nor more common than undesirable lines within the artwork. Distinguishing between the resultant corners of all these lines was also a lost cause since there were often too many alternative corners that interfered with choosing the correct cropping. Searching for correct combinations of corners is futile since it grows \\(\mathcal{O}(n^{4})\\) at worst.

![A high contrast lithograph performs poorly. The green circles show all of the potential corners found from intersection of Hough Lines.](http://f.cl.ly/items/2v151z3j030N3j1h2l2l/corner_hell.png)

*A high contrast lithograph performs poorly. The green circles show all of the potential corners found from intersection of Hough Lines.*

Tweaking preprocessing effects also greatly varied the performance across the dataset in a non-generalized way. A tweak that would improve performance in one set of images would inhibit finding the correct Hough lines in another set.

### Rectangular Contour Search

The Rectangular Contour method can be broken down into:

- Preprocessing the image to minimize non-target edges
    - Dilation
    - Median Blur Filter
    - Shrinking and enlarging
- Canny edge detection with dilation
- Searching for contours along the edges
- Throwing out all contours not fulfilling the constraints:
    - exactly 4 points
    - right angles (5 degree tolerance)
- Picking the best of the remaining contours, that minimizes a combination of:
    - Shape distortion
    - Proportion of the image's surface area
    - Displacement of the shape from the center of the image

![The Rectangular Contour Search workflow stages in pictures. The code used to generate this figure can be found [here](https://gist.github.com/ilyakava/b2dbca43991d6c668dbb).](http://f.cl.ly/items/0o0N2k0d0s2u2p381G1l/flow.png)

*The Rectangular Contour Search workflow stages in pictures. The code used to generate this figure can be found [here](https://gist.github.com/ilyakava/b2dbca43991d6c668dbb).*

This method fared much better than the Hough lines technique because it was much more immune to discontinuities in our borders of interest (thanks to dilation and contour search), and because it made interference from within each artwork less likely. Because this method searched for a more specific feature than the Hough lines method (rectangles rather than simply lines), interference from the content of the artworks was subdued. In addition, the ranking of contours, especially the displacement of the shape from the center of the image, minimized cases where squares within the artworks were selected as crop contours.

This was the best performing method we tried, and achieved a 85% success rate in our dataset. It also carried a benefit that obvious failures were easy to report. If no rectangles were found (15% of the time with the IMA set) this failure could be recorded in a spreadsheet, rather than generating a result image that needs to be visually inspected.

## Previous Work

Below is a quick survey of some similar previous work that helped us during research.

- High contrast sheet of paper localization:
    - [mmgp's answer](http://stackoverflow.com/a/14368605/2256243) incorporated using a median filter, then a morphological gradient (good for strong edges), thresholding (guided by Otsu), isolating the correct shape by comparing the area of the convex hull containing the shape and the area of its bounding box (01/16/2013).
    - [karlphillip's answer](http://stackoverflow.com/a/8863060/2256243) incorporated using a median filter, Canny edges with dilation, finding all contours, and outputing the largest such rectangle (01/14/2012).
- Subtle drawn square in a photo localization:
    - [karlphillip's answer](http://stackoverflow.com/a/7732392/2256243) incorporated dilating the image, using medianBlur, downscaling and upscaling the image, and then continuing the same way as with his 01/14/2012 Sheet of paper localization answer (10/11/2011).
- Obvious but partially blocked square localization:
    - [karlphillip's answer](http://stackoverflow.com/a/10535042/2256243) used thresholding, and using the find squares function or bounding box function (05/10/2012).
    - [mevatron's answer](http://stackoverflow.com/a/10535042/2256243) used thresholding, Gaussian blur, Canny, and a sensitive search for many Hough lines (05/10/2012).
- Receipt Localization:
    - [Martin Foot's answer](http://stackoverflow.com/a/6555842/2256243) used the Median Filter, Hough transform, drawing lines across entire image and filtering out lines that are close to each other, and have few other lines that are nearly parallel to them (06/02/2011).
    - [Daniel Crowley's answer](http://stackoverflow.com/a/6644246/2256243) suggested to use Low canny restraints, and to search for the largest closed contour (06/02/2011).
    - [Vanuan's answer](http://stackoverflow.com/a/6644246/2256243) used Gaussian blur, dilation, Canny edges, finding contours, simplifying the contours to polygons (09/20/2013).

## References

Our chief references were the excellent [opencv documentation](http://docs.opencv.org/master/) which often included tutorials, as well as [Kenneth Daweson-Howe's textbook](http://www.amazon.com/Practical-Introduction-Computer-Wiley-IS-Technology/dp/1118848454).
