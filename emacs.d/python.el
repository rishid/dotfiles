;; Python stuff

(defun my-python-startup ()
  "Setup Python style."
  (interactive)
  (local-set-key '[f4] 'pdb)
  (setq tab-width 2)
  (setq indent-tabs-mode nil)  ; Autoconvert tabs to spaces
  (setq python-indent 2)
  (setq python-continuation-offset 2)
  (setq py-smart-indentation nil)
  (my-start-scripting-mode "py" "#!/usr/bin/python"))

(add-hook 'python-mode-hook 'my-python-startup)

(add-to-list 'interpreter-mode-alist '("python" . python-mode))
 
;; show scons files in python mode
(add-to-list 'auto-mode-alist '("\\.scons$" . python-mode))
(add-to-list 'auto-mode-alist '("SCons\\(cript\\|truct\\)" . python-mode))

(provide 'python)