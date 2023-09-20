;; init.el file
;; Rishi Dhupar
;; Time-stamp: <01-31-2012 19:39:33 (ubuntu)>
;; This is the first thing to get loaded.

;; List of sources
;; Emacs Starter Kit
;; http://www.elliotglaysher.org/emacs/
;; https://github.com/magnars/.emacs.d/

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

;; Keep emacs Custom-settings in separate file
(setq custom-file (expand-file-name "custom.el" emacs-dir))
(load custom-file)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; These should be loaded on startup rather than autoloaded on demand
;; since they are likely to be used in every session

;; Lets start with a smattering of sanity
(require 'sane-defaults)

(require 'cl)
(require 'saveplace)
(require 'ffap)
(require 'ansi-color)

;; Load up personal customizations
(require 'customizations)
(require 'encoding)
(require 'defuns)
(require 'bindings)
(require 'misc)
(require 'init-color-theme)
(require 'registers)
(require 'init-c)
(require 'init-python)
(require 'eshell)
(require 'init-perl)
(require 'init-js)
(require 'init-ido)
(require 'init-cmake)
(require 'init-ibuffer)
(require 'init-hippie-expand)

(add-hook 'after-init-hook 'message-startup-time)
