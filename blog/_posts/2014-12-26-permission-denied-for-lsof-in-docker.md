---
layout: post
title: Permission denied for lsof in Docker
---

On my host system I have installed Linux Mint 17 and on that host I'm running Docker with Ubuntu 14.10. Recently I wanted to call lsof in a Docker container and I got the following permission denied error:

<pre><code class="bash">root@ada77fe6ef60:/tmp $ lsof -p 751
COMMAND   PID USER   FD      TYPE DEVICE SIZE/OFF NODE NAME
octave-cl 751 root  cwd   unknown                      /proc/751/cwd (readlink: Permission denied)
octave-cl 751 root  rtd   unknown                      /proc/751/root (readlink: Permission denied)
octave-cl 751 root  txt   unknown                      /proc/751/exe (readlink: Permission denied)
octave-cl 751 root    0   unknown                      /proc/751/fd/0 (readlink: Permission denied)
octave-cl 751 root    1   unknown                      /proc/751/fd/1 (readlink: Permission denied)
octave-cl 751 root    2   unknown                      /proc/751/fd/2 (readlink: Permission denied)
</code></pre>

I solved this problem simply by setting docker into complain mode on the host with the following command:

<pre><code class="bash">sudo aa-complain /etc/apparmor.d/docker
</code></pre>
