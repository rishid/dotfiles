;; Python stuff

(defun my-python-startup ()
  "Setup Python style."
  (interactive)
  (local-set-key '[f4] 'pdb)
  (setq tab-width 4)
  (setq indent-tabs-mode nil)  ; Autoconvert tabs to spaces
  (setq python-indent 4)
  (setq python-continuation-offset 2)
  (setq py-smart-indentation nil)
  (my-start-scripting-mode "py" "#!/usr/bin/python"))

(add-hook 'python-mode-hook 'my-python-startup)

;(add-to-list 'interpreter-mode-alist '("python" . python))

(autoload 'python-mode "python" "Python Mode." t)

;; show scons files in python mode
(add-to-list 'auto-mode-alist '("\\.scons$" . python))
(add-to-list 'auto-mode-alist '("SCons\\(cript\\|truct\\)" . python))

(provide 'init-python)
