;;; misc.el --- Things that don't fit anywhere else
;;
;; Part of the Emacs Starter Kit

;;; system type
(defconst djcb-win32-p (eq system-type 'windows-nt) "Are we on Windows?")
(defconst djcb-linux-p (or (eq system-type 'gnu/linux)(eq system-type 'linux))
  "Are we running on a GNU/Linux system?")
(defconst djcb-console-p (eq (symbol-value 'window-system) nil)
  "Are we in a console?")
(defconst djcb-machine (substring (shell-command-to-string "hostname") 0 -1))



;;(scroll-bar-mode t)                      ; show a scrollbar...
;;(set-scroll-bar-mode 'right)             ; ... on the right

;; time-stamps 
(setq ;; when there's "Time-stamp: <>" in the first 10 lines of the file
  time-stamp-active t        ; do enable time-stamps
  time-stamp-line-limit 10   ; check first 10 buffer lines for Time-stamp: <>
  time-stamp-format "%02m-%02d-%04y %02H:%02M:%02S (%u)") ; date format
(add-hook 'write-file-hooks 'time-stamp) ; update when saving



(add-hook 'before-make-frame-hook 'turn-off-tool-bar)

(ansi-color-for-comint-mode-on)

(setq visible-bell t
      fringe-mode (cons 4 0)
      echo-keystrokes 0.1
      font-lock-maximum-decoration t
      delete-selection-mode t
      shift-select-mode nil
      truncate-partial-width-windows nil
      uniquify-buffer-name-style 'post-forward
      uniquify-after-kill-buffer-p t
      uniquify-ignore-buffers-re "^\\*"
      ffap-machine-p-known 'reject
      whitespace-style '(trailing lines space-before-tab
                                  face indentation space-after-tab)
      whitespace-line-column 100
      ediff-window-setup-function 'ediff-setup-windows-plain
      oddmuse-directory (concat emacs-dir "oddmuse")
      xterm-mouse-mode t
      save-place-file (concat emacs-dir "places"))

(add-to-list 'safe-local-variable-values '(lexical-binding . t))
(add-to-list 'safe-local-variable-values '(whitespace-line-column . 80))

;; Set this to whatever browser you use
;; (setq browse-url-browser-function 'browse-url-firefox)
;; (setq browse-url-browser-function 'browse-default-macosx-browser)
;; (setq browse-url-browser-function 'browse-default-windows-browser)
;; (setq browse-url-browser-function 'browse-default-kde)
;; (setq browse-url-browser-function 'browse-default-epiphany)
;; (setq browse-url-browser-function 'browse-default-w3m)
;; (setq browse-url-browser-function 'browse-url-generic
;;       browse-url-generic-program "~/src/conkeror/conkeror")

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

;; ido makes completing buffers and finding files easier
;; http://www.emacswiki.org/cgi-bin/wiki/InteractivelyDoThings
;; ido-mode is like magic pixie dust!
(when (> emacs-major-version 21)
  (ido-mode 'both)
  (setq 
    ido-save-directory-list-file (concat emacs-tmp-dir "/ido.last")
    ido-ignore-buffers ;; ignore these guys
    '("\\` " "^\*Mess" "^\*Back" ".*Completion" "^\*Ido")
    ido-work-directory-list '("~/" "~/Desktop" "~/Documents")
    ido-everywhere t                                              ; use for many file dialogs
    ido-case-fold  t                                              ; be case-insensitive
    ido-enable-last-directory-history t                           ; remember last used dirs
    ido-max-work-directory-list 30                                ; should be enough
    ido-max-work-file-list      50                                ; remember many
    ido-use-filename-at-point nil                                 ; don't use filename at point (annoying)
    ido-use-url-at-point nil                                      ;  don't use url at point (annoying)ido-enable-prefix nil
    ido-enable-flex-matching t                                    ; be flexible
    ido-create-new-buffer 'always
    ido-use-filename-at-point 'guess
    ido-confirm-unique-completion t                              ; wait for RET, even with unique completion
    ido-max-prospects 10)                                        ; don't spam my minibuffer
)

(set-default 'indent-tabs-mode nil)
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
    
;; text-mode
(add-hook 'text-mode-hook
  (lambda()     
    (set-fill-column 78)                    ; lines are 78 chars long ...
    (auto-fill-mode t)                      ; ... and wrapped around 
    (turn-on-flyspell t)))                    ; on-the-fly spelling checking

(defvar coding-hook nil
  "Hook that gets run on activation of any programming mode.")

;; url proxy services
(setq url-proxy-services
       '(("http"     . "rkd4127@gw6alt.draper.com:3128")
         ))
         
(random t) ;; Seed the random-number generator

(defalias 'auto-revert-tail-mode 'tail-mode)

;; Hippie expand: at times perhaps too hip
(delete 'try-expand-line hippie-expand-try-functions-list)
(delete 'try-expand-list hippie-expand-try-functions-list)
(delete 'try-complete-file-name-partially hippie-expand-try-functions-list)
(delete 'try-complete-file-name hippie-expand-try-functions-list)
;(setq hippie-expand-try-functions-list
;  '(yas/hippie-try-expand try-expand-all-abbrevs try-expand-dabbrev
;     try-expand-dabbrev-from-kill
;     try-complete-lisp-symbol-partially try-complete-lisp-symbol-partially
;     try-expand-dabbrev-all-buffers))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; saving things across sessions
;; bookmarks
(setq bookmark-default-file (concat emacs-tmp-dir "/bookmarks")) ;; bookmarks

;; saveplace: save location in file when saving files
(setq save-place-file
  (concat emacs-tmp-dir "/saveplace"))  ;; keep my ~/ clean
(setq-default save-place t)            ;; activate it for all buffers
(require 'saveplace)                   ;; get the package
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; backups
(setq auto-save-list-file-name nil)     ; no .saves files
(setq auto-save-default        t)       ; auto saving
(setq djcb-backup-dir (concat emacs-tmp-dir "/backups"))
(setq make-backup-files t ;; do make backups
  backup-by-copying t     ;; and copy them here
  backup-directory-alist `(("." . ,(expand-file-name (concat emacs-tmp-dir "/backups"))))  
  version-control t
  kept-new-versions 3
  kept-old-versions 5
  delete-old-versions t)  
;;(setq backup-directory-alist `(("." . ,(expand-file-name (concat emacs-dir "backups")))))

;; http://www.emacswiki.org/cgi-bin/wiki/download/cursor-chg.el
;; change cursor for verwrite/read-only/input 
(when (require-soft 'cursor-chg)  ; Load this library
  (change-cursor-mode 1) ; On for overwrite/read-only/input mode
  (toggle-cursor-type-when-idle 1)
  (setq curchg-default-cursor-color "Yellow"))
  
;; higlight changes
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
      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; BELOW CODE IS UNUSED ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; filecache: http://www.emacswiki.org/cgi-bin/wiki/FileNameCache
;(eval-after-load "filecache" 
;  '(progn (message "Loading file cache...")
;     (file-cache-add-directory "~/")
;     (file-cache-add-directory-list (list "~/Desktop" "~/Documents"))))

;; tramp, for remote access
;(require 'tramp)
;(setq tramp-default-method "ssh")
                                        
;; yasnippet 
;(when (require-soft 'yasnippet-bundle) ;; note: yasnippet-bundle
;  (setq yas/trigger-key [(super tab)])       
;  yas/next-field-key [(control tab)])
;
;(require-soft 'djcb-yasnippet-bundle)
;(defun djcb-yasnippet-compile-bundle ()
;  "create a bundle of my own snippets"
;  (interactive)
;  (yas/compile-bundle 
;    "~/.emacs.d/elisp/yasnippet-0.5.9/yasnippet.el"
;    "~/.emacs.d/elisp/djcb-yasnippet-bundle.el"
;    '("~/.emacs.d/yasnippets/")
;    "(yas/initialize)"))

;; custom menu; http://emacs-fu.blogspot.com/2009/04/adding-custom-menus.html
;(easy-menu-define djcb-menu global-map "MyMenu"
;  '("djcb"
;     ("Programs" ;; submenu
;       ["mutt"  (djcb-term-start-or-switch "mutt" t)]
;       ["mc"    (djcb-term-start-or-switch "mc" t)]
;       ["htop"  (djcb-term-start-or-switch "htop" t)]
;       ["iotop" (djcb-term-start-or-switch "iotop" t)])
;
;     ("Org"
;       ["html"  (org-export-as-html 3 nil nil nil t)])
;
;     ("TeXDrive"  :visible (or (string= major-mode "html-helper-mode") 
;                             (string= major-mode "html-mode"))
;       ["Insert formula"   texdrive-insert-formula 
;         :help "Insert some formula"]
;       ["Generate images"  texdrive-generate-images 
;         :help "(Re)generate the images for the formulae"])
;     ("Twitter" ;; submenu
;       ["View friends" twitter-get-friends-timeline]
;       ["What are you doing?" twitter-status-edit])
;
;     ("Misc"  ;; submenu
;       ["Save & exit" save-buffers-kill-emacs]
;       ["Count words" djcb-count-words]
;       ["Show/hide line numbers" linum]
;       ["Toggle full-screen" djcb-fullscreen-toggle])))

;;; customization for term, ansi-term
;; disable cua and transient mark modes in term-char-mode
;; http://www.emacswiki.org/emacs/AnsiTermHints
;; remember: Term-mode remaps C-x to C-c
;(defadvice term-char-mode (after term-char-mode-fixes ())
;  (set (make-local-variable 'cua-mode) nil)
;  (set (make-local-variable 'transient-mark-mode) nil)
;  (set (make-local-variable 'global-hl-line-mode) nil)
;  (ad-activate 'term-char-mode)
;  (term-set-escape-char ?\C-x))

;(add-hook 'term-mode-hook 
;  (lambda() 
;    (local-set-key [(tab)] nil)
;    (local-set-key (kbd "<C-f1>") 
;      '(lambda()(interactive)
;         (shell-command "killall -SIGWINCH mutt slrn irssi zsh")))))  

(provide 'misc)
;;; misc.el ends here