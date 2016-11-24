(require 'minizinc)
(require 'ert)

(defmacro minizinc--should-indent (from to)
  (declare (indent 1))
  `(with-temp-buffer
     (let ((minizinc-basic-offset 2))
       (minizinc-mode)
       (insert ,from)
       (indent-region (point-min) (point-max))
       (should (string= (buffer-substring-no-properties (point-min)
                                                        (point-max))
                        ,to)))))

(ert-deftest minizinc--indent-let ()
  "indent let clause correctly"
  (minizinc--should-indent
   "
var int: x = let {
var 0..3: x;
var int: y;
constraint y = 10-x;
} in 3*y;"
   "
var int: x = let {
  var 0..3: x;
  var int: y;
  constraint y = 10-x;
} in 3*y;"))

(provide 'minizinc-tests)
