;; ------------------------------------------------- [ flymake-ruby-init ]
(defun flymake-ruby-init ()
  "Stolen from http://www.emacswiki.org/cgi-bin/emacs-en/FlymakeRuby"
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
     (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (list "ruby" (list "-c" local-file))))

;; ------------------------------------------------ [ setup-ruby-flymake ]
(defun setup-ruby-flymake ()
  "Also stolen from http://www.emacswiki.org/cgi-bin/emacs-en/FlymakeRuby"
  (require 'flymake)
  (if (not (null buffer-file-name))
      (flymake-mode)))

;; ------------------------------------------------------ [ Ruby startup ]
(defun my-ruby-startup ()
  "Setup Ruby."
  (interactive)
  (local-set-key '[f4] 'rubydb)

  (my-start-scripting-mode "rb" "#!/home/eglaysher/bin/ruby")

  ;; Ruby uses flymake for the win.
  (setup-ruby-flymake)

  (setq ri-ruby-script
        (expand-file-name "~/.elliot-unix/bin/ri-emacs.rb"))
  (autoload 'ri "ri-ruby.el" nil t))

(add-hook 'ruby-mode-hook 'my-ruby-startup)

(setq interpreter-mode-alist
      (append '(("ruby" . ruby-mode))
              interpreter-mode-alist))

(provide 'ruby)