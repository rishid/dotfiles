;;; c.el --- Some helpful C code
;; common c / c-mode / c++-mode

;; ------------------------------------------- [ my-common-c-ish-startup ]
(defconst djcb-c-style '((c-tab-always-indent . t)))

(defun my-common-c-ish-startup ()
  (interactive)
  (start-programing-mode)
  
  (c-add-style "djcb" djcb-c-style)  
  (c-set-style "ellemtel" djcb-c-style)

  ;; Load and start up filladapt
  (require 'filladapt)
  (c-setup-filladapt)
  (filladapt-mode)

  (require 'whitespace)
  (set (make-local-variable 'whitespace-style) '(lines-tail))
  (whitespace-mode t)
  
  (font-lock-add-keywords nil 
    '(("\\<\\(__FUNCTION__\\|__PRETTY_FUNCTION__\\|__LINE__\\)" 
        1 font-lock-preprocessor-face prepend)))
		
  (setq 
    compilation-scroll-output 'first-error  ; scroll until first error
    compilation-read-command nil            ; don't need enter
    compilation-window-height 12)           ; keep it readable
	
  (local-set-key (kbd "<M-up>")   'previous-error) 
  (local-set-key (kbd "<M-down>") 'next-error)
  (local-set-key (kbd "C-c i")    'djcb-include-guards)  
  (local-set-key (kbd "C-c o")    'ff-find-other-file)

  (setq
    c-basic-offset 2                        ; linux kernel style
    c-hungry-delete-key t)                  ; eat as much as possible
	
  (local-set-key "\C-o" 'ff-get-other-file)
  
  ;; guess the identation of the current file, and use
  ;; that instead of my own settings
  (when (require-soft 'dtrt-indent) (dtrt-indent-mode t))
  
  (when (require-soft 'doxymacs)
    (doxymacs-mode t)
    (doxymacs-font-lock))
	
  ;; warn when lines are > 80 characters (in c-mode)
  (font-lock-add-keywords 'c-mode '(("^[^\n]\\{80\\}\\(.*\\)$"
                                      1 font-lock-warning-face prepend))))

(add-hook 'c-mode-common-hook 'my-common-c-ish-startup)

;; --------------------------------------------------------- [ C startup ]
(defun my-c-startup ()
  "Change C C++ and Obj-C indents."
  (interactive)

  (local-set-key "\C-css" 'insert-c-seperator-line)
  (local-set-key "\C-csh" 'insert-c-section-header))

(add-hook 'c-mode-hook 'my-c-startup)

;; ------------------------------------------------------- [ C++ startup ]
(defun my-c++-startup ()
  (interactive)

  ;; Load and start up doxymacs when in C++ mode
  (require 'cc-vars)

  ;; Now that doxymacs is loaded, we set up skeletons for hpp files.
  ;(my-start-autoinsert)

  (local-set-key "\C-css" 'insert-c++-seperator-line)
  (local-set-key "\C-csh" 'insert-c++-section-header)
  (local-set-key "\C-csb" 'insert-c++-big-header)
	
  ;; warn when lines are > 100 characters (in c++-mode)
  (font-lock-add-keywords 'c++-mode  '(("^[^\n]\\{100\\}\\(.*\\)$"
                                         1 font-lock-warning-face prepend)))
)

(add-hook 'c++-mode-hook 'my-c++-startup)

(provide 'c)