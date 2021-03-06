# distutils: language = c++
import numpy as np
cimport numpy as np
cimport cython
from libcpp cimport bool
from libcpp.string cimport string

cdef extern from "tsne.h":
    cdef cppclass TSNE:
        TSNE()
        void run(double* X, string dataName, int N, int D, double* Y, int no_dims, double perplexity, double theta, int rand_seed, bool skip_random_init)

cdef class BHTSNE:
    cdef TSNE* tsne

    def __cinit__(self):
        self.tsne = new TSNE()

    def __dealloc__(self):
        del self.tsne

    @cython.boundscheck(False)
    @cython.wraparound(False)
    def run(self, X, data_name, no_rows, no_cols, no_dims, perplexity, theta, rand_seed, seed_positions, skip_random_init):
        cdef np.ndarray[np.float64_t, ndim=2, mode='c'] _X = np.ascontiguousarray(X)
        cdef np.ndarray[np.float64_t, ndim=2, mode='c'] Y = np.zeros((no_rows, no_dims), dtype=np.float64)
        if skip_random_init:
          Y = seed_positions
        self.tsne.run(&_X[0,0], str.encode(data_name), no_rows, no_cols, &Y[0,0], no_dims, perplexity, theta, rand_seed, skip_random_init)
        return Y
