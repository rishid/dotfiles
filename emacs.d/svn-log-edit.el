(defun my-svn-log-edit-mode-startup ()
  (interactive)
  (filladapt-mode t)
  (show-paren-mode t)
  (flyspell-mode t))

(add-hook 'svn-log-edit-mode-hook 'my-svn-log-edit-mode-startup)

(provide 'svn-log-edit)
