---
layout: post
title: MNIST database of handwritten digits for Octave
---

In this post you will see how to convert the MNIST database of handwritten digits via [rustml](/rustml/rustml/) into a format that can be read with [Octave](https://www.gnu.org/software/octave/).

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

Before you can perform the following steps you have to install Rust. If not already installed, download the latest version from [rust-lang.org](https://www.rust-lang.org) and execute the following commands. Otherwise you can skip the steps in the box below.

<pre>
# unpack the archive (the name of the archive may depend on your system configuration)
tar xzf ~/Downloads/rust-VERSION-x86_64-unknown-linux-gnu.tar.gz

# change into the directory
cd rust-VERSION-x86_64-unknown-linux-gnu/

# execute the install script with the destination directory
./install.sh --prefix=/opt/rust-VERSION

# add the rust directory to the search path
export PATH=/opt/rust-VERSION/bin:$PATH
</pre>

If Rust was installed successfully we can create a new project with cargo:

<pre>
cargo new --bin convert
</pre>

Append the following two lines (which specify the required dependencies and where to search for them) to `Cargo.toml` in the directory created by the command above.

<pre>
[dependencies]
rustml = { git = "https://github.com/daniel-e/rustml.git" }
</pre>

Now, overwrite the file `main.rs` in the directory `src` with the following content:

<pre>
extern crate rustml;

use std::fs::File;
use std::io::Write;

use rustml::datasets::MnistDigits;
use rustml::csv::matrix_to_csv;
use rustml::matrix::{Matrix, IntoMatrix};

fn write(f: &mut File, m: Matrix&lt;u8&gt;, s: &str) {

    f.write_all(format!(
        "# name: {}\n# type: matrix\n# rows: {}\n# columns: {}\n{}\n\n",
        s, m.rows(), m.cols(), matrix_to_csv(&m, " ")
    ).as_bytes()).unwrap();
}

fn main() {

    let (train_x, train_y) = MnistDigits::default_training_set().unwrap();
    let (test_x, test_y) = MnistDigits::default_test_set().unwrap();

    let mut f = File::create("mnist.txt").unwrap();

    write(&mut f, train_x, "trainX");
    write(&mut f, train_y.to_matrix(train_y.len()), "trainY");
    write(&mut f, test_x, "testX");
    write(&mut f, test_y.to_matrix(test_y.len()), "testY");
}
</pre>


After this run the program as follows:

<pre>
cargo run
</pre>

The output is written into the file `mnist.txt`. Because the size of the file is approx. 120MB and Octave can also handle compressed files we compress the text file with the command `gzip mnist.txt`. The result is a file `mnist.txt.gz` with a size of approx. 15MB.

Finally, this file can be loaded in Octave via the `load` function.

<pre>
octave:1> load("mnist.txt.gz");
octave:2> who
Variables in the current scope:

testX   testY   trainX  trainY

octave:3> size(trainX)
ans =

   60000     784
</pre>

