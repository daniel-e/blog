---
layout: post
title: CPU Throttling apparently enabled
---

When compiling [ATLAS](http://math-atlas.sourceforge.net/) (Automatically Tuned Linear Algebra Software) on modern CPUs it may happen that you get the following error message:

<pre>CPU Throttling apparently enabled!
It appears you have cpu throttling enabled, which makes timings
unreliable and an ATLAS install nonsensical.  Aborting.
</pre>

This is because today most operating systems  turn CPUs in throttling for power management. Unfortunately, with throttling being enabled ATLAS cannot be compiled because this makes timings random. Thus, before ATLAS can be compiled CPU throttling must be disabled. On Ubuntu this is quite easy.

First, let's see what governors are configured for each CPU. The following command loops over all CPUs and reads the governor that is configured for each CPU:

<pre><code class="bash">for i in $(seq 0 $((`nproc`-1))); do cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor; done
</code></pre>

The output should be similar to the following:

<pre>ondemand
ondemand
ondemand
ondemand
ondemand
ondemand
ondemand
ondemand
</pre>

On Ubuntu those values should be "performance". To set them to "performance" execute the following command:

<pre><code class="bash">for i in $(seq 0 $((`nproc`-1))); do echo $i; cpufreq-set -c $i -g performance; done
</code></pre>
