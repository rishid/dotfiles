;; -----------------------------------------------------------------------
;; Color Themes
;; -----------------------------------------------------------------------
(require 'color-theme)
;; Use color themes only in windowed modes.
(defun my-color-theme-frame-init (frame)
  (set-variable 'color-theme-is-global nil)
  (select-frame frame)
  (if window-system
      (progn (require 'color-theme-almost-monokai)
             (color-theme-almost-monokai))
	(progn (load-library "color-theme-library")
           (color-theme-tty-dark))))

(add-hook 'after-make-frame-functions 'my-color-theme-frame-init)

;; Must manually call `my-color-theme-frame-init' for the initial frame.
(cond ((selected-frame)
       (my-color-theme-frame-init (selected-frame))))

(provide 'init-color-theme)