;; init.el file
;; Rishi Dhupar
;; Time-stamp: <09-01-2011 16:54:53 (rkd4127)>

;; This is the first thing to get loaded.

;; Check for Linux and start the server
;(if (string-equal system-type "gnu/linux")
;  (server-start)
;  (message "emacsserver started."))

;; Turn off mouse interface early in startup to avoid momentary display
;; You really don't need these; trust me.
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; loadpath; this will recursively add all dirs in 'elisp-path' to load-path
(setq dotfiles-dir (file-name-directory
                    (or (buffer-file-name) load-file-name)))
(add-to-list 'load-path dotfiles-dir)
(setq package-user-dir (concat dotfiles-dir "elpa"))
(setq custom-file (concat dotfiles-dir "custom.el"))

(defconst elisp-path '("~/.emacs.d")) ;; my elisp directories
(mapcar '(lambda(p)
           (add-to-list 'load-path p)
           (cd p) (normal-top-level-add-subdirs-to-load-path)) elisp-path)

(defconst djcb-config-dir "~/.emacs.d/config/")
(defconst djcb-emacs-dir  "~/.emacs.d")
(defconst djcb-tmp-dir    "~/.emacs.tmp")

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
(require 'registers)
(require 'c)
(require 'eshell)
(require 'lisp)
(require 'perl)
(require 'js)

(load custom-file 'noerror)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; compilation
(setq compilation-window-height 12)
(setq compilation-finish-functions nil) ;; keep it open
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
(add-hook 'after-init-hook 'message-startup-time)
                           
;; init.el ends here