;; Setup hippie-expand (we're going to have to make an eval-after-load
;; section later)
(defun hippie-expand-case-sensitive (arg)
  "Do case sensitive searching so we deal with gtk_xxx and GTK_YYY."
  (interactive "P")
  (let ((case-fold-search nil))
    (hippie-expand arg)))

(global-set-key "\M-/" 'hippie-expand-case-sensitive)
(global-set-key (kbd "M-SPC") 'hippie-expand-case-sensitive)
(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev
        try-complete-file-name-partially
        try-complete-file-name
        try-expand-all-abbrevs
        try-expand-list
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill))

;; Hippie expand: at times perhaps too hip
;(delete 'try-expand-line hippie-expand-try-functions-list)
;(delete 'try-expand-list hippie-expand-try-functions-list)
;(delete 'try-complete-file-name-partially hippie-expand-try-functions-list)
;(delete 'try-complete-file-name hippie-expand-try-functions-list)
;(setq hippie-expand-try-functions-list
;  '(yas/hippie-try-expand try-expand-all-abbrevs try-expand-dabbrev
;     try-expand-dabbrev-from-kill
;     try-complete-lisp-symbol-partially try-complete-lisp-symbol-partially
;     try-expand-dabbrev-all-buffers))

(provide 'init-hippie-expand)