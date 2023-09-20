;; Python stuff
(setq-default python-indent 4)
(defun custom-python-mode-hook ()

    ;; tab width 4
    (setq tab-width 4)
    (setq python-indent 4)
    )
(add-hook 'python-mode-hook 'custom-python-mode-hook)

;; show scons files in python mode
(add-to-list 'auto-mode-alist '("\\.scons$" . python-mode))
(add-to-list 'auto-mode-alist '("\/SConstruct$" . python-mode))
(add-to-list 'auto-mode-alist '("\/SConscript$" . python-mode))