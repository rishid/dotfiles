;; Allow pasting selection outside of Emacs
(setq x-select-enable-clipboard t)

;; Auto refresh buffers
;(global-auto-revert-mode 1)

;; Also auto refresh dired
(setq global-auto-revert-non-file-buffers t)

;; Show keystrokes in progress
(setq echo-keystrokes 0.1)

;; No splash screen please ... jeez
(setq inhibit-startup-message t)

;; Move files to trash when deleting
(setq delete-by-moving-to-trash t)

;; Real emacs knights don't use shift to mark things
(setq shift-select-mode nil)

;; Transparently open compressed files
(auto-compression-mode t)

;; Enable syntax highlighting for older Emacsen that have it off
(global-font-lock-mode t)

;; Answering just 'y' or 'n' will do
(defalias 'yes-or-no-p 'y-or-n-p)

;; UTF-8 please
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; Show active region
(transient-mark-mode 1)
(make-variable-buffer-local 'transient-mark-mode)
(put 'transient-mark-mode 'permanent-local t)
(setq-default transient-mark-mode t)

;; Remove text in active region if inserting text
(delete-selection-mode 1)

;; Always display line and column numbers
(setq line-number-mode t)
(setq column-number-mode t)
;; Display line numbers in margin. emacs 23 only.
(global-linum-mode t)                

;; Lines should be 80 characters wide, not 72
(setq fill-column 80)

;; Save a list of recent files visited.
;(require 'recentf)
(setq recentf-save-file (concat emacs-tmp-dir "/recentf")  ;; keep ~/ clean
      recentf-max-saved-items 100                          ;; max save 100
      recentf-max-menu-items 15)                           ;; max 15 in menu
(recentf-mode t)                                           ;; turn it on

;; Never insert tabs
(set-default 'indent-tabs-mode nil)

;; Show me empty lines after buffer end
(set-default 'indicate-empty-lines t)

;; Don't break lines for me, please
;(setq-default truncate-lines t)

;; Keep cursor away from edges when scrolling up/down
;(require 'smooth-scrolling)

;; Represent undo-history as an actual tree (visualize with C-x u)
;(setq undo-tree-mode-lighter "")
;(require 'undo-tree)
;(global-undo-tree-mode)

;; Add parts of each file's directory to the buffer name if not unique
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward
      uniquify-after-kill-buffer-p t
      uniquify-ignore-buffers-re "^\\*")

(provide 'sane-defaults)
