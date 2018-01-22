;;; text-trivialfis --- Configuration for normal text file -*- lexical-binding: t -*-
;;;
;;; Copyright © 2016-2018 Fis Trivial <ybbs.daans@hotmail.com>
;;;
;;; This file is part of Foci-Emacs.
;;;
;;; Foci-Emacs is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; Foci-Emacs is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with Foci-Emacs.  If not, see <http://www.gnu.org/licenses/>.
;;;
;;; Commentary:
;;; Code:

(require 'company)
(eval-when-compile			; Get rid of the free reference
  (defvar flyspell-mode-map))

(defun trivialfis/_text ()
  "Configuration for normal text."
  (flyspell-mode 1)
  ;; (define-key flyspell-mode-map (kbd "C-;") 'flyspell-correct-previous-word-generic)
  (define-key flyspell-mode-map (kbd "C-;") 'flyspell-correct-at-point)
  (add-to-list 'company-backends 'company-ispell))

(defun trivialfis/text ()
  "Guard for trivialfis/_text."
  (when (or (eq major-mode 'text-mode)
	    (eq major-mode 'org-mode)
	    (eq major-mode 'markdown-mode))
    (trivialfis/_text)))

(provide 'text-trivialfis)
;;; text-trivialfis.el ends here
