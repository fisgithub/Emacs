;;; misc-trivialfis.el --- Misc functions.
;;;
;;; Copyright © 2016-2021 Fis Trivial <ybbs.daans@hotmail.com>
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

(defun trivialfis/goto-pos ()
  "Go to position.
If you want to go to the middle, enter 50. 50 means 50% of the buffer."
  (interactive)
  (let ((inhibit-message t)
	(current (line-number-at-pos (point)))
	(pos (string-to-number (read-from-minibuffer "Pos: ")))
	(max-line (save-excursion
		    (progn
		      (goto-char (buffer-end 1))
		      (line-number-at-pos (point))))))
    (catch 'wrong-pos
      (if (or (> pos 100)
	      (< pos 0))
	  (throw 'wrong-pos "Wrong position")
	(forward-line (- (truncate (* (/ (float pos) 100)
				      max-line))
			 current))))))

(defun trivialfis/pop-frame ()
  "Pop up a new frame and close the current window."
  (interactive)
  (if (eq (selected-window) (next-window))
      (make-frame)
    (progn
      (make-frame)
      (delete-window))))

(defun trivialfis/close-frame ()
  "Close frame or kill Emacs."
  (interactive)
  (if (eq (next-frame) (selected-frame))
      (save-buffers-kill-terminal)
    (delete-frame)))

(defun trivialfis/local-set-keys (key-commands)
  "Set multiple local bindings with KEY-COMMANDS list."
  (let ((local-map (current-local-map)))
    (dolist (kc key-commands)
      (define-key local-map
	(kbd (car kc))
	(cdr kc)))))

(defun until-success (args)
  "Run until one of ARGS succeed.
ARGS: A quoted list containing all functions to be tried."
  (if (equal args 'nil)
      'nil
    (if (not (apply (list (car args))))
  	(until-success (cdr args))
      't)))

(defun elpy-nav-normalize-region ()
  "If the first or last line are not fully selected, select them completely."
  (let ((beg (region-beginning))
        (end (region-end)))
    (goto-char beg)
    (beginning-of-line)
    (push-mark (point) nil t)
    (goto-char end)
    (when (not (= (point) (line-beginning-position)))
      (end-of-line))))

(defun python-indent-shift-right (start end &optional count)
  "Shift lines contained in region START END by COUNT columns to the right.
COUNT defaults to `python-indent-offset'.  If region isn't
active, the current line is shifted.  The shifted region includes
the lines in which START and END lie."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end) current-prefix-arg)
     (list (line-beginning-position) (line-end-position) current-prefix-arg)))
  (let ((deactivate-mark nil))
    (setq count (if count (prefix-numeric-value count)
                  4))
    (indent-rigidly start end count)))

(defun python-indent-shift-left (start end &optional count)
  "Shift lines contained in region START END by COUNT columns to the left.
COUNT defaults to `python-indent-offset'.  If region isn't
active, the current line is shifted.  The shifted region includes
the lines in which START and END lie.  An error is signaled if
any lines in the region are indented less than COUNT columns."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end) current-prefix-arg)
     (list (line-beginning-position) (line-end-position) current-prefix-arg)))
  (if count
      (setq count (prefix-numeric-value count))
    (setq count 4))
  (when (> count 0)
    (let ((deactivate-mark nil))
      (save-excursion
        (goto-char start)
        (while (< (point) end)
          (if (and (< (current-indentation) count)
                   (not (looking-at "[ \t]*$")))
              (user-error "Can't shift all lines enough"))
          (forward-line))
        (indent-rigidly start end (- count))))))

;; adoped from `elpy'.
(defun trivialfis/nav-indent-shift-right (&optional _count)
  "Shift current line by COUNT columns to the right.

COUNT defaults to `python-indent-offset'.
If region is active, normalize the region and shift."
  (interactive)
  (if (use-region-p)
      (progn
        (elpy-nav-normalize-region)
        (python-indent-shift-right (region-beginning) (region-end) current-prefix-arg))
    (python-indent-shift-right (line-beginning-position) (line-end-position) current-prefix-arg)))

(defun trivialfis/nav-indent-shift-left (&optional _count)
  "Shift current line by COUNT columns to the left.

COUNT defaults to `python-indent-offset'.
If region is active, normalize the region and shift."
  (interactive)
  (if (use-region-p)
      (progn
        (elpy-nav-normalize-region)
        (python-indent-shift-left (region-beginning) (region-end) current-prefix-arg))
    (python-indent-shift-left (line-beginning-position) (line-end-position) current-prefix-arg)))

(defun trivialfis/screenshot ()
  "Save a screenshot of the current frame as an SVG image.
Saves to a temp file and puts the filename in the kill ring."
  (interactive)
  (let ((filename (make-temp-file "Emacs-screenshot-" nil ".svg"))
        (data (x-export-frames nil 'svg)))
    (with-temp-file filename
      (insert data))
    (kill-new filename)
    (message filename)))

(defun vterm-send-M-\\ ()
  (interactive)
  (vterm-send-key "\\" nil t nil))


(defun trivialfis/new-term (&optional window)
  "Split window and open a new term, optional WINDOW."
  (interactive)
  (let ((window (or (selected-window) window))
	(split-wh-threshold 4))
    (if (< (* (window-height) split-wh-threshold) (window-width))
	(with-selected-window window
	  (split-window-horizontally))
      (with-selected-window window
	(split-window-vertically))))
  (select-window (next-window))
  (trivialfis/vterm))

(defun trivialfis/vterm ()
  "Open vterm."
  (interactive)
  ;; Add this to gnome shortcut key `'emacs --eval "(trivialfis/vterm)"'
  (require 'nix-elpa)
  (load-nix-elpa-packages)
  (require 'vterm)
  (setq vterm-kill-buffer-on-exit t
	vterm-max-scrollback 100000)
  (define-key vterm-mode-map (kbd "M-p") 'vterm-send-C-p)
  (define-key vterm-mode-map (kbd "M-n") 'vterm-send-C-n)
  (define-key vterm-mode-map (kbd "M-\\") 'vterm-send-M-\\)
  (set-face-foreground 'vterm-color-blue "#CCFFCC")
  (set-face-foreground 'vterm-color-magenta "#cc99ff")
  (vterm)
  (define-key vterm-mode-map (kbd "C-S-n") 'trivialfis/new-term)
  ;; Don't ask on exist
  (set-process-query-on-exit-flag (get-buffer-process (current-buffer)) nil)
  ;; FIXME: Enable per-buffer highlight
  (global-hl-line-mode -1))

(defun trivialfis/remove-blank-lines ()
  (interactive)
  (flush-lines "^$"))

(require 'windmove)

;; Utilities from https://www.emacswiki.org/emacs/buffer-move.el
(defun buf-move-left ()
  "Swap the current buffer and the buffer on the left of the split.
If there is no split, ie now window on the left of the current
one, an error is signaled."
  (let* ((other-win (windmove-find-other-window 'left))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

(defun buf-move-right ()
  "Swap the current buffer and the buffer on the right of the split.
If there is no split, ie now window on the right of the current
one, an error is signaled."
  (let* ((other-win (windmove-find-other-window 'right))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No right split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

(defun trivialfis/swap-windows-horizontal()
  "Swap windows."
  (interactive)
  (if (null (windmove-find-other-window 'right))
      (buf-move-left)
    (buf-move-right)))

;; Other functions that might be useful
;; set-buffer-file-coding-system utf-8-unix

(provide 'misc-trivialfis)
;;; misc-trivialfis.el ends here
