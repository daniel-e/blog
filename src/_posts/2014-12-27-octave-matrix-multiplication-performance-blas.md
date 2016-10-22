---
layout: post
title: Octave matrix multiplication performance for different BLAS implementations
---

Octave is a tool for doing linear algebra. When doing linear algebra one of the most fundamental operations is the [matrix multiplication](http://en.wikipedia.org/wiki/Matrix_multiplication). A straightforward algorithm to do a matrix operation requires O(n³) multiplications. In 196 [Strassen developed an algorithm](http://en.wikipedia.org/wiki/Matrix_multiplication#Algorithms_for_efficient_matrix_multiplication) for multiplying big matrices (n > 100 to 1000) which requires O(n^2.807) multiplications.

Octave can use different implementations for doing matrix multiplication, e.g. [BLAS](http://en.wikipedia.org/wiki/Basic_Linear_Algebra_Subprograms), [ATLAS](http://en.wikipedia.org/wiki/Automatically_Tuned_Linear_Algebra_Software) and [OpenBLAS](http://www.openblas.net/). We have measured the performances of the different implementations for this post.

All tests were running on a quad-core Intel(R) Core(TM) i7-2670QM CPU @ 2.20GHz with hyperthreading enabled. As Linux we used Linux Mint 17 (Qiana) on which we installed the packages "octave" and "libatlas3-base". This configuration we will refer to as "default" in this post. We have also tested ATLAS, the single-threaded ("satlas") and the multi-threaded ("tatlas") versions and OpenBLAS ("openblas") which is multi-treaded by default.

Before we compiled ATLAS we have configured it with the following arguments:

<pre><code class="bash">./configure -b 64 --shared -D -c -DPentiumCPS=2200 --with-netlib-lapack-tarfile=lapack-3.5.0.tgz
</code></pre>

For OpenBLAS we used the default configuration and just executed make to create the libraries.

As all libraries have been created we started Octave as follows:

<pre>default : octave -p perf.m
satlas  : LD_PRELOAD=libsatlas.so octave -p perf.m
tatlas  : LD_PRELOAD=libtatlas.so octave -p perf.m
openblas: LD_PRELOAD=libopenblas.so octave -p perf.m
</pre>

The fastest implementation is OpenBLAS. It took 5.1 seconds to multiply a 5000x5000 matrix. The multi-threaded ATLAS implementation took 6.9 seconds, the single-threaded implementation took 18 seconds and the default configuration required 32 seconds to multiply the matrix.

Just for comparison we also added 100 times a 5000x5000 matrix. It took for all implementations about 13.5 seconds, i.e. one 5000x5000 matrix addition took approximately 0.135 seconds.

![performance of different blas implemenations](/assets/perfchartmult1.png)

