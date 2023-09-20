;;; org.el --- Some helpful Org mode mode
;;

(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(setq org-log-done t)

(provide 'org)
;; org.el ends here