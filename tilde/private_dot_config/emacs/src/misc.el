;;; misc.el --- Things that don't fit anywhere else
;;
;; Part of the Emacs Starter Kit

;; time-stamps
(setq ;; when there's "Time-stamp: <01-31-2012 19:11:59 (ubuntu)>" in the first 10 lines of the file
  time-stamp-active t        ; do enable time-stamps
  time-stamp-line-limit 10   ; check first 10 buffer lines for Time-stamp: <>
  time-stamp-format "%02m-%02d-%04y %02H:%02M:%02S (%u)") ; date format
(add-hook 'write-file-hooks 'time-stamp) ; update when saving

(ansi-color-for-comint-mode-on)

(setq visible-bell t
      fringe-mode (cons 4 0)
      echo-keystrokes 0.1
      font-lock-maximum-decoration t
      delete-selection-mode t
      shift-select-mode nil
      uniquify-buffer-name-style 'post-forward
      uniquify-after-kill-buffer-p t
      uniquify-ignore-buffers-re "^\\*"
      ffap-machine-p-known 'reject
      whitespace-style '(trailing lines space-before-tab
                                  face indentation space-after-tab)
      whitespace-line-column 100
      ediff-window-setup-function 'ediff-setup-windows-plain
      oddmuse-directory (concat emacs-dir "oddmuse")
      xterm-mouse-mode t)

(add-to-list 'safe-local-variable-values '(lexical-binding . t))
(add-to-list 'safe-local-variable-values '(whitespace-line-column . 80))

;; Transparently open compressed files
(auto-compression-mode t)

