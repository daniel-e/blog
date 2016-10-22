---
layout: post
title: Maximum GFLOPS for an element-wise matrix multiplication
---

A question that often comes into my mind when doing computations with Octave or other numerical libraries is how good do they utilize the CPU. Recently I was interested in estimating the number of GFLOPS that can be achieved with Octave for the element-wise matrix multiplication. For an nxn matrix exactly n*n multiplications (by default double precision floating point operations) have to be executed. Hence, to estimate the number of GFLOPS we just need to measure the time that is required for that number of operations to be executed.

So, I wrote the following Octave script:

{% highlight matlab %}
1;

n = 4096;
x = rand(n, n);
tic, x .* x;
y = toc
printf('GFLOPS: %f\n', n * n / y / 1e9);
{% endhighlight %}

I have saved this script as "mult.m", started Octave and executed the script:

{% highlight bash %}
xx@host ~ $ octave -q
octave:1> mult
y = 0.081134
GFLOPS: 0.206784
octave:2>
{% endhighlight %}

For 4096 * 4096 = 16M multiplications the script took 0.08 seconds. According to the spec the theoretical GFLOPS of my four cores is 70.4. With Octave we can achieve just 0.2 GFLOPS for an element-wise matrix multiplication.

*This is less than 1% of the theoretical peak performance!*

To compute the element-wise matrix multiplication we must read at least once from main memory to read a source operand, perform the computation and write the result back to main memory. So one question is how much is that operation affected because of reading and writing memory?

I wrote a C++ program to measure the number of milliseconds required to copy 128MB from one memory location to another memory location. My assumption is that memcpy is well optimized and thus the fastest way to copy data so that I can use the time that memcpy requires for just copying as a lower bound for my further calculations.

{% highlight cpp %}
#include <string.h>
#include <stdlib.h>
#include <iostream>
#include <chrono>

using namespace std::chrono;

int main()
{
        #define N (4096 * 4096 * 8)
        char* c = (char*) malloc (N);
        char* d = (char*) malloc (N);
        memset(c, 0, N);
        auto start = std::chrono::system_clock::now();
        memcpy(d, c, N);
        auto duration =
                duration_cast<milliseconds>(
                        system_clock::now() - start
                );
        std::cout << duration.count() << std::endl;
}
{% endhighlight %}

I compiled the code and executed the binary several times:

{% highlight bash %}
g++ -O3 memmv.cc --std=c++11 -o memmv
xx@host ~ $ ./memmv
72
{% endhighlight %}

As we can see copying 128MB takes 72 milliseconds. Hence, the element-wise matrix multiplication with 16M double precision floating point operations must take at least 72 milliseconds. A maximum of 16M floating point operations in 72 milliseconds implies that we cannot perform more than 16M / 0.072 / 1e9 = 0.233 GFLOPS.

To summarize the results: I have shown how we can derive from experiments and calculations an upper bound for the maximum number of GFLOPS that can be executed for an element-wise double precision matrix multiplication by any numerical library. I have shown that the maximum number of GFLOPS that can be done especially on my system for an element-wise matrix multiplication is 0.233 GFLOPS and that Octave can do it with 0.2 GFLOPS which is approximately 86% of the theoretical peak. Although Octave is near to the optimum 0.2 GFLOPS are far away from the theoretical 17.6 GFLOPS for one CPU. The experiments show that the main reason for this comes from the limited memory bandwidth.

The code for these experiments can be found on Github: [https://github.com/daniel-e/misc/tree/master/measure_flops](https://github.com/daniel-e/misc/tree/master/measure_flops)

