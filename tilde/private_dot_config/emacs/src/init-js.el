;;; js.el --- Some helpful Javascript helpers
;;

(autoload 'js2-mode "setup-js2-mode")
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.json$" . javascript-mode))

;(add-hook 'espresso-mode-hook 'start-programing-mode)

(provide 'init-js)