;; recentf - Save a list of recent files visited.
(when (require-soft 'recentf)
  (setq recentf-save-file (concat emacs-tmp-dir "/recentf")  ;; keep ~/ clean
        recentf-max-saved-items 100                         ;; max save 100
        recentf-max-menu-items 15)                          ;; max 15 in menu
        (recentf-mode t))                                   ;; turn it on

 ;; scroll just one line when hitting the bottom of the window
(setq scroll-preserve-screen-position 1)
(setq scroll-margin 1                    ; do smooth scrolling, ...
  scroll-conservatively 100000           ; ... the defaults ...
  scroll-up-aggressively 0.01            ; ... are very ...
  scroll-down-aggressively 0.01)         ; ... annoying

(set-default 'indicate-empty-lines t)
(set-default 'imenu-auto-rescan t)

;(put 'narrow-to-region 'disabled nil)    ; enable...
(put 'erase-buffer 'disabled nil)        ; ... useful things
(when (fboundp file-name-shadow-mode)    ; emacs22+
  (file-name-shadow-mode t))             ; be smart about filenames in mbuf

(add-hook 'gtags-mode-hook
  (lambda()
    (local-set-key (kbd "M-.") 'gtags-find-tag)   ; find a tag, also M-.
    (local-set-key (kbd "M-,") 'gtags-find-rtag)  ; reverse tag
    (local-set-key (kbd "s-n") 'gtags-pop-stack)
    (local-set-key (kbd "s-p") 'gtags-find-pattern)
    (local-set-key (kbd "s-g") 'gtags-find-with-grep)))

(defvar coding-hook nil
  "Hook that gets run on activation of any programming mode.")

(defalias 'auto-revert-tail-mode 'tail-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; saving things across sessions
;; bookmarks
(setq bookmark-default-file (concat emacs-tmp-dir "/bookmarks")) ;; bookmarks

;; ---------------------------------------------------------- [ saveplace ]
;; save location in file when saving files
(setq save-place-file
  (concat emacs-tmp-dir "/saveplace"))  ;; keep my ~/ clean
(setq-default save-place t)            ;; activate it for all buffers

;; ---------------------------------------------------------- [ diminish ]
;; Makes minor mode names in the modeline shorter.
(require 'diminish)

(eval-after-load "filladapt"
  '(diminish 'filladapt-mode "Fill"))
(eval-after-load "abbrev"
  '(diminish 'abbrev-mode "Abv"))
(eval-after-load "doxymacs"
  '(diminish 'doxymacs-mode "dox"))

;; -------------------------------------------------------- [ backup-dir ]
;; Changes the location where backup files are placed. Instead of
;; being spread out all over the filesystem, they're now placed in one
;; location.
(setq auto-save-list-file-name nil)     ; no .saves files
(setq auto-save-default        t)       ; auto saving
(setq make-backup-files t ;; do make backups
  backup-by-copying t     ;; and copy them here
  backup-directory-alist `(("." . ,(expand-file-name (concat emacs-tmp-dir "/backups"))))
  version-control t
  kept-new-versions 3
  kept-old-versions 5
  delete-old-versions t)

;; http://www.emacswiki.org/cgi-bin/wiki/download/cursor-chg.el
;; change cursor for verwrite/read-only/input
(when (require-soft 'cursor-chg)  ; Load this library
  (change-cursor-mode 1) ; On for overwrite/read-only/input mode
  (toggle-cursor-type-when-idle 1)
  (setq curchg-default-cursor-color "Yellow"))

;; highlight changes
(global-highlight-changes-mode t)
(setq highlight-changes-visibility-initial-state nil)

;; html/html-helper mode
;; my handy stuff for both html-helper and x(ht)ml mode
(add-hook 'html-helper-mode-hook
  (lambda()
    (abbrev-mode t)             ; support abbrevs
    (auto-fill-mode -1)))       ; don't do auto-filling

;; nxhtml stuff
(setq mumamo-chunk-coloring 'submode-colored
      nxhtml-skip-welcome t
      indent-region-mode t
      rng-nxml-auto-validate-flag nil)

;; Associate modes with file extensions
(add-to-list 'auto-mode-alist '("COMMIT_EDITMSG$" . diff-mode))
(add-to-list 'auto-mode-alist '("\\.css$" . css-mode))
(add-to-list 'auto-mode-alist '("\\.ya?ml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.js\\(on\\)?$" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.html$" . html-helper-mode))
(add-to-list 'auto-mode-alist '("\\.xml$" . nxml-mode))

(eval-after-load 'grep
  '(when (boundp 'grep-find-ignored-files)
    (add-to-list 'grep-find-ignored-files "target")
    (add-to-list 'grep-find-ignored-files "*.class")))

;; Default to unified diffs
(setq diff-switches "-u -w")

;; Cosmetics

;; (set-face-background 'vertical-border "white")
;; (set-face-foreground 'vertical-border "white")

(eval-after-load 'diff-mode
  '(progn
     (set-face-foreground 'diff-added "green4")
     (set-face-foreground 'diff-removed "red3")))

(eval-after-load 'magit
  '(progn
     (set-face-foreground 'magit-diff-add "green3")
     (set-face-foreground 'magit-diff-del "red3")))

(eval-after-load 'mumamo
  '(eval-after-load 'zenburn
     '(ignore-errors (set-face-background
                      'mumamo-background-chunk-submode "gray22"))))

;; make emacs use the clipboard
(setq x-select-enable-clipboard t        ; copy-paste should work ...
  interprogram-paste-function            ; ...with...
  'x-cut-buffer-or-selection-value)      ; ...other X clients

;; Get around the emacswiki spam protection
(add-hook 'oddmuse-mode-hook
          (lambda ()
            (unless (string-match "question" oddmuse-post)
              (setq oddmuse-post (concat "uihnscuskc=1;" oddmuse-post)))))

;; safe locals; we mark these as 'safe', so emacs22+ won't give us annoying
;; warnings
(setq safe-local-variable-values
      (quote ((auto-recompile . t)
              (outline-minor-mode . t)
              auto-recompile outline-minor-mode)))

;; -----------------------------------------------------------------------
;; Prevent the bell from ringing all the time.
;; -----------------------------------------------------------------------
;; nice little alternative visual bell; Miles Bader <miles /at/ gnu.org>

;; TODO(erg): Figure out why that note doesn't appear in the mode-line-bar...
(defcustom mode-line-bell-string "ding" ; "?"
  "Message displayed in mode-line by `mode-line-bell' function."
  :group 'user)
(defcustom mode-line-bell-delay 0.1
  "Number of seconds `mode-line-bell' displays its message."
  :group 'user)

;; internal variables
(defvar mode-line-bell-cached-string nil)
(defvar mode-line-bell-propertized-string nil)

(defun mode-line-bell ()
  "Briefly display a highlighted message in the mode-line.

The string displayed is the value of `mode-line-bell-string',
with a red background; the background highlighting extends to the
right margin.  The string is displayed for `mode-line-bell-delay'
seconds.

This function is intended to be used as a value of `ring-bell-function'."

  (unless (equal mode-line-bell-string mode-line-bell-cached-string)
    (setq mode-line-bell-propertized-string
      (propertize
       (concat
        (propertize
         "x"
         'display
         `(space :align-to (- right ,(string-width mode-line-bell-string))))
        mode-line-bell-string)
       'face '(:background "red")))
    (setq mode-line-bell-cached-string mode-line-bell-string))
  (message mode-line-bell-propertized-string)
  (sit-for mode-line-bell-delay)
  (message ""))

(setq ring-bell-function 'mode-line-bell)

;; -------------------------------------------------- [ browse-kill-ring ]
;; Select something that you put in the kill ring ages ago.
(autoload 'browse-kill-ring "browse-kill-ring" "Browse the kill ring." t)
(global-set-key (kbd "C-c k") 'browse-kill-ring)
(eval-after-load "browse-kill-ring"
  '(progn
     (setq browse-kill-ring-quit-action 'save-and-restore)))

(provide 'misc)
;;; misc.el ends here
