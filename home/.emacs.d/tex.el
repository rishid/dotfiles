;;; tex.el --- Some helpful Tex code
;;

;; TeX/LaTex

(defun my-LaTeX-startup ()
  "Change the default LaTeX environment."
  (interactive)
  ;; We want to automatically wrap paragraphs in LaTeX mode...
  (filladapt-mode)
  (setq
    TeX-brace-indent-level 0 ;; don't screw up \index
    LaTeX-item-ident       2
    TeX-parse-self         t ; Enable parse on load.
    TeX-auto-save          t)) ; Enable parse on save.

(add-hook 'tex-mode-hook 'my-LaTeX-startup)
(add-hook 'LaTeX-mode-hook 'my-LaTeX-startup)   ;; AUCTex latex mode
(add-hook 'latex-mode-hook 'my-LaTeX-startup)   ;; Emacs latex mode

(provide 'tex)
;; tex.el ends here