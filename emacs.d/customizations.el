;;; customizations.el --- Customization of Emacs UI
;;

;; disable some ui components
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(scroll-bar-mode -1)

(setq enable-local-variables :safe
      inhibit-startup-message t  ;; no welcome message
      default-major-mode 'text-mode
      require-final-newline t
      default-tab-width 4
	  tab-width 4
      backward-delete-char-untabify 4
	  indent-tabs-mode nil
      default-fill-column 80
      global-hl-line-mode t ;; highlight current line
      truncate-partial-width-windows nil)
	  
;; defaults for graphical frames. important because emacsclient -c
;; doesn't respect the font of the default face.
;(setq window-system-default-frame-alist
;      '((x (font . "Bitstream Vera Sans Mono-8")
;           (background-color . "white")
;           (foreground-color . "black"))))

;; no echo area help on startup
(defun display-startup-echo-area-message ()
  (message ""))
  
;; default-fonts
;(set-face-attribute 'default nil :family "Inconsolata" :height 120)

;(set-default-font
;  (cond 
;    (djcb-win32-p
;      "-outline-Consolas-normal-r-normal-normal-14-97-96-96-c-*-iso8859-1")
;    ((and (not djcb-console-p) djcb-linux-p)
;      (= 0 (shell-command "fc-list | grep Inconsolata"))
;      "Inconsolata-14")))

;; the modeline
(line-number-mode t)                     ; show line numbers
(column-number-mode t)                   ; show column numbers
(global-linum-mode t)                    ; display line numbers in margin. emacs 23 only.
(when (fboundp size-indication-mode)
  (size-indication-mode t))              ; show file size (emacs 22+)
(display-time-mode -1)                   ; don't show the time
(ruler-mode -1)

(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (tooltip-mode -1)
  (mouse-wheel-mode t)
  (blink-cursor-mode -1)) ; stop cursor from blinking
  
;; highlight selection
(transient-mark-mode t)
  
;; Enable syntax highlighting for older Emacsen that have it off
(global-font-lock-mode t)

;; make "yes or no" prompts show "y or n" instead
(fset 'yes-or-no-p 'y-or-n-p)

(setq search-highlight t                 ; highlight when searching... 
  query-replace-highlight t)             ; ...and replacing

;;(iswitchb-mode 1)

;; completion in minibuffer
(icomplete-mode t)                       
(setq icomplete-prospects-height 2)      ; don't spam my minibuffer
(partial-completion-mode t)              ; be smart with completion

;; case insensitive completion
(setq completion-ignore-case t             
  read-file-name-completion-ignore-case t) ; ...filenames too

;; compilation
(setq compilation-window-height 12)
(setq compilation-finish-functions nil) ;; keep it open

;; mouse stuff
(setq
 mouse-1-click-in-non-selected-windows nil
 mouse-yank-at-point t)
(mouse-avoidance-mode 'none)

(setq-default indicate-empty-lines t)

;; do not show trailing ws by default, but whenever some buffer
;; changes its major mode, enable it if the buffer is visiting a file
(setq-default show-trailing-whitespace nil)
(add-hook 'after-change-major-mode-hook
          (lambda ()
            (when (buffer-file-name)
              (setq show-trailing-whitespace t))))


  
(provide 'customizations)
;; customizations.el ends here