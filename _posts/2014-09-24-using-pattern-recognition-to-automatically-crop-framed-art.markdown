---
layout: post
title: "Using Pattern Recognition to Automatically Crop Framed Art"
date: 2014-09-24 10:28
comments: true
categories: [OpenCV, Pattern Recognition, Image Processing]
author: ilya
---

## Introduction

The [Indianapolis Museum of Art](https://artsy.net/imamuseum) (IMA) recently shared thousands of high-resolution images from its permanent collection with Artsy, including 5,000 images that were in an un-cropped state. These images contain color swatches, frames, and diverse backgrounds, as shown below. The clutter in these images made them inappropriate to display to end users, and invited an approach to automatically crop the images. This post explores some fully automated techniques to locate the piece of art within each photo. If you're eager to jump straight to the code that worked best, you'll find the implementation of the 'Rectangular Contour Search' section [here](https://gist.github.com/ilyakava/b2dbca43991d6c668dbb).

![All of these images are open access. For reference, the accession numbers/names. 45-115.tif 45-9-v01.tif 54-4.tif 76-166-1-12b.tif 14-57.tif](http://f.cl.ly/items/2C0e2X1G1R1i1z1Y0M1B/banner.png)

<!-- more -->

*Some samples from the IMA image dataset. The bold green shape indicates the best cropping choice found, and the thin yellow shapes are the alternative cropping choices.*

Our specific goal within this project was to find a rectangle that best contains the artwork within each photo. We want a program that finds a rectangle small enough to exclude the backgrounds, color swatches, and (preferably) frames in the images. At the same time, we want to avoid over-cropping the image and excluding the edges of the artwork, even if the artwork contains regions of flat color similar to the background. We are always searching for a rectangle that contains the artwork, so we need to take care and not be distracted by geometrical artworks like those of [Josef Albers](https://artsy.net/artwork/josef-albers-i-s-lxxb).

![Cropping choices within a Josef Albers painting.](http://f.cl.ly/items/2A1t3h1K2l2q362f3A1Y/albers.png)

*Cropping choices within a Josef Albers painting. Copyright The Josef and Anni Albers Foundation / Artists Rights Society (ARS), New York*

## Background

What follows is a summary of some useful background knowledge for interpreting the output of common image transformations. Included are the corresponding commands in python that rely on the [OpenCV](http://docs.opencv.org/master/) library which we used in this project.

### Blur Transformations

#### [Gaussian Blur](http://docs.opencv.org/master/modules/imgproc/doc/filtering.html?highlight=gaussianblur#cv2.GaussianBlur)

*Gaussian Smoothing* is a technique for reducing noise in an image by averaging each pixel with its surrounding pixels. To perform Gaussian Smoothing, an image is *convolved* with a square *filter matrix* (with an odd number of dimensions to ensure symmetry) whose values (*weights*) are defined by a Gaussian distribution with some standard deviation \\(\sigma\\). The filter matrix is also called a *kernel* in the context of convolution. Shown below is a \\(3\times3\\) kernel with a \\(\sigma\\) of 0:

$$\frac{1}{16}\begin{bmatrix}1 & 2 & 1
\\\\\
2 & 4 & 2
\\\\\
1 & 2 & 1  \end{bmatrix}$$

Convolution is a matrix multiplication technique commonly used in image processing. An interpretation of convolution is that it is a technique to decompose one matrix (an output matrix) into a sum of shifted and scaled impulse functions (input matrix convolved with the kernel). The mechanics of convolution are beyond the scope of this post, and can be found [here](http://www.songho.ca/dsp/convolution/convolution2d_example.html) and described more generally [here](http://www.songho.ca/dsp/convolution/convolution.html#convolution_2d).

The intended effect of Gaussian blur for our purposes is to disturb smaller boundaries and edges more than larger ones.

```python
blur = cv2.GaussianBlur(src = bw, ksize = (3,3), sigma = 0)
# to see the 3 by 3 filter matrix that the image bw is convolved with above:
cv2.getGaussianKernel(ksize = 3, sigma = 0) * cv2.getGaussianKernel(3, 0).T
```

#### [Median Blur Filter](http://docs.opencv.org/master/modules/imgproc/doc/filtering.html?highlight=medianblur#cv2.medianBlur)

The *Median Filter* is a technique where each pixel in an image is replaced by the median valued pixel within a square neighborhood around that pixel, making it a non-linear noise reduction technique. Median filters do not blur edges, but they do damage thin lines and corners.

```python
# uses the median in a 7 by 7 neighborhood to reassign each pixel
cv2.medianBlur(img, ksize = 7)
```

### Edges

Edges in an image are defined to be where brightness changes abruptly. Edge detection is performed with 2D derivatives called gradients, either by finding maximums in first order gradients, or inflection points in second order gradients. Derivatives are usually continuous functions, but the gradients we will look at approximate the derivative at discrete points throughout the image by comparing each pixel to its neighborhood of pixels to establish a gradient vector (which points in the direction of maximum brightness change).

#### [Sobel Filter](http://docs.opencv.org/master/modules/imgproc/doc/filtering.html?highlight=sobel#cv2.Sobel)

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

```python
# uses the above two partial derivatives
sobelx = cv2.Sobel(bw, cv2.CV_16S, 1, 0, ksize=3)
sobely = cv2.Sobel(bw, cv2.CV_16S, 0, 1, ksize=3)
abs_gradientx = cv2.convertScaleAbs(sobelx)
abs_gradienty = cv2.convertScaleAbs(sobely)
# combine the two in equal proportions
total_gradient = cv2.addWeighted(abs_gradientx, 0.5, abs_gradienty, 0.5, 0)
```

#### [Canny Edges](http://docs.opencv.org/master/modules/imgproc/doc/feature_detection.html?highlight=canny#cv2.Canny)

The Canny edge detector is a multi-stage process that combines the first and second order gradients in a way that optimizes:

1. Detection - missing few edges (thanks to sensitivity of 2nd order gradient)
2. Localization - precision of edges detected (thanks to precision of 2nd order gradient)
3. Single Responses - 1 edge detected per real edge (thanks to suppressing non-maxima values)

A full description of this technique can be found [here](http://en.wikipedia.org/wiki/Canny_edge_detector#Stages_of_the_Canny_algorithm). The aspect of it that interests us here is its use of *hysteresis thresholding* that helps the continuity of edges. This is a process where in order to ensure the continuity of edge contours, the first order gradient is taken over two thresholds and then recombined. A high threshold is used for finding edge points with precision, and then a low threshold for connecting edge points to each other.

```python
# apertureSize argument is the size of the filter for derivative approximation
cv2.Canny(bw, threshold1 = 0, threshold2 = 50, apertureSize = 3)
```

#### [Hough Lines](http://docs.opencv.org/master/modules/imgproc/doc/feature_detection.html?highlight=hough#cv2.HoughLines)

The Hough Transform tries to find lines in an image explainable by the linear equation \\(y=mx + b\\). A more convenient way of expressing this equation on an image plane is with: \\(d=xcos(\theta) + ysin(\theta)\\) where a point \\((x,y)\\) is explained by the normal distance from the origin to the line (\\(d\\)) and the angle between that normal line and the x axis (\\(\theta\\)). To search for lines, we:

1. Decide on a resolution for \\(d\\) and \\(\theta\\) that we are interested in.
    - We know that: \\(-image\ diagonal \leq d \leq image\ diagonal\\), and \\(-90 \leq \theta \leq 90\\) in degrees.
    - We choose a resolution that breaks up each of these continuous ranges into small enough discrete chunks, so that there are a total of \\(d^{n}\\) normal distances we will be interested in for each of \\(\theta^{n}\\) total angles.
2. We use this decision to create a matrix \\(H\\) called the Hough Space Accumulator that is \\(H \epsilon \mathbb{R}^{d^{n} \times \theta^{n}}\\).
3. For each edge point in our image:
    - increment \\(H\\) at every \\(d\\) and \\(\theta\\) pair that creates a line passing through that point
4. Pick the pairs of \\(d\\) and \\(\theta\\) that have an accumulator value in \\(H\\) above a certain threshold.

![The code used to generate this plot can be found [here](https://gist.github.com/ilyakava/c2ef8aed4ad510ee3987).](http://f.cl.ly/items/0K08010j1Q20070C2h0U/hough_by_hand.png)

*We search for Hough lines on a binary image. In this case we chose the top 22 lines to draw on the final image, their (\\(d\\), \\(\theta\\)) pairs are circled in blue on the accumulator matrix. The code used to generate this plot can be found in full [here](https://gist.github.com/ilyakava/c2ef8aed4ad510ee3987).*

```python
cv2.HoughLinesP(edges, rho = 1, theta = math.pi / 180, threshold = 70, minLineLength = 100, maxLineGap = 10)
```

### [Contour Search](http://docs.opencv.org/master/modules/imgproc/doc/structural_analysis_and_shape_descriptors.html?highlight=findcontours#cv2.findContours)

The contour search we used is a [border following technique for binary images](http://stackoverflow.com/questions/10427474/what-is-the-algorithm-that-opencv-use-for-finding-contours). It was developed to extract the hierarchical topology of a binary image, but that information is discarded in our use.

```python
contours, hierarchy = cv2.findContours(bin_img, mode = cv2.RETR_LIST, method = cv2.CHAIN_APPROX_SIMPLE)
```

## Experimental Evaluation

We used the powerful open source image processing library, [OpenCV](http://opencv.org), with python for our experiments. We operated on images with 400 pixels as their largest dimension. This decision was made in the interest of quick image transformations, but we confirmed later that there were no significant improvements in artwork border detection with larger images.

### Hough Lines

An early attempt at detecting artwork borders consisted of the following steps:

- Gaussian blur
- Combine x and y Sobel Filters (w/ scaling)
- Gaussian blur
- Canny edge detection
- Finding Hough lines
- Extrapolating the intersection of the Hough lines to get corners

The choice of the Sobel filter was motivated by the great number of artwork images with light and gradual transitions between the artworks and their surrounding mattes, as well as between the paper artworks and their backgrounds. The smoothing in the Sobel filter makes it an edge detector well equipped for gradual borders. The Gaussian blur was used to minimize the interfering details within the artworks. The Canny edge detector was then used to fill in discontinuities in the borders. Finally, Hough lines were found, in the hopes that the most prominent lines would be along the edges of the artwork.

![Corner detection working well. A high contrast background and a lack of geometrical shapes in the artwork led to occasional good performance. Open access image: 41-88.tif](http://f.cl.ly/items/3C1z3A172C0Y2C0x1F09/corner_good_case2.png)

*Corner detection working well. A lack of geometrical shapes in the artwork combined with strong artwork borders led to occasional good performance.*

Occasionally, the correct corners were found within 4-6 lines. More often, it took 30-50 lines for the correct corners to be identified. This method struggled to find Hough lines for discontinuous borders, which were common in our dataset and preprocessing techniques were not able to completely overcome. Often, since the content within the artwork, or far outside the artwork, was of much greater contrast than the border between the artwork and background, the most prominent lines were in fact within the artwork.

The chief problem with this approach was that once the sensitivity of the search was increased enough to find the correct edges, there were too many lines found overall. It was hard to distinguish the right lines from the wrong lines since the desired border lines were not longer, more horizontal or vertical, nor more common than undesirable lines within the artwork. Distinguishing between the resultant corners of all these lines was also a lost cause since there were often too many alternative corners that interfered with choosing the correct cropping. Searching for correct combinations of corners is futile since it grows \\(\mathcal{O}(n^{4})\\) at worst.

![Corner detection performing poorly. Open access images, accession numbers are top: 10-194-v01.tif, bottom: 11-101.tif](http://f.cl.ly/items/1u070G2u3O2r0Q0n0m32/combo_bad_case.png)

*Corner detection performing poorly. The top row shows a case where the content of the image starts to interfere with the border detection (which is even worse for some high contrast lithographs). The bottom row shows a case where lines outside of the artwork dominate the scene. It would be difficult to think of a ranking method that would work for both of these cases. The green circles show all of the potential corners found from intersection of Hough Lines.*

Tweaking preprocessing effects also greatly varied the performance across the dataset in a non-generalized way. A tweak that would improve performance in one set of images would inhibit finding the correct Hough lines in another set.

### Rectangular Contour Search

We went a different direction and instead decided to take advantage of a more specific feature within our dataset. We started searching for rectangular closed contours with the following strategy:

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

![The Rectangular Contour Search workflow stages in pictures. The code used to generate this figure can be found [here](https://gist.github.com/ilyakava/b2dbca43991d6c668dbb). Open Access, accession number/filename: 2008-364b_v01.tif](http://f.cl.ly/items/0L2t2z2h3w3O130C2T0s/flow.png)

*The Rectangular Contour Search workflow stages. The code used to generate this figure can be found in full [here](https://gist.github.com/ilyakava/b2dbca43991d6c668dbb).*

This method fared much better than the Hough lines technique because it was much more immune to discontinuities in our borders of interest (thanks in part to the dilation and resizing, but mostly to the contour search). Dilation had the effect of thickening the desired edges, and flooding out the less significant edges within the artwork. Resizing the artwork (shrinking and then enlarging) had the effect of removing isolated noise outside of the border, making for an easier to single out border ([Pomplun](http://www.cs.umb.edu/~marc/cs675/cvs09-12.pdf)).

Because this method searched for a more specific feature than the Hough lines method (rectangles rather than simply lines), interference from the content of the artworks was subdued. In addition, we gained the possibility of ranking the different shapes found accurately. While useful versus useless Hough lines were indistinguishable quantitatively, contours could easily be ranked by their distortion (we are always looking for rectangles), their displacement from the center of the image (should be the central object of interest), and their size.

This was the best performing method we tried, and achieved a 85% success rate on our dataset. It also carried the benefit that obvious failures were easy to report. If no rectangles were found (15% of the time with the IMA set) this failure could be recorded in a spreadsheet, rather than generating a result image that needed to be visually inspected.

The code we used is available in full [here](https://gist.github.com/ilyakava/b2dbca43991d6c668dbb). See the images in this project, as well as others for the [Indianapolis Museum of Art on Artsy](https://artsy.net/imamuseum).

## Previous Work

Below is a quick survey of some similar previous work that helped us during research.

- High contrast sheet of paper localization:
    - [mmgp's answer](http://stackoverflow.com/a/14368605/2256243) incorporated using a median filter, then a morphological gradient (good for strong edges), thresholding (guided by Otsu), and then isolating the correct shape by comparing the area of the convex hull containing the shape and the area of its bounding box (01/16/2013).
    - [karlphillip's answer](http://stackoverflow.com/a/8863060/2256243) incorporated using a median filter, Canny edges with dilation, finding all contours, and finally outputing the largest such rectangle (01/14/2012).
- Subtle drawn square in a photo localization:
    - [karlphillip's answer](http://stackoverflow.com/a/7732392/2256243) incorporated dilating the image, using medianBlur, downscaling and upscaling the image, and then continuing the same way as with his [Sheet of paper localization answer](http://stackoverflow.com/a/8863060/2256243) (10/11/2011).
- Obvious but partially blocked square localization:
    - [karlphillip's answer](http://stackoverflow.com/a/10535042/2256243) used thresholding, and the find squares and bounding box functions (05/10/2012).
    - [mevatron's answer](http://stackoverflow.com/a/10535042/2256243) used thresholding, Gaussian blur, Canny, and a sensitive search for many Hough lines (05/10/2012).
- Receipt Localization:
    - [Martin Foot's answer](http://stackoverflow.com/a/6555842/2256243) used the Median Filter, Hough transform, drawing lines across the entire image and filtering out lines that are close to each other, or have few other lines that are nearly parallel to them (06/02/2011).
    - [Daniel Crowley's answer](http://stackoverflow.com/a/6644246/2256243) suggested using Low canny restraints, and searching for the largest closed contour (06/02/2011).
    - [Vanuan's answer](http://stackoverflow.com/a/6644246/2256243) used Gaussian blur, dilation, Canny edges, finding contours, and simplified the contours to polygons (09/20/2013).
- Correcting the perspective of a white card on dark surface. A [tutorial](http://opencv-code.com/tutorials/automatic-perspective-correction-for-quadrilateral-objects/) on Hough Lines.
- An in depth [tutorial](http://nabinsharma.wordpress.com/2012/12/26/linear-hough-transform-using-python/) of Hough Lines with python code.

## References

[Kenneth Daweson-Howe's textbook](http://www.amazon.com/Practical-Introduction-Computer-Wiley-IS-Technology/dp/1118848454) is the source of most of the knowledge in the Background section, as well as the excellent [opencv documentation](http://docs.opencv.org/master/) which often included tutorials.
