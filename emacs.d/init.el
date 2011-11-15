;; init.el file
;; Rishi Dhupar
;; Time-stamp: <11-09-2011 21:29:00 (Rishi)>

;; This is the first thing to get loaded.

;; List of sources
;; Emacs Starter Kit
;; http://www.elliotglaysher.org/emacs/

;; Check for Linux and start the server
;(if (string-equal system-type "gnu/linux")
;  (server-start)
;  (message "emacsserver started.")


;; -----------------------------------------------------------------------
;; Load paths
;; -----------------------------------------------------------------------
(defconst emacs-dir     "~/.emacs.d")
(defconst emacs-tmp-dir "~/.emacs.tmp")
(add-to-list 'load-path emacs-dir)
(add-to-list 'load-path (concat emacs-dir "/site-lisp"))
(add-to-list 'load-path (concat emacs-dir "/site-lisp/themes"))
(setq byte-compile-warnings nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; These should be loaded on startup rather than autoloaded on demand
;; since they are likely to be used in every session

(require 'cl)
(require 'saveplace)
(require 'ffap)
(require 'uniquify)
(require 'ansi-color)
(require 'recentf)

;; Load up personal customizations
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
(require 'init-ido)
(require 'init-cmake)
(require 'init-ibuffer)
(require 'init-hippie-expand)

(add-hook 'after-init-hook 'message-startup-time)