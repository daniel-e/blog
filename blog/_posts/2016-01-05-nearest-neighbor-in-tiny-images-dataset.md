---
layout: post
title: Nearest neighbor search in the Tiny Images dataset
---

The Tiny Images dataset consists of 79,302,017 images, each being a 32x32 color RGB image.
The images have been retrieved from the Internet from several image search engines,
are stored in an uncompressed large binary file (227GB) so that each image can be easily
accessed via random access and are loosely labeled with one of the 75,062 non-abstract
nouns in English as listed in the Wordnet lexical database. To download the file or to
get more details about the dataset you should visit
[this site](http://horatio.cs.nyu.edu/mit/tiny/data/index.html).

As shown in the paper "80 million tiny images: a large dataset for non-parametric object and scene recognition" 
which can be downloaded [here](http://people.csail.mit.edu/billf/www/papers/80millionImages.pdf) this
dataset can be used for some quite
interesting tasks like scene detection, object detection and localization and image annotation.

In this blog post I will show you how to do a simple k-nearest neighbor search in this
database to search similar images to a given query image. The results are not very impressive but
the code can be used as a basis for further more sophisticated experiments.
The scripts and the source code of this post are available via
[GitHub](https://github.com/daniel-e/tinyimages/tree/master/knn).

First, lets have a look at the dataset. The script `mosaic.py` can be used to retrieve
images from the Timy Images dataset. The output of the script is an image where the tiny
images are organized in a grid. The first image is located in the first row and first column,
the second image is located in the first row and second column and so on (i.e. column-major
order). For example, the following command produces the image below which
contains 100 random images from the dataset in 20 columns und 5 rows. The random number
generator to generate the random numbers is seeded with the value 123 just to get
reproducible results.

{% highlight bash %}
mosaic.py --db tiny_images.bin -o output.jpg -c 20 --seed 123
{% endhighlight %}

![mosaic of tiny images dataset](/assets/tiny_images_knn/tinyimages-mosaic.jpg)

If you want to extract images at specific positions you can append the position
of each image as an argument. For example, the following command retrieves the first 10
images of the Tiny Images dataset.

{% highlight bash %}
mosaic.py --db tiny_images.bin -o output.jpg 0 1 2 3 4 5 6 7 8 9
{% endhighlight %}

# Executing a search

Doing a simple k-nearest neighbor search in the whole dataset is quite easy.
First, we need to perform
a preprocessing step to normalize the image. The query image must be scaled to 32x32
pixels and it must be a color image with the three color channels red, green and
blue. After the preprocessing step we can use the script `knn.py` to search for the
nearest neighbors.

The following commands demonstrate these steps for an image that is part of
this repository.

{% highlight bash %}
# preprocessing: rescale the query image
convert -resize '32x32!' images/img.google.00000 queryimage.jpg
# perform the search
knn.py --db tiny_images.bin -v queryimage.jpg | sort -g -S 2G | head -n 10000 > scores.txt
{% endhighlight %}

The output of `knn.py` is one line for each image of the Tiny Images dataset. Each line
contains the score in the first column (i.e. the Euclidean distance between the query image
and the image in the dataset) and the position of the image in the Tiny Images
dataset.

In the example above we sort the output by the score and select only the first 10000 lines
which are the 10000 nearest neighbors. We can now inspect the nearest neighbors by creating
an image from the nearest neighbors.

{% highlight bash %}
# create a mosaic image for the first 100 nearest neighbours
head -n 100 scores.txt | awk '{print $2}' | \
	xargs mosaic.py --db tiny_images.bin -o output.jpg
{% endhighlight %}

Here are the results. For the following query image 

![nearest neighbors](/assets/tiny_images_knn/query_image_for_nearest_neighbors.jpg)

these are the most similar images:

![nearest neighbors](/assets/tiny_images_knn/nearest_neighbors.jpg)

## Performance

On my workstation (i7-4790, Quadcore + Hyperthreading) it takes approximately
30 minutes for a single search. The disk is the bottleneck which can provide just
about 100MB/s for sequential I/O. To measure the maximum performance of the
`knn.py` script I have created a ramdisk with a capacity of 3GB and copied the
first 3GB of the Tiny Images dataset to that disk. Then, I did run the
`knn.py` script once again.

{% highlight bash %}
# create the ramdisk
sudo mount -t tmpfs -o size=3g tmpfs /mnt/ramdisk/
# copy the first 3GB of the dataset to the ramdisk
dd if=tiny_images.bin of=/mnt/ramdisk/tiny_images.bin bs=1M
# run knn.py
knn.py --db /mnt/ramdisk/tiny_images.bin -v queryimage.jpg >/dev/null
{% endhighlight %}

With the data being read from main memory the maximum bandwidth of the
script is 390MB/s now. Thus, with a SSD the time required for a single
search could be reduced to about eight minutes.

Even without a SSD you could profit from further parallelism. If you want
to search the nearest neighbors for more than one image you could start
several `knn.py` scripts at the same time, one instance for each query
image. If one script reads the data
from the disk with about 100MB/s the other scripts can read the data from
the cache (>3GB/s) and are not bounded by disk I/O anymore. With this
simple approach, we can run as many instances as required to get bounded
by CPU now. I have successfully tested this approach with four instances
running at the same time. I wasn't bounded by disk I/O anymore and was able
to increase the throughput by a factor of about four.

# Running as a framework

The repository comes with example images in the `images/` directory and
a `Makefile` which can be used to search for the nearest neighbors for each
image in that directory. So, to run your own experiments for a set of images
you just have to put your images into the `images/` directory and run
the Makefile. But before doing this you have to set the
environment variable TINYIMAGE to the location of your Tiny Images
dataset. Then, you can execute the Makefile by running `make` on the
command line.

{% highlight bash %}
export TINYIMAGES=<location of tiny_images.bin>
make
{% endhighlight %}

The results are stored in the directory `outputs` which contains the
following directories and files:

* `images_small/`: contains the normalized query images scaled to 32x32 pixels which are used for the knn search
* `scores/`: contains the scores (i.e. the Euclidean distances) for each query image
* `summary_images/`: contains for each query image an image with the top nearest neighbors
* `summary.pdf`: a PDF created from the images in `summary_images`

Before running another experiment you should run `make clean` to remove
the data (i.e. the directory `outputs`) of the previous experiment or you
simply move the `outputs` directory to another location.
