(autoload 'doxymacs-mode "doxymacs"
  ;; All of the following text shows up in the "mode help" (C-h m)
  "Minor mode for using/creating Doxygen documentation.
To submit a problem report, request a feature or get support, please
visit doxymacs' homepage at http://doxymacs.sourceforge.net/.

To see what version of doxymacs you are running, enter
`\\[doxymacs-version]'.

In order for `doxymacs-lookup' to work you will need to customise the
variable `doxymacs-doxygen-dirs'.

Key bindings:
\\{doxymacs-mode-map}" t)

(am-add-hooks
 `(c-mode-common-hook php-mode-hook)
 (lambda ()
   (doxymacs-mode 1)
   (doxymacs-font-lock)))

(defun doxymacs-settings ()
  "Settings for `doxymacs'.")

(eval-after-load "doxymacs"
  `(doxymacs-settings))

(provide 'doxymacs-settings)