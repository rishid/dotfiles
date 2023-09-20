;;; ansiterm.el --- Some helpful Ansi term code
;;

;; use AnsiTerm which does support colors or you can enable AnsiColor for the normal shell:
;; http://www.emacswiki.org/emacs/AnsiTerm
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(provide 'tex)
;; ansiterm.el ends here