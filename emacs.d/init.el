;; init.el file
;; Rishi Dhupar
;; Time-stamp: <04-13-2011 16:57:12 (rkd4127)>

;; Check for Linux and start the server
;(if (string-equal system-type "gnu/linux")
;  (server-start)
;  (message "emacsserver started."))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; loadpath; this will recursively add all dirs in 'elisp-path' to load-path
(defconst elisp-path '("~/.emacs.d")) ;; my elisp directories
(mapcar '(lambda(p)
           (add-to-list 'load-path p)
           (cd p) (normal-top-level-add-subdirs-to-load-path)) elisp-path)

(defconst djcb-config-dir "~/.emacs.d/config/")
(defconst djcb-emacs-dir  "~/.emacs.d")
(defconst djcb-tmp-dir    "~/.emacs.tmp")

;; id-tag; 'user@machine'; used for machine-specific configuration,
;; as part of machine-specific configuration files
(defconst djcb-id-tag (concat (user-login-name) "@" (system-name)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; djcb-require-maybe  (http://www.emacswiki.org/cgi-bin/wiki/LocateLibrary)
;; this is useful when this .emacs is used in an env where not all of the
;; other stuff is available
(defmacro djcb-require-maybe (feature &optional file)
  "*Try to require FEATURE, but don't signal an error if `require' fails."
  `(require ,feature ,file 'noerror))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; load my handy functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(djcb-require-maybe 'djcb-funcs) ;; load it it can be found...
(require 'cl) ;; some package require cl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ELPA
;;(when (load (expand-file-name "~/.emacs.d/elpa/package.el"))
;;  (package-initialize))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; system type
(defconst djcb-win32-p (eq system-type 'windows-nt) "Are we on Windows?")
(defconst djcb-linux-p (or (eq system-type 'gnu/linux)(eq system-type 'linux))
  "Are we running on a GNU/Linux system?")
(defconst djcb-console-p (eq (symbol-value 'window-system) nil)
  "Are we in a console?")
(defconst djcb-machine (substring (shell-command-to-string "hostname") 0 -1))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; the modeline
(line-number-mode t)                     ; show line numbers
(global-linum-mode t)                    ; display line numbers in margin. emacs 23 only.
;(column-number-mode t)                   ; show column numbers
(when (fboundp size-indication-mode)
  (size-indication-mode t))              ; show file size (emacs 22+)
(display-time-mode -1)                   ; don't show the time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; general settings
(menu-bar-mode  t)                       ; show the menu...
(tool-bar-mode -1)                       ; ... but not the the toolbar
;;(ruler-mode t)
(mouse-avoidance-mode 'jump)             ; mouse ptr when cursor is too close
(icomplete-mode t)                       ; completion in minibuffer
(setq icomplete-prospects-height 2)      ; don't spam my minibuffer
(scroll-bar-mode t)                      ; show a scrollbar...
(set-scroll-bar-mode 'right)             ; ... on the right

(partial-completion-mode t)              ; be smart with completion

(setq scroll-margin 1                    ; do smooth scrolling, ...
  scroll-conservatively 100000           ; ... the defaults ...
  scroll-up-aggressively 0.01            ; ... are very ...
  scroll-down-aggressively 0.01)         ; ... annoying

(when (fboundp 'set-fringe-mode)         ; emacs22+ 
  (set-fringe-mode 1))                   ; space left of col1 in pixels

(transient-mark-mode t)                  ; make the current 'selection' visible
(delete-selection-mode t)                ; delete the selection with a keypress
(setq x-select-enable-clipboard t        ; copy-paste should work ...
  interprogram-paste-function            ; ...with...
  'x-cut-buffer-or-selection-value)      ; ...other X clients

(setq search-highlight t                 ; highlight when searching... 
  query-replace-highlight t)             ; ...and replacing
(fset 'yes-or-no-p 'y-or-n-p)            ; enable y/n answers to yes/no 

(global-font-lock-mode t)                ; always do syntax highlighting 

(setq completion-ignore-case t           ; ignore case when completing...
  read-file-name-completion-ignore-case t) ; ...filenames too

;(put 'narrow-to-region 'disabled nil)    ; enable...
(put 'erase-buffer 'disabled nil)        ; ... useful things
(when (fboundp file-name-shadow-mode)    ; emacs22+
  (file-name-shadow-mode t))             ; be smart about filenames in mbuf

(setq inhibit-startup-message t          ; don't show ...    
  inhibit-startup-echo-area-message t    ; startup messages
  inhibit-splash-screen t)               ; ... splash screen

;(setq require-final-newline t)           ; end files with a newline
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; display settings
(defun set-frame-size-according-to-resolution ()
  (interactive)
  (if window-system
  (progn
    (add-to-list 'default-frame-alist (cons 'top 80))
    (add-to-list 'default-frame-alist (cons 'left 400))
    ;; use 120 char wide window for largeish displays
    ;; and smaller 80 column windows for smaller displays
    ;; pick whatever numbers make sense for you
    (if (> (x-display-pixel-width) 1280)
        (add-to-list 'default-frame-alist (cons 'width 120))
      (add-to-list 'default-frame-alist (cons 'width 80)))
    ;; for the height, subtract a couple hundred pixels
    ;; from the screen height (for panels, menubars and
    ;; whatnot), then divide by the height of a char to
    ;; get the height we want
    (add-to-list 'default-frame-alist 
                 (cons 'height (/ (- (x-display-pixel-height) 200) (frame-char-height)))))))

(set-frame-size-according-to-resolution)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; utf8 / input-method
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-language-environment "UTF-8")       ; prefer utf-8 for language settings
(set-input-method nil)                   ; no funky input for normal editing;
(setq read-quoted-char-radix 10)         ; use decimal, not octal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; saving things across sessions
;; bookmarks
(setq bookmark-default-file "~/.emacs.d/bookmarks") ;; bookmarks
;;
;; saveplace: save location in file when saving files
(setq save-place-file
  (concat djcb-tmp-dir "/saveplace"))  ;; keep my ~/ clean
(setq-default save-place t)            ;; activate it for all buffers
(require 'saveplace)                   ;; get the package
;;
;; savehist: save some history
;(setq savehist-additional-variables    ;; also save...
;  '(search ring regexp-search-ring)    ;; ... my search entries
;  savehist-autosave-interval 60        ;; save every minute (default: 5 min)
;  savehist-file (concat djcb-tmp-dir "/savehist"))   ;; keep my home clean
;(savehist-mode t)                      ;; do customization before activation

;; recentf
;(when (djcb-require-maybe 'recentf)    ;; save recently used files
;  (setq recentf-save-file (concat djcb-tmp-dir "/recentf") ;; keep ~/ clean
;    recentf-max-saved-items 100          ;; max save 100
;    recentf-max-menu-items 15)         ;; max 15 in menu
;    (recentf-mode t))                  ;; turn it on
;;
;; filecache: http://www.emacswiki.org/cgi-bin/wiki/FileNameCache
;(eval-after-load "filecache" 
;  '(progn (message "Loading file cache...")
;     (file-cache-add-directory "~/")
;     (file-cache-add-directory-list (list "~/Desktop" "~/Documents"))))
;;
;; backups
(setq auto-save-list-file-name nil)     ; no .saves files
(setq auto-save-default        t)       ; auto saving
(setq djcb-backup-dir (concat djcb-tmp-dir "/backups"))
(setq make-backup-files t ;; do make backups
  backup-by-copying t     ;; and copy them here
  backup-directory-alist '(("." . "~/.emacs.tmp/backups")) ;; FIXME
  version-control t
  kept-new-versions 3
  kept-old-versions 5
  delete-old-versions t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; misc small stuff
;; url proxy services
(setq url-proxy-services
       '(("http"     . "rkd4127@gw6alt.draper.com:3128")
         ))

;; time-stamps 
(setq ;; when there's "Time-stamp: <>" in the first 10 lines of the file
  time-stamp-active t        ; do enable time-stamps
  time-stamp-line-limit 10   ; check first 10 buffer lines for Time-stamp: <>
  time-stamp-format "%02m-%02d-%04y %02H:%02M:%02S (%u)") ; date format
(add-hook 'write-file-hooks 'time-stamp) ; update when saving

;; cursor
(blink-cursor-mode 0)           ; don't blink cursor

;; http://www.emacswiki.org/cgi-bin/wiki/download/cursor-chg.el
;; change cursor for verwrite/read-only/input 
(when (djcb-require-maybe 'cursor-chg)  ; Load this library
  (change-cursor-mode 1) ; On for overwrite/read-only/input mode
  (toggle-cursor-type-when-idle 1)
  (setq curchg-default-cursor-color "Yellow"))

;; highlight the current line
(when (fboundp 'global-hl-line-mode)
  (global-hl-line-mode t)) ;; turn it on for all modes by default

;; show-paren-mode: subtle blinking of matching paren (defaults are ugly)
;; http://www.emacswiki.org/cgi-bin/wiki/ShowParenMode
(when (fboundp 'show-paren-mode)
  (show-paren-mode t)
  (setq show-paren-style 'parenthesis))

;; higlight changes
(global-highlight-changes-mode t)
(setq highlight-changes-visibility-initial-state nil)

(when (djcb-require-maybe 'uniquify) ;; make buffer names more unique
  (setq 
    uniquify-buffer-name-style 'post-forward
;   uniquify-separator ":"
    uniquify-after-kill-buffer-p t
    uniquify-ignore-buffers-re "^\\*"))

;; use AnsiTerm which does support colors or you can enable AnsiColor for the normal shell:
;; http://www.emacswiki.org/emacs/AnsiTerm
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; hippie-expand
;(setq hippie-expand-try-functions-list
;  '(yas/hippie-try-expand try-expand-all-abbrevs try-expand-dabbrev
;     try-expand-dabbrev-from-kill
;     try-complete-lisp-symbol-partially try-complete-lisp-symbol-partially
;     try-expand-dabbrev-all-buffers))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; tramp, for remote access
;(require 'tramp)
;(setq tramp-default-method "ssh")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; default-fonts
(set-default-font
  (cond 
    (djcb-win32-p
      "-outline-Consolas-normal-r-normal-normal-14-97-96-96-c-*-iso8859-1")
    ((and (not djcb-console-p) djcb-linux-p)
      (= 0 (shell-command "fc-list | grep Inconsolata"))
      "Inconsolata-14")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (require 'color-theme)  ;; use color theme...
(eval-after-load "color-theme"
  '(progn
     (color-theme-initialize)
     (color-theme-almost-monokai)))) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; global keybindings
(defmacro djcb-program-shortcut (name key &optional use-existing)
  "* macro to create a key binding KEY to start some terminal program PRG; 
    if USE-EXISTING is true, try to switch to an existing buffer"
  `(global-set-key ,key 
     '(lambda() (interactive) 
        (djcb-term-start-or-switch ,name ,use-existing))))

(global-set-key (kbd "<delete>")    'delete-char)  ; delete == delete    
(global-set-key (kbd "M-g")         'goto-line)    ; M-g  'goto-line
;; kill whole line with C-; (because ; is close to k)
(global-set-key (kbd "C-;") 'kill-whole-line)

;; C-pgup goes to the start, C-pgdw goes to the end
(global-set-key(kbd "<C-prior>")(lambda()(interactive)(goto-char(point-min))))
(global-set-key(kbd "<C-next>") (lambda()(interactive)(goto-char(point-max))))

(global-set-key (kbd "C-z") 'undo)   ;; use it like CUA, not like 'suspend'
(global-set-key (kbd "s-b") 'pop-global-mark) ; jump *back* to prev location

; replace-string and replace-regexp need a key binding
(global-set-key (kbd "C-c s") 'replace-string)
(global-set-key (kbd "C-c r") 'replace-regexp)

;; programming/writing stuff; f5-f8 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "<f7>") 'compile)                     ;; compile
(global-set-key (kbd "S-<f7>") 'delete-other-windows)      ;; close ...


(global-set-key (kbd "<f8>") 'comment-or-uncomment-region) ;; (un)comment
;; for writing
(global-set-key (kbd "C-<f5>") 'djcb-count-words)          ;; count words
(when (djcb-require-maybe 'magit)                          ;; marius...
  (global-set-key (kbd "C-<f6>") 'magit-status))           ;; ...git mode
;; some toggles; Shift + function key
(global-set-key (kbd "<S-f6>") 'highlight-changes-visible-mode) ;; changes
(global-set-key (kbd "<S-f7>") 'whitepace-mode)            ;; show blanks
(autoload 'linum "linum" "mode for line numbers" t) 
(global-set-key (kbd "<S-f9>")   'djcb-fullscreen-toggle)  ;; fullscreen
(global-set-key (kbd "<S-<f10>")  'package-list-packages)  ;; elpa

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(global-set-key (kbd "M-X") 'smex) ;; use smex
;; this depends on smex availability                                              
;(setq smex-save-file (concat djcb-tmp-dir "/smex.save"))              
;(when (djcb-require-maybe 'smex)                                                  
;  (smex-initialize))                                                           

;; hippy expands starts with try-yasnippet-expand
(global-set-key [(control tab)] 'hippie-expand) ; Ctrl-Tab for expand

;; tab is for indentation, not completion
(global-set-key (kbd "TAB") 'indent-for-tab-command)
(setq-default indent-tabs-mode nil)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; yasnippet 
;(when (djcb-require-maybe 'yasnippet-bundle) ;; note: yasnippet-bundle
;  (setq yas/trigger-key [(super tab)])       
;  yas/next-field-key [(control tab)])
;
;(djcb-require-maybe 'djcb-yasnippet-bundle)
;(defun djcb-yasnippet-compile-bundle ()
;  "create a bundle of my own snippets"
;  (interactive)
;  (yas/compile-bundle 
;    "~/.emacs.d/elisp/yasnippet-0.5.9/yasnippet.el"
;    "~/.emacs.d/elisp/djcb-yasnippet-bundle.el"
;    '("~/.emacs.d/yasnippets/")
;    "(yas/initialize)"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ido makes completing buffers and ffinding files easier
;; http://www.emacswiki.org/cgi-bin/wiki/InteractivelyDoThings
;(require 'ido) 
;(ido-mode 'buffers) ;; only for buffers
;(setq 
;  ido-save-directory-list-file (concat djcb-tmp-dir "/ido.last")
;  ido-ignore-buffers ;; ignore these guys
;  '("\\` " "^\*Mess" "^\*Back" ".*Completion" "^\*Ido")
;  ido-work-directory-list '("~/" "~/Desktop" "~/Documents")
;  ido-everywhere t                 ; use for many file dialogs
;  ido-case-fold  t                 ; be case-insensitive
;  ido-enable-last-directory-history t ; remember last used dirs
;  ido-max-work-directory-list 30   ; should be enough
;  ido-max-work-file-list      50   ; remember many
;  ido-use-filename-at-point nil    ; don't use filename at point (annoying)
;  ido-use-url-at-point nil         ;  don't use url at point (annoying)
;  ido-enable-flex-matching t       ; be flexible
;  ido-max-prospects 4              ; don't spam my minibuffer
;  ido-confirm-unique-completion t) ; wait for RET, even with unique completion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; easy way to find the definitions of Emacs Lisp functions and variables
;(require 'find-func)  
;(find-function-setup-keys)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; macros to save me some type creating keyboard macros
(defmacro set-key-func (key expr)
  "macro to save me typing"
  (list 'local-set-key (list 'kbd key) 
        (list 'lambda nil 
              (list 'interactive nil) expr)))
(defmacro set-key (key str) (list 'local-set-key (list 'kbd key) str))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;text-mode
(add-hook 'text-mode-hook
  (lambda() 
    (set-fill-column 78)                    ; lines are 78 chars long ...
    (auto-fill-mode t)                      ; ... and wrapped around 
    (set-input-method "latin-1-prefix")))    ; make " + e => ë etc.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; html/html-helper mode
;; my handy stuff for both html-helper and x(ht)ml mode
(add-hook 'html-helper-mode-hook
  (lambda()
    (abbrev-mode t)             ; support abbrevs
    (auto-fill-mode -1)         ; don't do auto-filling
    ;; my own texdrive, for including TeX formulae
    ;; http://www.djcbsoftware.nl/code/texdrive/
    (when (djcb-require-maybe 'texdrive) (texdrive-mode t))))
(setq auto-mode-alist (cons '("\\.html$" . html-helper-mode) auto-mode-alist))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TeX/LaTex
(defun djcb-tex-mode-hook ()
  "my TeX/LaTeX (auctex) settings"
  (interactive)
  (setq
    TeX-brace-indent-level 0 ;; don't screw up \index
    LaTeX-item-ident       2
    TeX-parse-self         t ; Enable parse on load.
    TeX-auto-save          t)) ; Enable parse on save.
  
(add-hook 'tex-mode-hook 'djcb-tex-mode-hook)
(add-hook 'LaTeX-mode-hook 'djcb-tex-mode-hook)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Elisp
(add-hook 'emacs-lisp-mode-hook 
  (lambda()
    (local-set-key (kbd "<f7>") ;; overrides global f7 (compile) 
      '(lambda()(interactive) 
         (let ((debug-on-error t)) 
           (eval-buffer)
           (message "buffer evaluated")))) ; 
    
    (setq lisp-indent-offset 2) ; indent with two spaces, enough for lisp
    (djcb-require-maybe 'folding)
    (font-lock-add-keywords nil 
      '(("\\<\\(FIXME\\|TODO\\|XXX+\\|BUG\\)" 
          1 font-lock-warning-face prepend)))  
    (font-lock-add-keywords nil 
      '(("\\<\\(djcb-require-maybe\\|add-hook\\|setq\\)" 
          1 font-lock-keyword-face prepend)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org mode
(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(setq org-log-done t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; perl/cperl mode
(defalias 'perl-mode 'cperl-mode) ; cperl mode is what we want
(add-hook 'cperl-mode-hook
  (lambda()
    (eval-when-compile (require 'cperl-mode))
    (abbrev-mode -1)                  ; turn-off the annoying elecric crap
    (setq 
      cperl-hairy t                  ; parse hairy perl constructs
      cperl-indent-level 4           ; indent with 4 positions
      cperl-invalid-face nil        ; don't show stupid underlines
      cperl-electric-keywords t)))   ; complete keywords
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; cmake mode
; Add cmake listfile names to the mode list.
(require 'cmake-mode)
(setq auto-mode-alist
	  (append
	   '(("CMakeLists\\.txt\\'" . cmake-mode))
	   '(("\\.cmake\\'" . cmake-mode))
	   auto-mode-alist))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; gtags
(add-hook 'gtags-mode-hook 
  (lambda()
    (local-set-key (kbd "M-.") 'gtags-find-tag)   ; find a tag, also M-.
    (local-set-key (kbd "M-,") 'gtags-find-rtag)  ; reverse tag
    (local-set-key (kbd "s-n") 'gtags-pop-stack)
    (local-set-key (kbd "s-p") 'gtags-find-pattern)
    (local-set-key (kbd "s-g") 'gtags-find-with-grep)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; c-mode / c++-mode
(defconst djcb-c-style '((c-tab-always-indent . t)))

(defun djcb-c-mode-common ()
  (interactive) 
  (c-add-style "djcb" djcb-c-style)  
  (c-set-style "ellemtel" djcb-c-style)
  (hs-minor-mode t) ; hide-show
  (font-lock-add-keywords nil 
    '(("\\<\\(FIXME\\|TODO\\|XXX+\\|BUG\\):" 
        1 font-lock-warning-face prepend)))  
  ;; highlight some stuff; this is for _all_ c modes
  (font-lock-add-keywords nil 
    '(("\\<\\(__FUNCTION__\\|__PRETTY_FUNCTION__\\|__LINE__\\)" 
        1 font-lock-preprocessor-face prepend)))
 
  (setq 
    compilation-scroll-output 'first-error  ; scroll until first error
    compilation-read-command nil            ; don't need enter
    compilation-window-height 12)           ; keep it readable

  (setq
    c-basic-offset 2                        ; linux kernel style
    c-hungry-delete-key t)                  ; eat as much as possible
  
  ;; guess the identation of the current file, and use
  ;; that instead of my own settings
  (when  (djcb-require-maybe 'dtrt-indent) (dtrt-indent-mode t))

  (when (not (string-match "/usr/src/linux" 
               (expand-file-name default-directory)))
    (when (djcb-require-maybe 'gtags) 
      (gtags-mode t)
      (djcb-gtags-create-or-update)))  
  (when (djcb-require-maybe 'doxymacs)
    (doxymacs-mode t)
    (doxymacs-font-lock))
  
  (local-set-key (kbd "<M-up>")   'previous-error) 
  (local-set-key (kbd "<M-down>") 'next-error)
  (local-set-key (kbd "C-c i")    'djcb-include-guards)  
  (local-set-key (kbd "C-c o")    'ff-find-other-file)
  
  ;; warn when lines are > 80 characters (in c-mode)
  (font-lock-add-keywords 'c-mode '(("^[^\n]\\{80\\}\\(.*\\)$"
                                      1 font-lock-warning-face prepend))))
(defun djcb-c++-mode ()
  ;; warn when lines are > 100 characters (in c++-mode)
  (font-lock-add-keywords 'c++-mode  '(("^[^\n]\\{100\\}\\(.*\\)$"
                                         1 font-lock-warning-face prepend))))

(add-hook 'c-mode-common-hook 'djcb-c-mode-common) ; run before all c-modes
;;(add-hook 'c-mode-hook 'djcb-c-mode)               ; run before c mode
(add-hook 'c++-mode-hook 'djcb-c++-mode)           ; run before c++ mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Makefiles
(add-hook 'makefile-mode-hook
  (lambda()
    (whitespace-mode t)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; compilation
(setq compilation-window-height 12)
(setq compilation-finish-functions nil) ;; keep it open
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; customization for term, ansi-term
;; disable cua and transient mark modes in term-char-mode
;; http://www.emacswiki.org/emacs/AnsiTermHints
;; remember: Term-mode remaps C-x to C-c
(defadvice term-char-mode (after term-char-mode-fixes ())
  (set (make-local-variable 'cua-mode) nil)
  (set (make-local-variable 'transient-mark-mode) nil)
  (set (make-local-variable 'global-hl-line-mode) nil)
  (ad-activate 'term-char-mode)
  (term-set-escape-char ?\C-x))

(add-hook 'term-mode-hook 
  (lambda() 
    (local-set-key [(tab)] nil)
    (local-set-key (kbd "<C-f1>") 
      '(lambda()(interactive)
         (shell-command "killall -SIGWINCH mutt slrn irssi zsh")))))    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; safe locals; we mark these as 'safe', so emacs22+ won't give us annoying
;; warnings
(setq safe-local-variable-values
      (quote ((auto-recompile . t)
              (outline-minor-mode . t)
              auto-recompile outline-minor-mode)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun message-startup-time ()
  "Display a message of how long Emacs took to start up, in milliseconds."
  (message "Emacs loaded in %dms"
           (/ (-
               (+
                (third after-init-time)
                (* 1000000
                   (second after-init-time)))
               (+
                (third before-init-time)
                (* 1000000
                   (second before-init-time))))
              1000)))
 
(add-hook 'after-init-hook 'message-startup-time)
                           
;; FIN
