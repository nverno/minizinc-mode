% RUNS ON mzn20_fd
% RUNS ON mzn20_fd_linear
% Example battleships problem for bs.mzn.
%
include "battleships.model.mzn";

n = 10;

a = array2d(ROW, COL,
            [| 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
             | 0, _, _, _, _, _, _, _, _, _, _, 0
             | 0, _, _, _, _, _, _, _, 0, _, 0, 0
             | 0, 0, _, _, _, _, _, _, _, 0, _, 0
             | 0, _, _, _, _, _, _, _, _, _, _, 0
             | 0, _, _, _, _, _, _, _, _, _, _, 0
             | 0, _, _, _, _, _, _, _, _, _, _, 0
             | 0, _, _, _, _, _, _, _, _, _, _, 0
             | 0, _, _, _, 0, _, _, _, _, _, _, 0
             | 0, _, _, _, _, _, _, _, _, _, _, 0
             | 0, _, _, _, _, _, _, _, _, _, _, 0
             | 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
             |]
            );

constraint a[2, 9] > 1;

row_sums = [2, 1, 5, 0, 0, 0, 1, 6, 1, 4];

col_sums = [1, 4, 1, 2, 3, 1, 3, 0, 4, 1];

n_classes = 4;

class_sizes = [4, 3, 2, 1];

