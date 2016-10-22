---
layout: post
title: Computing the determinant in Python in one (long) line of code
---

<script type="text/javascript"
    src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>

Computing the determinant is one of the fundamental operations in linear algebra with many practical applications. The determinant can be used to compute the area of a parallelogram or to check if there exists a solution for a system of linear equations. The determinant is defined only for square matrices and can be computed recursively.

If $$\alpha_{ij}$$ is the element of the matrix A at row i and column j with $$i,j \geq 1$$  then the determinant can be computed as follows:

$$ \det(A) = \alpha_{11} \det \tilde{A}_{11} ... - \alpha_{21} \det \tilde{A}_{21} ... + \alpha_{31} \det \tilde{A}_{31} - ... $$

where $$\tilde{A}_{ij}$$ is the matrix A with row i and column j being removed. The recursion terminates if the matrix A is a 1x1 matrix because the determinant of a 1x1 matrix simply is $$\alpha_{11}$$.

Translating this into Python code we finally get:

{% highlight cpp %}
import numpy as np

def det(A):
    return sum([(-1)**i * A[i, 0] * det(np.delete(np.delete(A, 0, 1), i, 0)) for i in range(A.shape[0])]) if A.shape != (1, 1) else A[0, 0]

m = np.array([[1, 4], [2, 1]])
print det(m)
{% endhighlight %}

**Note**: this is not a very efficient way to compute the determinant of a matrix because this approach takes O(n!) steps which is very inefficient even for rather small matrices. If you really need an efficient way which returns the solution in a finite time even for big matrices you should use `numpy.linalg.det` from numpy instead.
