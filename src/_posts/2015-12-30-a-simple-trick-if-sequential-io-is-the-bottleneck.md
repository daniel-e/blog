---
layout: post
title: A simple trick if sequential I/O is the bottleneck
---

In the following post I will show you a simple trick to increase the throughput
of a disk's sequential I/O up to two orders of magnitude if for some
computation the sequential I/O is the bottleneck and computation can be
parallized. I will motivate this via an approach that is typically used for
machine learning experiments, i.e. pipelining.

# Data processing via pipelines

In machine learning we often use pipelines for data processing. Some process
B consumes and processes the output of some process A and passes the result
to the input of another other process C and so on. This flow of data is
illustrated in the following diagram.

![data processing pipeline](/assets/io-bottleneck/pipeline.svg)

When using Linux this can be realized very easily via pipes. For example, extracting the second column of a CSV files, sorting the values and displaying only the first ten smallest elements is done with the following commands:

{% highlight bash %}
cat file.csv | cut -d, -f2 | sort | head
{% endhighlight %}

The `cat` command reads the data from disk and writes it to stdout.
The `cut` command reads the data from stdin (which is connected to stdout of
the `cat` process), selects the second column and writes the result to
stdout. The stdin of the `sort` command is connected with stdout of
the `cut` command. The `sort` command reads from stdin, sorts the data
and writes the result to stdout. Finally, the `head` command reads the
result from the `sort` command (via the connection from the sort's stdout
to the head's stdin) and writes only the first ten lines to stdout.

<script type="text/javascript"
    src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>

There are two big advantages when using pipelines for data processing: 
First, the whole process is parallelized with no additional implementation
costs. All processes run at the same time. If data is available at the 
input of one process it can already consume the data while the process
which feeds the input is still working on the next chunk of data. If you
would do this in a single process you often end up with concurrent
programming. Concurrent programming is challenging and error prone.
Nonderterministic behavior for example induced by race conditions which
might happen even only once in $$10^8$$ steps are very difficult to
detect und to debug and could render the results of the data processing
useless. In the worst case you may not even notice a problem and you could 
make the wrong decisions based on incorrect data. Thus, instead of
trying to parallelize many tasks in one big task it is usually a better
idea to split big tasks into smaller tasks and connecting those tasks via
pipes which brings us to the second big advantage. Such an approach is
very flexible. A process can easily be replaced by another process and
smaller and well separated processes help to reduce the complexity which
usually implies less bugs.

If we have successfully established a highly parallelized data processing pipeline we often encounter another problem. At some point we usually need to read some data from the disk in order to process the data. We usually want to read the data via sequential I/O to optimally utilize the data throughput of the disk. However, compared to the throughput of the CPU that can be achieved for many tasks even sequential disk I/O cannot achieve the throughput which is required to optimally utilize the CPU. The disk becomes the bottleneck.

There's sometimes an easy and very effective solution to this problem but 
before describing this solution let me mention a very useful fact. If
the data is read from disk for the first time and if it fits into main
memory there's a good chance that the data is fully cached by the operating
system. The next time we want to read the data from the disk the operating
system can provide the data from the much faster cache in the main memory
instead of accessing the slow disk. So we gain a significant boost in the
throughput if the data is in the cache and chances are good that the CPU
will become the bottleneck for our computation now. ;)

# The trick

So the trick is to read the data once from the stream and simply use
it many times. **Da wir möglicherweise von einem Stream lesen, der mehr
Daten liefert als in den Speicher passen wäre es keine Option die Daten
komplett zu lesen und die Experimente darauf laufen zu lassen. Wir könnten unsere ... so implementieren, dass sie einen Teil des Streams lesen, dann darauf arbeiten, das Ergebnis liefern und den nächsten Teil einlesen, usw.
Dann hätten wir jedoch wieder Implementierungsaufwand mit erhöhter
Code-Komplexität und somit einer erhöhten Fehleranfälligkeit. Das ist
jedoch garnicht notwendig. Denn** Due to the operating systems' page
cache it often comes for free. No additional implementation effort is
required. Let me explain why.

When doing machine learning experiments we typically build a data 
processing pipeline as described above. Some or all tasks in that pipeline 
can be parameterized (e.g. by setting some thresholds or the number of clusters for
some clustering algorithm) and usually we run several experiments in which
we vary the parameters for each task to find an optimal solution.
We can formalize this as follows. Let $$E_\theta:X\to Y$$ be
a function that is parameterized by $$\theta$$ which takes some input
$$x\in X$$ and computes some output $$y\in Y$$. For each particular
$$\theta$$ this function is computed by the pipeline. We run several
experiments for different values of $$\theta$$, i.e. we compute the 
following functions:

$$E_{\theta_1}(x), E_{\theta_2}(x), E_{\theta_3}(x), \dots$$

We could do it sequentially, i.e. we compute $$E_{\theta_1}(x)$$ first.
If the computation of $$E_{\theta_1}(x)$$ has finished we compute
$$E_{\theta_2}(x)$$ and so on. If $$t_E$$ is the time required
to compute the function $$E$$ and $$t_d$$ is the time required to read the
data $$x$$ from the disk this approach
takes $$2(t_d + t_E)$$ time if the data does not fit into the cache. In
general for $$n$$ sequential evaluations of the function $$E$$ the time
$$T(n) = n(t_d + t_E)$$ is required.

If the function $$E$$ is limited by the bandwidth with which the input
$$x$$ can be read from disk we can do better if we evaluate the function $$E$$
for different parameters in parallel, i.e. we compute $$E_{\theta_1}(x)$$,
$$E_{\theta_2}(x)$$ and so on at the same time. If we evaluate the function $$E$$
for $$n$$ different parameters in parallel we get the following result for the
running time:

$$\begin{eqnarray}
	T(n) & = &(t_d + t_{E_{\theta_1}}) + (t_c + t_{E_{\theta_2}}) + (t_c + t_{E_{\theta_3}}) + \dots + (t_c + t_{E_{\theta_n}}) \\
		& = &t_d + (n-1)t_c + nt_E
\end{eqnarray}
$$

where $$t_c$$ is the time required to read the data from the page cache.
Because we can assume that the ratio between the page cache bandwidth and
the disk bandwidth is constant,
i.e. $$t_d = kt_c$$ for some constant $$k$$ (typically $$k>50$$) we get

$$ T(n) = \left(1+\frac{(n-1)}{k}\right)t_d + nt_E$$

Because the evaluation of $$E$$ is bounded by I/O (by definition above) the
last term $$nt_E$$ must be an upper bound for the time required to
compute the function $$E$$ concurrently for $$n$$ different parameters.
Concretely, if 

<!-- 
the last term nt_E ist sogar noch kleiner
Because 
For example, if $$n=8$$ and $$k=50$$ we get $$T(n) = 1.06 t_d + nt_E$$.
Advantage: E must not be modified

To evaluate the function $$E_{\theta_2}, \dots, E_{\theta_n}$$ the data
is already in the page cache...

* sollte man noch erwaehnen, dass es für streaming anwendung hat?
-->
