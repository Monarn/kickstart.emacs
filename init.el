;; -*- lexical-binding: t; -*-

(defun start/org-babel-tangle-config ()
  "Automatically tangle our init.org config file and refresh `package-quickstart'.
Credit to Emacs From Scratch for this one!"
  (interactive)
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle)
      (package-quickstart-refresh))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'start/org-babel-tangle-config)))

(defun start/display-startup-time ()
  "Display Emacs startup time and number of garbage collections."
  (interactive)
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                    (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'start/display-startup-time)

(require 'use-package-ensure) ; Load use-package-always-ensure
(setq use-package-always-ensure t) ; Always ensures that a package is installed

(setq package-archives '(("melpa" . "https://melpa.org/packages/") ; Sets default package repositories
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/"))) ; For Eat Terminal

(setq package-quickstart t) ; For blazingly fast startup times, this line makes startup miles faster

(use-package async
  :defer t
  :custom
  (dired-async-mode t)
  (async-bytecomp-package-mode t)
  (async-bytecomp-allowed-packages '(all))
  (async-package-do-action t))

(use-package emacs
  :custom

  ;; Still needed for terminals
  (menu-bar-mode nil)         ; Disable the menu bar
  (scroll-bar-mode nil)       ; Disable the scroll bar
  (tool-bar-mode nil)         ; Disable the tool bar
  (global-visual-line-mode t)

  ;;(inhibit-startup-screen t)  ; Disable welcome screen

  (delete-selection-mode t)   ; Select text and delete it by typing.
  ;; (electric-indent-mode t)  ; Turn off the weird indenting that Emacs does by default.
  (electric-pair-mode t)      ; Turns on automatic parens pairing

  (blink-cursor-mode t)     ; Don't blink cursor
  (global-auto-revert-mode t) ; Automatically reload file and show changes if the file has changed
  ;; (use-short-answers t)   ; Since Emacs 29, `yes-or-no-p' will use `y-or-n-p'

  ;; (dired-kill-when-opening-new-dired-buffer t) ; Dired doesn't create new buffer
  ;; (dired-mouse-drag-files t) ; Enable Drag and Drop support in dired (Only works in X11)

  ;; (recentf-mode t) ; Enable recent file mode
  ;; (context-menu-mode t) ; Right-click menu
  ;; (savehist-mode t) ; Enables save history mode

  ;; (global-visual-line-mode t)           ; Enable line wrapping (NOTE: breaks vundo)
  (global-display-line-numbers-mode t)  ; Display line numbers
  (display-line-numbers-type 'relative) ; Relative line numbers
  (global-hl-line-mode t)               ; Highlight current line

  (native-comp-async-report-warnings-errors 'silent) ; Don't show native comp errors
  (warning-minimum-level :error) ; Only show errors in warnings buffer

  (mouse-wheel-progressive-speed nil) ; Disable progressive speed when scrolling
  (scroll-conservatively 10) ; Smooth scrolling
  (scroll-margin 8)

  (pixel-scroll-precision-mode t) ; Precise pixel scrolling. i.e. smooth scrolling (GUI only)
  ;; (pixel-scroll-precision-use-momentum nil)

  (indent-tabs-mode nil) ; Only use spaces for indentation
  (tab-width 4)
  (sgml-basic-offset 4) ; Set Html mode indentation to 4
  (c-ts-mode-indent-offset 4) ; Fix weird indentation in c-ts (C, C++)
  (go-ts-mode-indent-offset 4) ; Fix weird indentation in go-ts

  ;; (display-fill-column-indicator-column 80) ; Set line length indicator to 80 characters
  (whitespace-style '(face tabs tab-mark trailing))

  (make-backup-files nil) ; Stop creating ~ backup files
  (auto-save-default t) ; Stop creating # auto save files
  (delete-by-moving-to-trash t)
  :hook
  (prog-mode . hs-minor-mode) ; Enable folding hide/show globally
  ;; (prog-mode . display-fill-column-indicator-mode) ; Display line length indicator
  (prog-mode . whitespace-mode)
  :config
  ;; Move customization variables to a separate file and load it, avoid filling up init.el with unnecessary variables
  (setq custom-file (locate-user-emacs-file "custom-vars.el"))
  (load custom-file 'noerror 'nomessage)
  (add-to-list 'warning-suppress-types '(files lexical-binding))
  :bind (
         ([escape] . keyboard-escape-quit) ; Makes Escape quit prompts (Minibuffer Escape)
         ;; Zooming In/Out
         ("C-+" . text-scale-increase)
         ("C--" . text-scale-decrease)
         ("<C-wheel-up>" . text-scale-increase)
         ("<C-wheel-down>" . text-scale-decrease)))

(use-package evil
  :hook (after-init . evil-mode)
  :init
  (evil-mode)
  :config
  (evil-set-initial-state 'eat-mode 'insert) ; Set initial state in eat terminal to insert mode
  (setq evil-auto-indent nil)
  ;; (global-set-key [C-backspace] 'evil-delete-backward-word) ; Make C-backspace less aggressive
  ;; Center cursor when jumping with C-d, C-u.
  ;; (advice-add 'evil-scroll-down :after (lambda (&rest _) (recenter nil)))
  ;; (advice-add 'evil-scroll-up :after (lambda (&rest _) (recenter nil)))
  :custom
  (evil-want-keybinding nil)    ; Disable evil bindings in other modes (It's not consistent and not good)
  (evil-want-C-u-scroll t)      ; Set C-u to scroll up
  (evil-want-C-i-jump nil)      ; Disables C-i jump
  (evil-undo-system 'undo-redo) ; C-r to redo
  (evil-want-fine-undo t)
  (evil-respect-visual-line-mode nil) ; Move in wrap lines
  ;; Unmap keys in 'evil-maps. If not done, org-return-follows-link will not work
  :bind (:map evil-motion-state-map
              ("SPC" . nil)
              ("RET" . nil)
              ("TAB" . nil)))
(use-package evil-collection
  :after evil
  :config
  ;; Setting where to use evil-collection)
  (setq evil-collection-mode-list '(dired ibuffer magit corfu consult info (package-menu package) bookmark))
  (evil-collection-init))

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

(defun start/open-init-file ()
  "Open init.org configuration file."
  (interactive)
  (find-file "~/.config/emacs/init.org"))

(defun start/reload-config()
  "Reload Emacs config."
  (interactive)
  (load-file "~/.config/emacs/init.el"))

(use-package general
  :after (evil) ; <- evil
  :config
  (general-evil-setup) ; <- evil
  ;; Set up 'C-SPC' as the leader key
  (general-create-definer start/leader-keys
    :states '(normal insert visual motion emacs) ; <- evil
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC") ; Set global leader key so we can access our keybindings from any state

  (start/leader-keys
    "." '(find-file :wk "Find file")
    "," '(embark-act :wk "Embark act")
    "TAB" '(comment-line :wk "Comment lines")
    "c" '(ghostel :wk "Ghostel terminal")
    "g" '(magit-status :wk "Magit status")
    "q" '(flymake-show-buffer-diagnostics :wk "Flymake buffer diagnostic")
    ;; Projectile
    "p" '(projectile-command-map :wk "Projectile")
    "s p" '(projectile-discover-projects-in-search-path :wk "Search for projects"))

  (start/leader-keys
    "d" '(:ignore t :wk "Buffers & Dired")
    "d i" '(ibuffer :wk "Ibuffer")
    "d j" '(dired-jump :wk "Dired jump to current")
    "d k" '(kill-current-buffer :wk "Kill current buffer")

    "d n" '(next-buffer :wk "Next buffer")
    "d p" '(previous-buffer :wk "Previous buffer")
    "d r" '(revert-buffer :wk "Reload buffer")
    "d s" '(consult-buffer :wk "Switch buffer")
    "d v" '(dired :wk "Open dired"))

  (start/leader-keys
    "w" '(:ignore t :wk "Windows operations")
    "w r" '(evil-window-left :wk "Go to the window on the left")
    "w t" '(evil-window-down :wk "Go to the lower window")
    "w i" '(evil-window-up :wk "Go to the upper window")
    "w u" '(evil-window-right :wk "Go to the window on the right")
    "w v" '(split-window-vertically :wk "Split window vertically")
    "w h" '(split-window-horizontally :wk "Split window horizontally"))

  (start/leader-keys
    "e" '(:ignore t :wk "Languages")
    "e a" '(eglot-code-actions :wk "Eglot code actions")
    "e d" '(eldoc-doc-buffer :wk "Eldoc Buffer")
    "e e" '(eglot-reconnect :wk "Eglot Reconnect")
    "e f" '(eglot-format :wk "Eglot Format")
    "e i" '(xref-find-definitions :wk "Find definition")
    "e l" '(consult-flymake :wk "Consult Flymake")

    "e n" '(flymake-goto-next-error :wk "Flymake next error")
    "e p" '(flymake-goto-prev-error :wk "Flymake previous error")
    "e r" '(eglot-rename :wk "Eglot Rename")
    "e s" '(xref-find-references :wk "Find references")
    "e v" '(:ignore t :wk "Elisp")
    "e v b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e v r" '(eval-region :wk "Evaluate elisp in region"))

  (start/leader-keys
    "m" '(:ignore t :wk "Bookmarks & Registers")
    ;; Bookmarks
    "m a" '(bookmark-set :wk "Bookmark Set")
    "m b" '(bookmark-bmenu-list :wk "Bookmark bmenu list")
    "m c" '(consult-bookmark :wk "Consult Bookmark")
    "m d" '(bookmark-jump :wk "Bookmark Jump")
    "m r" '(bookmark-delete :wk "Bookmark Delete")
    "m R" '(bookmark-delete-all :wk "Bookmark Delete All")
    ;; Registers
    "m s" '(consult-register :wk "Consult register")
    "m k" '(jump-to-register :wk "Jump to register")
    "m e" '(point-to-register :wk "Point to register"))

  (start/leader-keys
    "r" '(:ignore t :wk "Reload & Packages") ; To get more help use C-h commands (describe variable, function, etc.)
    ;; Mason.el
    "r i" '(mason-install :wk "Mason install")
    "r m" '(mason-manager :wk "Mason manager")
    "r l" '(mason-update-all :wk "Mason update all")
    ;; Package-menu-mode
    "r p" '(list-packages :wk "List packages")
    "r c" '(package-menu-clear-filter :wk "Package clear filters")
    "r n" '(package-menu-filter-by-name :wk "Package filter by name")
    "r N" '(package-menu-filter-by-name-or-description :wk "Package filter by name or description")
    "r s" '(package-menu-filter-by-status :wk "Package filter by status")
    "r u" '(package-menu-filter-upgradable :wk "Package filter by upgradable")
    ;; Session and Configuration Management
    "r q" '(save-buffers-kill-emacs :wk "Quit Emacs and Daemon")
    "r r" '(start/reload-config :wk "Reload Emacs config"))

  (start/leader-keys
    "s" '(:ignore t :wk "Search")
    "s c" '(start/open-init-file :wk "Open init file")
    "s f" '(consult-fd :wk "Search files with fd")
    "s g" '(consult-ripgrep :wk "Search with ripgrep")
    "s i" '(consult-imenu :wk "Search Imenu buffer locations") ; This one is really cool
    "s l" '(consult-line :wk "Search line")
    "s r" '(consult-recent-file :wk "Search recent files"))

  (start/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t t" '(visual-line-mode :wk "Toggle truncated lines (wrap)")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")))

;; Fix general.el leader key not working instantly in messages buffer with evil mode
;;(use-package emacs
;;  :after (evil general)
;;  :ghook ('after-init-hook
;;          (lambda (&rest _)
;;            (when-let ((messages-buffer (get-buffer "*Messages*")))
;;              (with-current-buffer messages-buffer
;;                (evil-normalize-keymaps))))
;;          nil nil t))

(use-package doom-themes
  :custom
  ;; Global settings (defaults)
  (doom-themes-enable-bold t)   ; if nil, bold is universally disabled
  (doom-themes-enable-italic t) ; if nil, italics is universally disabled
  :config
  (load-theme 'doom-gruvbox t) ; We need to add t to trust this package
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(add-to-list 'default-frame-alist '(alpha-background . 90)) ; For all new frames henceforth

;; Transparency in terminal
(defun start/tui-enable-transparency ()
  "Enable background transparency when running Emacs in a terminal emulator."
  (unless (display-graphic-p (selected-frame))
    (set-face-background 'default "unspecified-bg" (selected-frame))))

(add-hook 'window-setup-hook 'start/tui-enable-transparency)

(use-package doom-modeline
  :custom
  (doom-modeline-height 25) ; Set modeline height
  :hook (after-init . doom-modeline-mode))

(use-package nerd-icons :defer t)

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package projectile
  :hook (after-init . projectile-mode)
  :config
  (projectile-mode)
  :custom
  ;; (projectile-auto-discover nil) ; Disable auto search for better startup times. Search with a keybind
  ;; (projectile-run-use-comint-mode t) ; Interactive run dialog when running projects inside emacs (like giving input)
  (projectile-switch-project-action #'projectile-dired) ; Open dired when switching to a project
  (projectile-project-search-path '("~/projects/" "~/work/" ("~/github" . 1)))) ; . 1 means only search the first subdirectory level for projects

(use-package eglot
  :ensure nil ; Don't install eglot because it's now built-in
  :hook ((c-mode c++-mode ; Autostart lsp servers for a given mode
                 lua-mode qml-mode haskell-mode) ; Lua-mode needs to be installed
         . eglot-ensure)
  :custom
  ;; Good default
  (eglot-events-buffer-size 0) ; No event buffers (LSP server logs)
  (eglot-autoshutdown t) ; Shutdown unused servers.
  (eglot-report-progress nil) ; Disable LSP server logs (Don't show lsp messages at the bottom, java)
  ;; Manual lsp servers
  :config
  (add-to-list 'eglot-server-programs
               '((qml-mode qml-ts-mode) . ("qmlls6"
                                           "-I" "/usr/lib/qt6/qml"
                                           "-I" "/usr/lib64/qt6/qml"
                                           "-I" "/usr/lib/qt/qml")
                 ))
  ;;(add-to-list 'eglot-server-programs
  ;;             `(lua-mode . ("PATH_TO_THE_LSP_FOLDER/bin/lua-language-server" "-lsp"))) ; Adds our lua lsp server to eglot's server list
  )

(use-package mason
  :hook (after-init . mason-ensure))

(use-package sideline-flymake
  :hook (flymake-mode . sideline-mode)
  :custom
  (sideline-flymake-display-mode 'line) ; Show errors on the current line
  (sideline-backends-right '(sideline-flymake)))

(use-package yasnippet
  :ensure t
  :hook (prog-mode . yas-minor-mode)
  (org-mode . yas-minor-mode))

(use-package yasnippet-snippets
  ;; :custom
  ;; (yas-key-syntaxes '("w_" "w_." "^ ")) ; Fixes prefixes that have characters like: !,@ etc.
  :hook (prog-mode . yas-minor-mode))

(defun start/corfu-yas-tab-handler ()
  "Prioritize corfu over yasnippet when yasnippet is active."
  (interactive)
  ;; There is no direct way to get if corfu is currently displayed so we watch the completion index
  (if (> corfu--index -1)
      (corfu-complete)
    (yas-next-field-or-maybe-expand)))
(use-package emacs
  :after (yasnippet corfu)
  :bind
  (:map yas-keymap
        ("TAB" . start/corfu-yas-tab-handler)))

(use-package aas
  :hook (org-mode . aas-activate-for-major-mode))

(use-package laas
  :hook (org-mode . laas-mode)
  :config
  (aas-set-snippets 'laas-mode
                                        ; normal mode

    "mk" '(yas "$$$1$$")
    "ml" '(yas "\\[\n\t$1\n\\]")
    :cond #'texmathp
    ";:" "test"
    ))

(setq treesit-language-source-alist
      '((bash "https://github.com/tree-sitter/tree-sitter-bash")
        (cmake "https://github.com/uyha/tree-sitter-cmake")
        (c "https://github.com/tree-sitter/tree-sitter-c")
        (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
        (css "https://github.com/tree-sitter/tree-sitter-css")
        (gdscript "https://github.com/PrestonKnopp/tree-sitter-gdscript")
        (go "https://github.com/tree-sitter/tree-sitter-go")
        (gomod "https://github.com/camdencheek/tree-sitter-go-mod")
        (html "https://github.com/tree-sitter/tree-sitter-html")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (json "https://github.com/tree-sitter/tree-sitter-json")
        (make "https://github.com/alemuller/tree-sitter-make")
        (markdown "https://github.com/ikatyang/tree-sitter-markdown")
        (python "https://github.com/tree-sitter/tree-sitter-python")
        (rust "https://github.com/tree-sitter/tree-sitter-rust")
        (toml "https://github.com/tree-sitter/tree-sitter-toml")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (vue "https://github.com/ikatyang/tree-sitter-vue")
        (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

(defun start/install-treesit-grammars ()
  "Install missing treesitter grammars."
  (interactive)
  (dolist (grammar treesit-language-source-alist)
    (let ((lang (car grammar)))
      (unless (treesit-language-available-p lang)
        (treesit-install-language-grammar lang)))))

;; Call this function to install missing grammars
(add-hook 'after-init-hook #'start/install-treesit-grammars)

;; Optionally, add any additional mode remappings not covered by defaults
(setq major-mode-remap-alist
      '((yaml-mode . yaml-ts-mode)
        (sh-mode . bash-ts-mode)
        (c-mode . c-ts-mode)
        (c++-mode . c++-ts-mode)
        (css-mode . css-ts-mode)
        (python-mode . python-ts-mode)
        (mhtml-mode . html-ts-mode)
        (javascript-mode . js-ts-mode)
        (js-json-mode . json-ts-mode)
        (typescript-mode . typescript-ts-mode)
        (conf-toml-mode . toml-ts-mode)
        (gdscript-mode . gdscript-ts-mode)))
(setq treesit-font-lock-level 3)

;; Or if there is no built in mode
(use-package cmake-ts-mode :ensure nil :mode ("CMakeLists\\.txt\\'" "\\.cmake\\'"))
(use-package go-mod-ts-mode :ensure nil :mode "\\.mod\\'")
(use-package lua-ts-mode :ensure nil :mode "\\.lua\\'")
(use-package rust-ts-mode :ensure nil :mode "\\.rs\\'")
(use-package typescript-ts-mode :ensure nil :mode "\\.ts\\'")
(use-package tsx-ts-mode :ensure nil :mode "\\.tsx\\'")
(use-package yaml-ts-mode :ensure nil :mode ("\\.yaml\\'" "\\.yml\\'"))
(use-package qml-mode
  :ensure t
  :mode "\\.qml\\'")

(use-package haskell-mode
  :ensure t)

(add-to-list 'load-path "~/.emacs.d/lisp")
(load-library "ampl-mode")

(use-package graphviz-dot-mode
  :ensure t)

(use-package org
  :ensure nil
  :custom
  (org-edit-src-content-indentation 0) ; Set src block automatic indent to 4 instead of 2.
  (org-return-follows-link t)   ; Sets RETURN key in org-mode to follow links
  (org-format-latex-options '(:scale 0.37))
  :hook
  (org-mode . org-indent-mode)) ; Indent text

(use-package org-fragtog
  :hook (org-mode . org-fragtog-mode))

(use-package toc-org
  :commands toc-org-enable
  :hook (org-mode . toc-org-mode))

(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode))

(setq org-publish-project-alist
      '(
       ("fac-org"
        :base-directory "~/Documents/fac/"
        :publishing-directory "~/Documents/fac/export/"
        :base-extension "org"
        :exclude "export"
        :html-head "<link rel=\"stylesheet\" href=\"/css/style.css\"></style>"
        :recursive t
        :htmlized-source t
        :publishing-function org-html-publish-to-html
        )
       ("fac-pdf"
        :base-directory "~/Documents/fac/"
        :publishing-directory "~/Documents/fac/export/"
        :base-extension "pdf"
        :exclude "export"
        :publishing-function org-publish-attachment
        :recursive t
        )
       ("fac" :components ("fac-pdf" "fac-org"))
       ))

(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
  '((python . t)
    (haskell . t)
    (dot . t)
    (gnuplot . t)
    (makefile . t)
    (C . t)
    (emacs-lisp . t)
    (shell . t)
    ))
  (setq org-babel-python-command "python3"
        org-confirm-babel-evaluate nil)
  )

(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown")
  :bind (:map markdown-mode-map
         ("C-c C-e" . markdown-do)))

(use-package ghostel
  :ensure t)

(use-package evil-ghostel
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))

(use-package exec-path-from-shell
  :hook (after-init . exec-path-from-shell-initialize))

;; (add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; (require 'start-multiFileExample)

;; (start/hello)

(use-package transient
  :defer t
  :config
  (define-key transient-map (kbd "<escape>") 'transient-quit-one)) ; Make escape quit magit prompts

(use-package magit
  :defer t
  :custom (magit-diff-refine-hunk (quote all)) ; Shows inline diff
  :config
  (setopt magit-format-file-function #'magit-format-file-nerd-icons)) ; Magit nerd icons

(use-package diff-hl
  :hook ((dired-mode         . diff-hl-dired-mode-unless-remote)
         (magit-post-refresh . diff-hl-magit-post-refresh)
         (after-init . global-diff-hl-mode)))

(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ; Enable auto completion
  (corfu-auto-prefix 2)          ; Minimum length of prefix for auto completion.
  (corfu-popupinfo-mode t)       ; Enable popup information
  (corfu-popupinfo-delay 0.5)    ; Lower popup info delay to 0.5 seconds from 2 seconds

  (corfu-separator ?\s)          ; Orderless field separator, Use M-SPC to enter separator
  ;; (corfu-quit-at-boundary nil)   ; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ; Use scroll margin

  (completion-ignore-case t)
  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  (corfu-preview-current nil) ; Don't insert completion without confirmation
  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :init
  (global-corfu-mode))

(use-package nerd-icons-corfu
  :after corfu
  :init (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package yasnippet-capf :defer t)

(defun start/setup-capfs ()
  "Configure completion backends."
  ;; Take care when adding Capfs to the list since each of the Capfs adds a small runtime cost.
  (let ((merge-backends (list
                         ;; Snippy-capf needed to be first, so characters like !,@, etc. Works with Snippy.
                         ;; When cape-capf-super combines multiple completion functions, it uses the prefix boundaries of the first capf.
                         ;; Other capf have different prefix boundaries.
                         ;;#'snippy-capf       ; Vscode Snippets
                         #'yasnippet-capf    ; Yasnippet snippets
                         ;; #'cape-abbrev       ; Complete abbreviation
                         #'cape-dabbrev      ; Complete word from current buffers
                         #'cape-keyword      ; Keyword completion
                         ;; #'cape-line         ; Complete entire line from current buffer
                         ;; #'cape-history      ; Complete from Eshell, Comint or minibuffer history
                         ;; #'cape-dict         ; Dictionary completion (Needs Dictionary file installed)
                         ;; #'cape-tex          ; Complete Unicode char from TeX command, e.g. \hbar
                         ;; #'cape-sgml         ; Complete Unicode char from SGML entity, e.g., &alpha
                         ;; #'cape-rfc1345      ; Complete Unicode char using RFC 1345 mnemonics
                         ))
        (separate-backends (list
                            #'cape-file ; Path completion
                            #'cape-elisp-block ; Complete elisp in Org or Markdown mode
                            )))

    ;; Remove keyword and snippet completion in git commits
    (when (bound-and-true-p git-commit-mode)
      (dolist (backend '(cape-keyword snippy-capf yasnippet-capf))
        (setq merge-backends (remq backend merge-backends))))

    ;; Add Elisp symbols only in Elisp modes
    (when (derived-mode-p 'emacs-lisp-mode 'ielm-mode)
      (setq merge-backends (cons #'cape-elisp-symbol merge-backends))) ; Emacs Lisp code (functions, variables)

    ;; Add Eglot to the front of the list if it's active
    (when (bound-and-true-p eglot--managed-mode)
      (setq merge-backends (append merge-backends (list #'eglot-completion-at-point))))

    ;; Create the super-capf and set it buffer-locally
    (setq-local completion-at-point-functions
                (append
                 separate-backends
                 (list (apply #'cape-capf-super merge-backends))))))
(use-package cape
  :after (corfu)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.

  ;; Separate function needed, because we use setq-local (everything is replaced)
  (add-hook 'eglot-managed-mode-hook #'start/setup-capfs)
  (add-hook 'prog-mode-hook #'start/setup-capfs)
  (add-hook 'text-mode-hook #'start/setup-capfs)
  (add-hook 'git-commit-setup-hook #'start/setup-capfs)) ; Fixes completion in magit commits

(use-package vertico
  :hook (after-init . vertico-mode)
  ;; Vim keybinds
  ;; :bind (:map vertico-map
  ;;            ("C-j" . vertico-next)
  ;;            ("C-k" . vertico-previous)
  ;;            ("C-u" . vertico-scroll-down)
  ;;            ("C-d" . vertico-scroll-up))
  :custom
  (vertico-cycle t)) ; Enable cycling for `vertico-next/previous'

(use-package marginalia
  :after vertico
  :config
  (marginalia-mode))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  :hook
  (marginalia-mode . nerd-icons-completion-marginalia-setup))

;; Configure directory extension.
(use-package vertico-directory
  :after vertico
  :ensure nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word)))

(use-package orderless
  :defer t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package embark :defer t)
(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package consult
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))

  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  ;; (consult-customize
  ;; consult-theme :preview-key '(:debounce 0.2 any)
  ;; consult-ripgrep consult-git-grep consult-grep
  ;; consult-bookmark consult-recent-file consult-xref
  ;; consult--source-bookmark consult--source-file-register
  ;; consult--source-recent-file consult--source-project-recent-file
  ;; :preview-key "M-."
  ;; :preview-key '(:debounce 0.4 any))

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
   ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
   ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
   ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
   ;;;; 4. projectile.el (projectile-project-root)
  (autoload 'projectile-project-root "projectile")
  (setq consult-project-function (lambda (_) (projectile-project-root)))
   ;;;; 5. No project support
  ;; (setq consult-project-function nil)
  )

(use-package helpful
  :bind
  ;; Note that the built-in `describe-function' includes both functions
  ;; and macros. `helpful-function' is functions only, so we provide
  ;; `helpful-callable' as a drop-in replacement.
  ("C-h f" . helpful-callable)
  ("C-h v" . helpful-variable)
  ("C-h k" . helpful-key)
  ("C-h x" . helpful-command))

(use-package diminish :defer t)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package hl-todo
  :hook
  ((prog-mode yaml-ts-mode) . hl-todo-mode)
  :config
  ;; From doom emacs
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        '(;; For reminders to change or add something at a later date.
          ("TODO" warning bold)
          ;; For code (or code paths) that are broken, unimplemented, or slow,
          ;; and may become bigger problems later.
          ("FIXME" error bold)
          ;; For code that needs to be revisited later, either to upstream it,
          ;; improve it, or address non-critical issues.
          ("REVIEW" font-lock-keyword-face bold)
          ;; For code smells where questionable practices are used
          ;; intentionally, and/or is likely to break in a future update.
          ("HACK" font-lock-constant-face bold)
          ;; For sections of code that just gotta go, and will be gone soon.
          ;; Specifically, this means the code is deprecated, not necessarily
          ;; the feature it enables.
          ("DEPRECATED" font-lock-doc-face bold)
          ;; Extra keywords commonly found in the wild, whose meaning may vary
          ;; from project to project.
          ("NOTE" success bold)
          ("BUG" error bold)
          ("XXX" font-lock-constant-face bold))))

(use-package indent-guide
  :hook
  (prog-mode . indent-guide-mode)
  :config
  (setq indent-guide-char "│")) ; Set the character used for the indent guide.

(use-package which-key
  :ensure nil ; Don't install which-key because it's now built-in
  :hook (after-init . which-key-mode)
  :diminish
  :custom
  (which-key-side-window-location 'bottom)
  (which-key-sort-order #'which-key-key-order-alpha) ; Same as default, except single characters are sorted alphabetically
  (which-key-sort-uppercase-first nil)
  (which-key-add-column-padding 1) ; Number of spaces to add to the left of each column
  (which-key-min-display-lines 6)  ; Increase the minimum lines to display because the default is only 1
  (which-key-idle-delay 0.3)       ; Set the time delay (in seconds) for the which-key popup to appear
  (which-key-allow-imprecise-window-fit nil)) ; Fixes which-key window slipping out in Emacs Daemon

(use-package ws-butler
  :hook (after-init . ws-butler-global-mode))

(setq org-agenda-files '("~/org/todo.org"))

(defun my/change-dashboard-title (title)
  (setq dashboard-banner-logo-title title))

(defun my/get-hour ()
  (string-to-number (format-time-string "%H" (current-time) "Europe/Paris")))


(defun my/change-dashboard-depends-time ()
  (let ((time (my/get-hour)))
    (cond ((and (< time 18) (>= time 6)) (my/change-dashboard-title "Bonjour Romann"))
          ((and (>= time 18) (<= time 23)) (my/change-dashboard-title "Bonsoir Romann"))
          (t (my/change-dashboard-title "Va dormir bâtard"))
          )))

(advice-add 'dashboard-open :before (lambda (&rest _) (my/change-dashboard-depends-time)))

;; use-package with package.el:
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook))

(setq initial-buffer-choice 'dashboard-open)

(setq dashboard-banner-logo-title "Bonjour Romann")
(setq dashboard-navigation-cycle t)
(setq dashboard-startup-banner "/home/romann/.config/emacs/startup.jpg")
(setq dashboard-week-agenda t)
