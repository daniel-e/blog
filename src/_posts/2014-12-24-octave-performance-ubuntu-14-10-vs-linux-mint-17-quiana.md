---
layout: post
title: Octave performance - Ubuntu 14.10 vs Linux Mint 17 Qiana
---

Recently I played around with Octave that I've installed on Ubuntu 14.10 running in a Docker container. The host system on which Docker is running is a Linux Mint 17 (Qiana). I was wondering whether there is a significant overhead induced by Docker when doing big matrix multiplications. So, I've done a quick test in Octave. First,  I have multiplied a 5000x5000 matrix with Octave on Ubuntu 14.10 in the Docker container. Then, I have multiplied another matrix with the same dimensions on Linux Mint 17. The very surprising result was as follows:

![performance doing a matrix multiplication](/assets/matrix_multiplication_ubuntu_vs_mint.png)

As you can see multiplying a 5000x5000 matrix on Ubuntu 14.10 was 5x faster than doing the same operation on Linux Mint 17. It took 31 seconds in the Ubuntu container and 161 seconds on the Linux Mint system.

The exact Octave command I was doing was the following one:

<pre><code class="matlab">octave:1> x = rand(5000, 5000);
octave:2> tic, x*x; toc
</code></pre>

Neither Octave on Ubuntu nor Octave on Linux Mint used more than one thread for the multiplication. Both versions consumed 100% of one CPU during the complete computation.

*So the question was why Octave that comes with Ubuntu is 5x faster compared to Octave that comes with Linux Mint 17?*

I've started Octave on the host system, determined the process id and looked at the libraries which the process has opened. I compared the list of these libraries with the list of libraries that have been opened by Octave that comes with Ubuntu.

One difference that was conspicuous was the fact that the process on the host did not open the ATLAS library.

Host/Linux Mint 17:

<pre><code class="bash">xx@linuxmint ~ $ sudo lsof -p 19673 | egrep "blas|atlas|lapack"
/usr/lib/libblas/libblas.so.3.0
/usr/lib/lapack/liblapack.so.3.0
</code></pre>

Docker/Ubuntu:

<pre><code class="bash">root@ada77fe6ef60:/tmp $ sudo lsof -p 751 | egrep "blas|atlas|lapack"
/usr/lib/atlas-base/libatlas.so.3.0
/usr/lib/atlas-base/atlas/libblas.so.3.0
/usr/lib/atlas-base/atlas/liblapack.so.3.0
</code></pre>

I've looked whether the ATLAS library was installed on the host system, but it wasn't. So I installed it with the following command:

<pre><code clsas="bash">sudo apt-get install libatlas3-base
</code></pre>

I've started Octave again and finally Octave on the host did the matrix multiplication in 31 seconds, as fast as Octave that comes with Ubuntu.

Now, when looking at the opened libraries on the host we can see the dependency to the ATLAS library (libblas.so.3 is now taken from a different path):

<pre><code class="bash">xx@linuxmint ~ $ lsof -p 13463 | egrep "blas|atlas|lapack"
/usr/lib/atlas-base/atlas/libblas.so.3.0
/usr/lib/lapack/liblapack.so.3.0
</code></pre>
