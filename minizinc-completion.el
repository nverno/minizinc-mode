;;; minizinc-completion --- basic completion for minizinc

;; This is free and unencumbered software released into the public domain.

;; Author: Noah Peart <noah.v.peart@gmail.com>
;; URL: https://github.com/nverno/minizinc-mode
;; Package-Requires: 
;; Created: 21 November 2016

;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;; Code:
(eval-when-compile
  (require 'cl-lib)
  (defvar company-keywords-alist))
(require 'company nil t)

(defvar minizinc-keywords
  '("ann" "annotation" "any" "array" "constraint"
    "diff" "div" "else" "elseif" "endif" "function"
    "include" "in" "intersect" "if" "let"
    "maximize" "minimize" "mod" "output" "of" "op"
    "of" "par" "predicate" "record" "solve" "satisfy"
    "subset" "superset" "symdiff" "test"
    "type" "then" "union" "var" "where" "xor"
    "forall" "bool2int" "int2float" "show"

    "float" "int" "bool" "string" "list" "tuple"

    "abort" "abs" "acosh" "array_intersect"
    "array_union" "array1d" "array2d" "array3d"
    "array4d" "array5d" "array6d" "asin" "assert"
    "atan" "card" "ceil" "concat" "cos"
    "cosh" "dom" "dom_array" "dom_size" "exp" "fix"
    "floor" "index_set" "index_set_1of2"
    "index_set_2of2" "index_set_1of3"
    "int_search"
    "is_fixed" "join" "lb" "lb_array" "length" "ln"
    "log" "log2" "log10" "min" "max" "pow" "product"
    "round" "set2array" "set_search"
    "show_int" "show_float" "sin" "sinh" "sqrt"
    "sum" "tan" "tanh" "trace" "ub" "ub_array"
    ))

(defvar company-keywords-alist ())
(eval-after-load 'company
  '(unless (assoc 'minizinc-mode company-keywords-alist)
     (push `(minizinc-mode ,@minizinc-keywords)
           company-keywords-alist)))

(provide 'minizinc-completion)
;;; minizinc-completion.el ends here
