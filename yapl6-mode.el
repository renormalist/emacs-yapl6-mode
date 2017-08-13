;;; yapl6-mode.el --- Yet Another Perl 6 major mode

;;; Copyright 2017 Steffen Schwigon

;;; Author: Steffen Schwigon <ss5@renormalist.net>
;;;
;;; Keywords: perl6 syntax highlighting
;;; X-URL: https://github.com/renormalist/emacs-yapl6-mode

;;; This program is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU General Public License as
;;; published by the Free Software Foundation; version 2.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
;;; 02110-1301, USA.

;;; Requirements:

;;; - Low expectations and some desire of pain :-) as this is highly
;;;   experimental and basically just the shy try of a feasibility
;;;   study.
;;;
;;; - You need a working "perl6" executable in your $PATH and the
;;;   Perl6 class Perl6::Parser installed, see
;;;     * https://github.com/drforr/perl6-Perl6-Parser

;;; Usage:

;;; Add the following into your ~/.emacs:
;;;
;;;    (require 'yapl6-mode)
;;;    (setq auto-mode-alist (append
;;;                           (list '("\\.p6$"  . yapl6-mode)
;;;                                 '("\\.pl6$" . yapl6-mode)
;;;                                 '("\\.pm6$" . yapl6-mode))
;;;                           auto-mode-alist))

(defgroup yapl6-mode nil
  "Mode for editing Perl6 files"
  :group 'faces)

(defgroup yapl6-faces nil
  "Faces for highlighting Perl6 constructs"
  :prefix "yapl6-"
  :group 'yapl6-mode)

(defvar yapl6-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c h") 'yapl6-highlight)
    map)
  "Keymap for YAPL6 major mode.")

;; (defface yapl6-face-bareword
;;   '((((min-colors 88) (background dark))
;;      (:background "yellow1" :foreground "black"))
;;     (((background dark)) (:background "yellow" :foreground "black"))
;;     (((min-colors 88)) (:background "red"))
;;     (t (:background "red")))
;;   "yapl6 face for bareword."
;;   :group 'yapl6-faces)
(defface yapl6-face-bareword          '((t (:foreground "red1")) ) "yapl6 bareword" :group 'yapl6-faces)
(defface yapl6-face-comment           '((t (:foreground "red3"))) "yapl6 comment" :group 'yapl6-faces)
(defface yapl6-face-colon-bareword    '((t (:foreground "gold1"))) "yapl6 colon-bareword" :group 'yapl6-faces)
(defface yapl6-face-op-postcircumfix  '((t (:foreground "gold3"))) "yapl6 op-postcircumfix" :group 'yapl6-faces)
(defface yapl6-face-op-circumfix      '((t (:foreground "yellow1"))) "yapl6 op-circumfix" :group 'yapl6-faces)
(defface yapl6-face-op-postfix        '((t (:foreground "yellow3"))) "yapl6 op-postfix" :group 'yapl6-faces)
(defface yapl6-face-op-prefix         '((t (:foreground "orange1"))) "yapl6 op-prefix" :group 'yapl6-faces)
(defface yapl6-face-op-infix          '((t (:foreground "orange3"))) "yapl6 op-infix" :group 'yapl6-faces)
(defface yapl6-face-op-hyper          '((t (:foreground "green1"))) "yapl6 op-hyper" :group 'yapl6-faces)
(defface yapl6-face-op                '((t (:foreground "green2"))) "yapl6 op" :group 'yapl6-faces)
(defface yapl6-face-num-decimal       '((t (:foreground "green3"))) "yapl6 num-decimal" :group 'yapl6-faces)
(defface yapl6-face-num-octal         '((t (:foreground "green4"))) "yapl6 num-octal" :group 'yapl6-faces)
(defface yapl6-face-num-radix         '((t (:foreground "blue1"))) "yapl6 num-radix" :group 'yapl6-faces)
(defface yapl6-face-num-binary        '((t (:foreground "blue2"))) "yapl6 num-binary" :group 'yapl6-faces)
(defface yapl6-face-num-imaginary     '((t (:foreground "blue3"))) "yapl6 num-imaginary" :group 'yapl6-faces)
(defface yapl6-face-num-float         '((t (:foreground "blue4"))) "yapl6 num-float" :group 'yapl6-faces)
(defface yapl6-face-num-decimal       '((t (:foreground "orange1"))) "yapl6 num-decimal" :group 'yapl6-faces)
(defface yapl6-face-num-hexdecimal    '((t (:foreground "orange2"))) "yapl6 num-hexdecimal" :group 'yapl6-faces)
(defface yapl6-face-num               '((t (:foreground "orange3"))) "yapl6 num" :group 'yapl6-faces)
(defface yapl6-face-callable          '((t (:foreground "orange4"))) "yapl6 callable" :group 'yapl6-faces)
(defface yapl6-face-hash              '((t (:foreground "grey10"))) "yapl6 hash" :group 'yapl6-faces)
(defface yapl6-face-array             '((t (:foreground "grey20"))) "yapl6 array" :group 'yapl6-faces)
(defface yapl6-face-var-scalar        '((t (:foreground "grey30"))) "yapl6 var-scalar" :group 'yapl6-faces)
(defface yapl6-face-var               '((t (:foreground "grey40"))) "yapl6 var" :group 'yapl6-faces)
(defface yapl6-face-str-interpolation '((t (:foreground "grey50"))) "yapl6 str-interpolation" :group 'yapl6-faces)
(defface yapl6-face-str-escaping      '((t (:foreground "grey60"))) "yapl6 str-escaping" :group 'yapl6-faces)
(defface yapl6-face-str               '((t (:foreground "grey70"))) "yapl6 str" :group 'yapl6-faces)
(defface yapl6-face-regex             '((t (:foreground "grey80"))) "yapl6 regex" :group 'yapl6-faces)

(defun yapl6-mode ()
  "Major mode for highlighting Perl6 files."
  (interactive)
  (kill-all-local-variables)
  (use-local-map yapl6-mode-map)
  (setq major-mode 'yapl6-mode)
  (setq mode-name "P6")
)

(defun yapl6-highlight ()
  "Perl6 highlighting"
  (interactive)
  (progn
    (remove-overlays)
    (overlay-put (make-overlay 1 21)    'face 'yapl6-face-comment)
    (overlay-put (make-overlay 23 25)   'face 'yapl6-face-bareword)
    (overlay-put (make-overlay 26 27)   'face 'yapl6-face-op-prefix)
    (overlay-put (make-overlay 27 33)   'face 'yapl6-face-array)
    (overlay-put (make-overlay 40 43)   'face 'yapl6-face-bareword)
    (overlay-put (make-overlay 44 70)   'face 'yapl6-face-str-interpolation)
    (overlay-put (make-overlay 76 80)   'face 'yapl6-face-bareword)
    (overlay-put (make-overlay 85 88)   'face 'yapl6-face-bareword)
    (overlay-put (make-overlay 91 94)   'face 'yapl6-face-bareword)
    (overlay-put (make-overlay 95 98)   'face 'yapl6-face-bareword)
    (overlay-put (make-overlay 107 110) 'face 'yapl6-face-bareword)
    (overlay-put (make-overlay 111 129) 'face 'yapl6-face-str-interpolation)
  )
)

(provide 'yapl6-mode)
