(defun my-makefile-startup ()
  "Setup how I like editing makefiles (Allow for project access, etc."
  (interactive)
  (start-programing-mode)

  (local-set-key "\C-css" 'insert-script-seperator-line)
  (local-set-key "\C-csh" 'insert-script-section-header)
  (local-set-key "\C-csb" 'insert-script-big-header))

(add-hook 'makefile-mode-hook 'my-makefile-startup)

(provide 'makefile)