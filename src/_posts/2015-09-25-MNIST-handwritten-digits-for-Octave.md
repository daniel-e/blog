---
layout: post
title: MNIST database of handwritten digits for Octave
---

In this post you will see how to convert the MNIST database of handwritten digits into a format that can be read with Octave.

The MNIST database of handwritten digits (see [here](http://yann.lecun.com/exdb/mnist/)) is a very popular dataset used by the machine learning research community for testing the performance of classification algorithms. It contains 60,000 labeled training examples of handwritten digits between 0 and 9 (both including) and 10,000 labeled examples for testing. Each digit is represented as a grayscale image each with a width and height of 28 pixels. The value of a pixel is in the interval [0, 255].

Because the database from the link above is in a format that cannot be directly processed with Octave we will use [rustml](/rustml/rustml) to convert into an Octave friendly format.

## Download the dataset 
First, we need to download the dataset. As described [here](https://github.com/daniel-e/rustml#rustml-datasets-package) we execute the following commands on the command line:

<pre>
# download the installer script
wget -q https://raw.githubusercontent.com/daniel-e/rustml/master/dl_datasets.sh

# execute the script
bash ./dl_datasets.sh
</pre>

The datasets are downloaded into the directory `~/.rustml/`.

## Converting the dataset

Now, we can create a new Rust project with

<pre>
cargo new --bin convert
</pre>

and append the following two lines to `Cargo.toml`:

<pre>
[dependencies]
rustml = { git = "https://github.com/daniel-e/rustml.git" }
</pre>



