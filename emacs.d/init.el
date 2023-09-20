;; init.el file
;; Rishi Dhupar
;; Time-stamp: <09-01-2011 16:54:53 (rkd4127)>

;; This is the first thing to get loaded.

;; Check for Linux and start the server
(if (string-equal system-type "gnu/linux")
  (server-start)
  (message "emacsserver started."))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; loadpath
(defconst emacs-dir     "~/.emacs.d")
(defconst emacs-tmp-dir "~/.emacs.tmp")
(add-to-list 'load-path emacs-dir)
(add-to-list 'load-path (concat emacs-dir "/site-lisp"))
(add-to-list 'load-path (concat emacs-dir "/site-lisp/themes"))
(setq custom-file (concat emacs-dir "custom.el"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; These should be loaded on startup rather than autoloaded on demand
;; since they are likely to be used in every session

(require 'cl)
(require 'saveplace)
(require 'ffap)
(require 'uniquify)
(require 'ansi-color)
(require 'recentf)

;; Load up starter kit customizations
(require 'customizations)
(require 'encoding)
(require 'defuns)
(require 'bindings)
(require 'misc)
(require 'init-color-theme)
(require 'registers)
(require 'c)
(require 'eshell)
(require 'lisp)
(require 'perl)
(require 'js)
(require 'doxymacs)

(load custom-file 'noerror)

(add-hook 'after-init-hook 'message-startup-time)
