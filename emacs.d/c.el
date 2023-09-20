;;; c.el --- Some helpful C code
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

  (add-hook 'before-save-hook
    'delete-trailing-whitespace nil t)
 
  (setq 
    compilation-scroll-output 'first-error  ; scroll until first error
    compilation-read-command nil            ; don't need enter
    compilation-window-height 12)           ; keep it readable

  (setq
    c-basic-offset 2                        ; linux kernel style
    c-hungry-delete-key t)                  ; eat as much as possible
  
  ;; guess the identation of the current file, and use
  ;; that instead of my own settings
  (when  (require-soft 'dtrt-indent) (dtrt-indent-mode t))

  (when (not (string-match "/usr/src/linux" 
               (expand-file-name default-directory)))
    (when (require-soft 'gtags) 
      (gtags-mode t)
      (djcb-gtags-create-or-update)))  
  (when (require-soft 'doxymacs)
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

(provide 'c)
;; c.el ends here