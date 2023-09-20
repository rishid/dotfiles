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

;; ----------------------------------------------------------- [ doxygen ]
;; Disable doxymacs prompts
;(defadvice doxymacs-insert-function-comment (around no-prompt activate compile)
;  "Prevents tempo from prompting during doxymacs template insertion"
;  (let ((tempo-interactive nil)) ad-do-it))

;(defadvice doxymacs-insert-file-comment  (around no-prompt activate compile)
;  "Prevents tempo from prompting during doxymacs template insertion"
;  (let ((tempo-interactive nil)) ad-do-it))

(provide 'init-doxymacs)