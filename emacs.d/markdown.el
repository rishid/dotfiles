;; --------------------------------------------- [ Markdown Mode Startup ]
(defun my-markdown-startup ()
  (interactive)
  (longlines-mode t))

(add-hook 'markdown-mode-hook 'my-markdown-startup)

(provide 'markdown)