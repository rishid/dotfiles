;;; perl.el --- Some helpful Perl code
;;
;; Part of the Emacs Starter Kit

(defalias 'perl-mode 'cperl-mode) ; cperl mode is what we want

(add-hook 'cperl-mode-hook
  (lambda()
    (eval-when-compile (require 'cperl-mode))
    (abbrev-mode -1)                  ; turn-off the annoying elecric crap
    (setq 
      cperl-hairy t                   ; parse hairy perl constructs
      cperl-indent-level 4            ; indent with 4 positions
      cperl-invalid-face nil          ; don't show stupid underlines
      cperl-electric-keywords t       ; complete keywords
      cperl-tab-always-indent t
      cperl-indent-left-aligned-comments t
      cperl-auto-newline nil
      cperl-close-paren-offset -4      
      cperl-indent-parens-as-block t
      cperl-continued-statement-offset 4
      cperl-indent-subs-specially nil
      cperl-invalid-face 'underline)
	(my-start-scripting-mode "pl" "#!/usr/bin/perl")))    

(custom-set-faces
  '(cperl-invalid-face default))
 
(eval-after-load 'cperl-mode
  '(progn
     (define-key cperl-mode-map (kbd "RET") 'reindent-then-newline-and-indent)
     (define-key cperl-mode-map (kbd "C-M-h") 'backward-kill-word)))

(global-set-key (kbd "C-h P") 'perldoc)

(add-to-list 'auto-mode-alist '("\\.p[lm]$" . cperl-mode))
(add-to-list 'auto-mode-alist '("\\.pod$" . pod-mode))
(add-to-list 'auto-mode-alist '("\\.tt$" . tt-mode))

;; TODO: flymake
;; TODO: electric bugaloo 

(provide 'perl)
;; perl.el ends here