;;; tex.el --- Some helpful Tex code
;;

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

(provide 'tex)
;; tex.el ends here