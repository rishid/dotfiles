;; ------------------------------------------------- [ Text Mode Startup ]
(defun my-textmode-startup ()
  (interactive)
  (turn-on-filladapt-mode)
  (flyspell-mode t)
  (local-set-key "\C-css" 'insert-text-seperator-line))

(add-hook 'text-mode-hook 'my-textmode-startup)

(provide 'text)