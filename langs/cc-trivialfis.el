;;; cc-trivialfis --- Summary
;;; Commentary:

;;; Code:
(require 'misc-trivialfis)
(require 'cc-mode)
;; (require 'flycheck)			; For language standard

;; (use-package company-clang
;;   :commands (trivialfis/company-clang))
;; (use-package company-c-headers)


;; (defun trivialfis/company-clang ()
;;   "Company clang configuration."
;;   (require 'company-clang)
;;   (require 'company-c-headers)
;;   (setq company-backends (delete 'company-semantic company-backends))
;;   (setq company-clang-arguments '("-std=c++14"))
;;   (require 'company-c-headers)
;;   (add-to-list 'company-c-headers-path-system "/usr/include/c++/6.3.1/")  ; Add c++ headers to company
;;   (add-to-list 'company-backends 'company-c-headers))

(use-package programming-trivialfis
  :commands trivialfis/semantic
  :config (message "Semantic loaded"))

(use-package cc-pkg-trivialfis
  :commands mumbo-find-library
  :config (message "cc-pkg loaded"))

(use-package rtags
  :commands rtags-start-process-unless-running
  :config (progn
	    (message "Rtags loaded")
	    (use-package company-rtags)))

(defun trivialfis/rtags ()
  "Rtags configuration.
Used only for nevigation."
  (interactive)
  (rtags-start-process-unless-running)
  ;; (setq rtags-autostart-diagnostics t)
  ;; (rtags-diagnostics)
  ;; (setq rtags-completions-enabled 1)
  ;; (add-to-list 'company-backends 'company-rtags)
  (setq rtags-display-result-backend 'helm)
  (trivialfis/local-set-keys
   '(
     ("M-."     .  rtags-find-symbol-at-point)
     ("M-,"     .  rtags-find-references-at-point)
     ("C-c r r" .  rtags-rename-symbolrtags-next-match)
     ;; ("C-c r n" .  rtags-next-match)
     ;; ("C-c r p" .  rtags-previous-match)
     ))
  (add-hook 'kill-emacs-hook 'rtags-quit-rdm))

(defun trivialfis/irony ()
  "Irony mode configuration."
  (add-hook 'irony-mode-hook 'irony-eldoc)
  (add-to-list 'company-backends 'company-irony)
  (add-to-list 'company-backends 'company-irony-c-headers)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
  (add-hook 'flycheck-mode-hook 'flycheck-irony-setup)
  (when (or (eq major-mode 'c-mode)	; Prevent from being loaded by c derived mode
  	    (eq major-mode 'c++-mode))
    (irony-mode 1)))


(defun trivialfis/cc-base-srefactor ()
  "Configuration for refactor."
  (trivialfis/local-set-keys
   '(
     ("M-RET"   .  srefactor-refactor-at-point)
     ("C-c t"   .  senator-fold-tag-toggle)
     ("C-."     .  semantic-symref)
     ("M-."     .  semantic-ia-fast-jump)
     ("C-,"     .  semantic-mrub-switch-tags)))
  (eval-after-load 'helm-trivialfis
    (local-set-key (kbd "C-h ,") 'helm-semantic-or-imenu)))

(defun trivialfis/cc-base ()
  "Common configuration for c and c++ mode."
  ;; Company mode
  (setf company-backends '())
  (add-to-list 'company-backends 'company-keywords)
  (add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
  (trivialfis/rtags)
  (trivialfis/irony)
  ;; (trivialfis/cc-base-srefactor)

  (trivialfis/local-set-keys
   '(
     ;; Disaster
     ("C-c d a" . disaster)
     ;; Clang formating
     ("C-c f b" . clang-format-buffer)
     ("C-c f r" . clang-format-region)
     ))
  (flycheck-mode 1))


(defun trivialfis/c++ ()
  "Custom C++ mode."
  (setf irony-additional-clang-options '("-std=c++14" "-cc1"))
  ;; (setf flycheck-clang-language-standard "c++14")
  ;; (trivialfis/semantic 'c++-mode)
  (trivialfis/cc-base))

(defun trivialfis/c ()
  "Custom c mode."
  ;; (trivialfis/semantic 'c-mode)
  (trivialfis/cc-base))

(provide 'c++-trivialfis)
;;; cc-trivialfis.el ends here
