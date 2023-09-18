
(autoload 'go-mode "go-mode" "Go Mode" t)

(add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))

(provide 'init-go)
