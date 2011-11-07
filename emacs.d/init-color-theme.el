;;; init-color-theme.el --- Define some custom functions
;;

;; use color theme...
;(when (require 'color-theme)  
;(eval-after-load "color-theme"
;  '(progn
;     (color-theme-initialize)
;     (color-theme-almost-monokai)))) 
     
(autoload 'color-theme-almost-monokai "color-theme-almost-monokai" nil t)
(setq color-theme-is-global nil)

;; this is for normal startup
(when (eq (window-system) 'x)
  (color-theme-almost-monokai))

;; this is for creating new emacsclient frames
(add-hook
 'after-make-frame-functions
 (lambda (frame)
   (when (eq (window-system frame) 'x)
     (select-frame frame)
     (color-theme-almost-monokai))))
     
(provide 'init-color-theme)
;;; init-color-theme.el ends here
