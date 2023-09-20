
(autoload 'cmake-mode "cmake-mode" "CMake Mode" t)

(add-to-list 'auto-mode-alist '("CMakeLists\\.txt\\'" . cmake-mode))
(add-to-list 'auto-mode-alist '("\\.cmake\\'" . cmake-mode))
     
(provide 'init-cmake)