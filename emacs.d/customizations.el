;;; customizations.el --- Customization of Emacs UI
;;

(setq enable-local-variables :safe
      default-major-mode 'text-mode
      require-final-newline t
      default-tab-width 4
	  tab-width 4
      backward-delete-char-untabify 4
      truncate-partial-width-windows nil)
	  
;; default-fonts
;(set-face-attribute 'default nil :family "Inconsolata" :height 120)

;(set-default-font
;  (cond 
;    (djcb-win32-p
;      "-outline-Consolas-normal-r-normal-normal-14-97-96-96-c-*-iso8859-1")
;    ((and (not djcb-console-p) djcb-linux-p)
;      (= 0 (shell-command "fc-list | grep Inconsolata"))
;      "Inconsolata-14")))

(when (fboundp size-indication-mode)
  (size-indication-mode t))              ; show file size (emacs 22+)
(display-time-mode -1)                   ; don't show the time
(ruler-mode -1)

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

(autoload 'whitespace-mode           "whitespace"
      "Toggle whitespace visualization."        t)

;; do not show trailing ws by default, but whenever some buffer
;; changes its major mode, enable it if the buffer is visiting a file
(setq-default show-trailing-whitespace nil)
(add-hook 'after-change-major-mode-hook
          (lambda ()
            (when (buffer-file-name)
              (setq show-trailing-whitespace t))))


  
(provide 'customizations)
;; customizations.el ends here
