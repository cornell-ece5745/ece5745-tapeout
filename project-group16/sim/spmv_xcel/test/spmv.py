import random
random.seed(0xdeadbeef)

def spmv( num_rows, rows, cols, vals, v ):
  dest = []
  for i in range(num_rows): 
    dest.append(0)
    sum = 0
    for j in range(rows[i], rows[i+1]):
      sum += vals[j] * v[cols[j]]
      # print(j)
      # sum += vals[j]
    dest[i] = sum
  return dest

if __name__ == "__main__":
  # num_rows = 4
  # rows       = [ 0, 2, 2, 5, 7 ]
  # cols       = [ 0, 2, 0, 2, 3, 1, 3 ]
  # v     = [ 1, 4, 6, 12 ]
  # vals       = [ 1, 2, 1, 2, 3, 1, 2 ]
  num_rows = 32
  rows       = [ 0, 0, 0, 1, 1, 2, 2, 3, 4, 4, 5, 6, 7, 7, 8, 8, 9, 9, 9, 10, 12, 13, 13, 14, 15, 15, 16, 16, 17, 18, 19, 19, 19 ]
  cols       = [ 2, 6, 9, 21, 18, 15, 15, 10, 6, 21, 5, 1, 27, 26, 31, 27, 11, 3, 2, 17 ]
  vals       = [ 25, 41, 27, 2, 61, 95, 41, 61, 35, 32, 46, 72, 50, 9, 51, 23, 93, 24, 74, 66 ]
  vector     = [ 700, 234, 640, 523, 164, 794, 398, 229, 72, 372, 792, 14, 772, 771, 77, 853, 816, 981, 439, 372, 303, 797, 34, 141, 547, 441, 596, 778, 439, 672, 824, 114 ]

  v = [random.randint(0,0xffff) for i in range(128)]

  # vals_rand_128x128_large = [random.randint(0,0x7fffffff) for i in range(num_nnz_rand_128)]
  # vector_rand_128x128_large = [random.randint(0,0x7fffffff) for i in range(128)]

  print(spmv(num_rows, rows, cols, vals, v))