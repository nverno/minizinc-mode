;;; minizinc --- minizinc major mode -*- lexical-binding: t; -*-

;; This is free and unencumbered software released into the public domain.

;; Author: Noah Peart <noah.v.peart@gmail.com>
;; URL: https://github.com/nverno/minizinc-mode
;; Package-Requires: 
;; Created: 24 November 2016

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

;; [![Build Status](https://travis-ci.org/nverno/minizinc-mode.svg?branch=master)](https://travis-ci.org/nverno/minizinc-mode)

;;; Description:

;;  Emacs major mode for minizinc source code.

;;; Code:
(eval-when-compile
  (require 'cl-lib)
  (defmacro re-opt (opts)
    `(concat "\\_<" (regexp-opt ,opts t) "\\_>")))
(require 'cc-mode)
(require 'minizinc-completion)

;; default indentation level
(defvar minizinc-basic-offset 2)

;; -------------------------------------------------------------------
;;; Font-lock
(defvar minizinc-font-lock-keywords
  (eval-when-compile
    (let ((keywords '(
                      "ann" "annotation" "any" "array" "constraint"
                      "diff" "div" "else" "elseif" "endif" "function"
                      "include" "in" "intersect" "if" "let"
                      "maximize" "minimize" "mod" "output" "of" "op"
                      "of" "par" "predicate" "record" "solve" "satisfy"
                      "subset" "superset" "symdiff" "test"
                      "type" "then" "union" "var" "where" "xor"
                      "forall" "bool2int" "int2float" "show"))
          (types '("float" "int" "bool" "string" "list" "tuple"))
          (builtins '(
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
                      )))
      `((,(re-opt keywords) (1 font-lock-keyword-face))
        (,(re-opt types) (1 font-lock-type-face))
        (,(re-opt builtins) (1 font-lock-builtin-face))
        ("^\\(\\sw+\\)\\s-*\\((\\(.+\\))\\)*"
         (1 font-lock-function-name-face)
         (3 font-lock-variable-name-face))))))

;; -------------------------------------------------------------------
;;; Syntax

(defvar minizinc-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?% "<" st)
    (modify-syntax-entry ?\n ">" st)
    (modify-syntax-entry ?_ "w" st)
    (modify-syntax-entry ?\\ "\\" st)
    (modify-syntax-entry ?/ ". 14" st)
    (modify-syntax-entry ?* ". 23" st)
    (mapc (lambda (c) (modify-syntax-entry c "." st)) "+-=<>")
    (modify-syntax-entry ?\' "\"" st)
    st))

;; -------------------------------------------------------------------
;;; Major Mode

(defvar minizinc-mode-map
  (let ((km (make-sparse-keymap)))
    (define-key km (kbd "C-c C-z") 'minizinc-switch-buffer)
    (define-key km (kbd "C-c C-c") 'minizinc-run)
    km))

;;;###autoload
(define-derived-mode minizinc-mode prog-mode "Minizinc"
  "Major mode for editing minizinc code.
Commands:\n
\\{minizinc-mode-map}"
  (c-initialize-cc-mode)
  (c-common-init 'c-mode)
  (setq-local c-basic-offset minizinc-basic-offset)
  (c-set-offset 'knr-argdecl-intro 0)
  (setq-local comment-start "% ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "\\(?:%+\\|/\\*+\\)")
  (setq-local comment-end-skip "[ \t]*\\(\n\\|\\*+/\\)")
  (setq-local font-lock-defaults
              '(minizinc-font-lock-keywords nil nil nil))

  (setq-local paragraph-separate (concat "%\\|$\\|" page-delimiter))
  (setq-local paragraph-ignore-fill-prefix  t)
  (setq-local imenu-generic-expression '((nil "^\\sw+" 0)))

  ;; hungry stuff
  ;; (c-toggle-auto-hungry-state -1)
  ;; (c-toggle-auto-newline -1)
  ;; (c-toggle-hungry-state -1)
  )

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.mzn$" . minizinc-mode))

;; -------------------------------------------------------------------
;;; Run
(defvar minizinc-program "minizinc")
(defvar minizinc-buffer "minizinc")
(defvar minizinc-process-env
  `(,(concat "MZN_STDLIB_DIR="
             (expand-file-name
              "minizinc-2.1.0/share/minizinc/" (getenv "DEVEL")))))
(defvar minizinc--last-buffer)

;; gather command line switches
(defvar minizinc--switches nil)
(defun minizinc--switches ()
  (or minizinc--switches
      (with-temp-buffer
        (call-process "minizinc" nil (current-buffer) nil "--help")
        (goto-char (point-min))
        (let (res)
          (while (re-search-forward "^\\s-*\\(-[-a-zA-Z]+\\)" nil t)
            (push (match-string 1) res)
            (if (re-search-forward "\\(-[a-zA-Z-]+\\)"
                                   (line-end-position) t)
                (push (match-string 1) res)))
          (setq minizinc--switches (nreverse res))))))

;; completion at point for command switches
(defun minizinc-switch-completion ()
  (let ((bnds (bounds-of-thing-at-point 'symbol)))
    (when bnds
      (if (eq ?- (char-after (car bnds)))
          (list (car bnds) (cdr bnds) (minizinc--switches))))))

;; read from minibuffer with completion
(defun minizinc-read-command (prompt &optional initial-contents)
  (let ((minibuffer-completing-symbol nil))
    (minibuffer-with-setup-hook
        (lambda ()
          (add-hook 'completion-at-point-functions
                    'minizinc-switch-completion nil 'local))
      (read-from-minibuffer prompt initial-contents
                            read-expression-map nil
                            'read-expression-history))))

;;;###autoload
(defun minizinc-run (&optional args file)
  "Run minizinc on FILE, prompt for arguments with prefix."
  (interactive)
  (let* ((process-environment
          (append minizinc-process-env process-environment))
         (args (or args
                   (and current-prefix-arg
                        (split-string-and-unquote
                         (minizinc-read-command "Minizinc args: ")))))
         (file (or file buffer-file-name))
         (compile-command (format "%s %s %s"
                                  minizinc-program
                                  (mapconcat 'identity args " ")
                                  file))
         (compilation-read-command nil))
    (call-interactively 'compile)))

;; switch b/w source code and output buffers
(defun minizinc-switch-buffer ()
  (interactive)
  (if (and (eq major-mode 'compilation-mode)
           minizinc--last-buffer)
      (pop-to-buffer minizinc--last-buffer)
    (let ((buff (get-buffer minizinc-buffer)))
      (when (buffer-live-p buff)
        (setq minizinc--last-buffer (current-buffer))
        (pop-to-buffer buff)))))

;; -------------------------------------------------------------------
;;; Compilation
(require 'compile)
(cl-pushnew 'minizinc-1 compilation-error-regexp-alist)
(add-to-list 'compilation-error-regexp-alist-alist
             '(minizinc-1 "^\\s-*\\([^ \t\n]+\\.mzn\\):\\([0-9]+\\)"
                          1 2))

;; -------------------------------------------------------------------
;;; Inf
;; wtf?
(defvar inf-minizinc-mode-map
  (let ((km (make-sparse-keymap)))
    (define-key km (kbd "C-c C-z") 'minizinc-switch-buffer)
    km))

(defvar inf-minizinc-mode-syntax-table minizinc-mode-syntax-table)

(define-derived-mode inf-minizinc-mode comint-mode "*Minizinc*"
  "Inferior minizinc interaction.
Commands:\n
\\{inf-minizinc-mode-map}"
  (setq mode-line-process '(":%s"))
  (setq-local comint-prompt-regexp "^| [ ?][- ] *"))

(provide 'minizinc)
;;; minizinc.el ends here
