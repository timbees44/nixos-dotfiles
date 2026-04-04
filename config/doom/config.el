;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Mail identity
(defun tim/mail-address-from-msmtp-config ()
  "Read the default sender address from the local msmtp config."
  (let ((msmtp-config (expand-file-name "~/.config/msmtp/config")))
    (when (file-readable-p msmtp-config)
      (with-temp-buffer
        (insert-file-contents msmtp-config)
        (goto-char (point-min))
        (when (re-search-forward "^from[[:space:]]+\\(.+\\)$" nil t)
          (string-trim (match-string 1)))))))

(setq user-mail-address (or (tim/mail-address-from-msmtp-config) user-mail-address))

;; Appearance
(setq doom-font (font-spec :family "JetBrainsMonoNL NF" :size 12))

(setq doom-theme 'doom-gruvbox)
(add-to-list 'default-frame-alist '(alpha . 90))

(setq display-line-numbers-type `relative)

;; Cross-platform file lookup for `M-x locate` without relying on BSD/GNU
;; locate compatibility.
(defvar tn/locate-search-root (expand-file-name "~")
  "Root directory searched by the custom `locate' command.")

(defun tn/locate-make-command-line (search-string)
  "Build a cross-platform command line for `locate' using fd or find."
  (cond
   ((executable-find "fd")
    (list (executable-find "fd")
          "--absolute-path"
          "--color" "never"
          "--type" "f"
          "--hidden"
          "--follow"
          search-string
          tn/locate-search-root))
   ((executable-find "find")
    (list (executable-find "find")
          tn/locate-search-root
          "(" "-type" "f" "-o" "-type" "l" ")"
          "-iname" (format "*%s*" search-string)))
   (t
    (error "Neither fd nor find is available for locate"))))

(setq locate-make-command-line #'tn/locate-make-command-line)

;; Org
(setq org-directory "~/Documents/org/")
(setq org-roam-directory (file-truename "~/Documents/org/roam"))
(after! org-roam
  (org-roam-db-autosync-mode))

;; Org Babel
(setq org-babel-python-command "python3")

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python  . t)
   (shell   . t)
   (C       . t)
   (verilog . t)
   (asm     . t)
   (lua     . t)))

;; Org editing
(after! org
  (setq-default fill-column 80))

;; Dynamic visual wrapping for prose buffers
(setq word-wrap-by-category t
      truncate-partial-width-windows nil)

(defvar tn/reflow-layout-idle-timer nil
  "Idle timer used to defer wrap/terminal reflow until layout settles.")

(defconst tn/layout-reflow-scale-functions
  '(text-scale-adjust text-scale-increase text-scale-decrease
    text-scale-set text-scale-mode)
  "Commands that should trigger deferred layout reflow.")

(defun tn/reflow-wrapped-windows (&optional frame)
  "Refresh visual wrapping in visible windows on FRAME.
This keeps screen-line wrapping in sync after window resizes."
  (dolist (window (window-list (or frame (selected-frame)) 'no-minibuf))
    (with-current-buffer (window-buffer window)
      (when (bound-and-true-p visual-line-mode)
        (force-window-update window)))))

(defun tn/run-deferred-layout-reflow ()
  "Reflow wrapped prose and AI terminal windows after layout settles."
  (setq tn/reflow-layout-idle-timer nil)
  (dolist (frame (visible-frame-list))
    (tn/reflow-wrapped-windows frame))
  (when (fboundp 'tn/reflow-ai-code-terminal-windows)
    (tn/reflow-ai-code-terminal-windows)))

(defun tn/schedule-layout-reflow (&rest _)
  "Queue a reflow pass after resize or text-scale changes settle."
  (when tn/reflow-layout-idle-timer
    (cancel-timer tn/reflow-layout-idle-timer))
  (setq tn/reflow-layout-idle-timer
        (run-with-idle-timer 0 nil #'tn/run-deferred-layout-reflow)))

(defun tn/enable-dynamic-visual-wrap ()
  "Enable dynamically reflowing visual line wrapping in the current buffer."
  (visual-line-mode 1)
  (setq-local truncate-lines nil))

(add-hook 'text-mode-hook #'tn/enable-dynamic-visual-wrap)
(add-hook 'window-size-change-functions #'tn/schedule-layout-reflow)
(dolist (fn tn/layout-reflow-scale-functions)
  (advice-add fn :after #'tn/schedule-layout-reflow))

;; Org links
(org-link-set-parameters
 "proj"
 :follow (lambda (path)
           (find-file (expand-file-name path "~/projects/")))
 :export (lambda (path desc format)
           (format "file:%s" (expand-file-name path "~/projects/"))))

;; macOS frame styling
(when (featurep 'ns)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark)))
(add-to-list 'default-frame-alist '(internal-border-width . 10))
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; PDF
(use-package pdf-view
  :hook (pdf-tools-enabled . pdf-view-midnight-minor-mode)
  :hook (pdf-tools-enabled . hide-mode-line-mode)
  :config
  (setq pdf-view-midnight-colors '("#ABB2BF" . "#282C35")))

;; mu4e load path
(when (featurep 'ns)
  (setq mu4e-mu-binary "/opt/homebrew/bin/mu"
        mu4e-maildir "~/.mail")
  (dolist (dir '("/opt/homebrew/share/emacs/site-lisp/mu/mu4e"
                 "/opt/homebrew/opt/mu/share/emacs/site-lisp/mu4e"
                 "/usr/local/share/emacs/site-lisp/mu/mu4e"
                 "/usr/local/opt/mu/share/emacs/site-lisp/mu4e"))
    (when (file-directory-p dir)
      (add-to-list 'load-path dir))))

;; mu4e
(after! mu4e
  (let ((mail-address (tim/mail-address-from-msmtp-config)))
    (setq mu4e-maildir "~/.mail"
          mu4e-user-mail-address-list (when mail-address (list mail-address))
        mu4e-get-mail-command
        "/etc/profiles/per-user/tim/bin/mbsync -c ~/.config/isync/mbsyncrc gmail"
        mu4e-update-interval 300
        sendmail-program
        (or (executable-find "msmtp")
            "/etc/profiles/per-user/tim/bin/msmtp")
        message-send-mail-function #'message-send-mail-with-sendmail
        message-sendmail-envelope-from 'header
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments
        (list "--read-envelope-from"
              "--read-recipients"
              (concat "--file=" (expand-file-name "~/.config/msmtp/config")))
        mu4e-drafts-folder "/gmail/[Gmail]/Drafts"
        mu4e-sent-folder "/gmail/[Gmail]/Sent Mail"
        mu4e-trash-folder "/gmail/[Gmail]/Trash"
        mu4e-refile-folder "/gmail/[Gmail]/All Mail")))

;; Elfeed
(setq elfeed-db-directory "~/.elfeed"
      elfeed-enclosure-default-dir "~/Downloads/elfeed/"
      elfeed-search-filter "@1-month-ago"
      elfeed-use-curl t)

(defun tn/elfeed-configured-feed-urls ()
  "Return the configured Elfeed feed URLs from `elfeed-feeds'."
  (mapcar (lambda (feed)
            (if (listp feed) (car feed) feed))
          elfeed-feeds))

(defun tn/elfeed-prune-removed-feeds (&rest _)
  "Remove database entries for feeds no longer present in `elfeed.org'."
  (when (featurep 'elfeed-org)
    (rmh-elfeed-org-process rmh-elfeed-org-files rmh-elfeed-org-tree-id))
  (elfeed-db-load)
  (let* ((configured-feeds (tn/elfeed-configured-feed-urls))
         (configured-table (make-hash-table :test 'equal))
         stale-entry-ids
         stale-feed-ids)
    (dolist (feed-url configured-feeds)
      (puthash feed-url t configured-table))
    (with-elfeed-db-visit (entry _feed)
      (unless (gethash (elfeed-entry-feed-id entry) configured-table)
        (push (elfeed-entry-id entry) stale-entry-ids)))
    (maphash (lambda (feed-id _feed)
               (unless (gethash feed-id configured-table)
                 (push feed-id stale-feed-ids)))
             elfeed-db-feeds)
    (dolist (entry-id stale-entry-ids)
      (avl-tree-delete elfeed-db-index entry-id)
      (remhash entry-id elfeed-db-entries))
    (dolist (feed-id stale-feed-ids)
      (remhash feed-id elfeed-db-feeds))
    (when (or stale-entry-ids stale-feed-ids)
      (elfeed-db-gc)
      (elfeed-db-save)
      (message "Elfeed pruned %d stale entries across %d removed feeds"
               (length stale-entry-ids)
               (length stale-feed-ids)))))

(use-package! elfeed-org
  :after elfeed
  :config
  (setq rmh-elfeed-org-files (list (expand-file-name "elfeed.org" doom-user-dir)))
  (elfeed-org)
  (advice-add #'elfeed :before #'tn/elfeed-prune-removed-feeds))

;; AI coding
(use-package! ai-code
  :defer t
  :init
  (map! :leader
        (:prefix ("c a" . "ai-code")
         :desc "AI Code menu" "a" #'ai-code-menu
         :desc "Start AI session" "s" #'ai-code-cli-start
         :desc "Jump to AI session" "z" #'ai-code-cli-switch-to-buffer-or-hide
         :desc "Ask AI" "q" #'ai-code-ask-question
         :desc "Change code" "c" #'ai-code-code-change
         :desc "Open prompt file" "p" #'ai-code-open-prompt-file))
  :config
  (defun tn/ai-code-session-vterm-window-p (window)
    "Return non-nil when WINDOW is an AI session using `vterm'."
    (with-current-buffer (window-buffer window)
      (when (or (and (fboundp 'ai-code-backends-infra--session-buffer-p)
                     (ai-code-backends-infra--session-buffer-p (current-buffer)))
                (bound-and-true-p ai-code-backends-infra--session-terminal-backend))
        (derived-mode-p 'vterm-mode))))
  (defun tn/reflow-ai-code-terminal-windows (&optional _)
    "Refresh visible AI terminal windows after layout or scale changes."
    (when (featurep 'ai-code-backends-infra)
      (walk-windows
       (lambda (window)
         (when (tn/ai-code-session-vterm-window-p window)
           (with-current-buffer (window-buffer window)
             ;; Reset cached width so ai-code's reflow guard does not suppress
             ;; a resize triggered by zoom or a frame/window size change.
             (set-window-parameter window 'ai-code-backends-infra-cached-width nil)
             (when-let ((process (get-buffer-process (current-buffer))))
               ;; Use vterm's own resize handler so ai-code's backend-specific
               ;; reflow filter remains in the path.
               (cond
                ((fboundp 'vterm--window-adjust-process-window-size)
                 (vterm--window-adjust-process-window-size process (list window)))
                ((fboundp 'window--adjust-process-windows)
                 (window--adjust-process-windows)))))))
       'no-minibuf
       'visible)))
  (setq ai-code-backends-infra-terminal-backend 'vterm)
  (ai-code-set-backend 'codex)
  (setq ai-code-auto-test-type 'ask-me)
  ;; Let vterm buffers reflow to the active window width when frames move
  ;; between displays. The suppression can leave stale wraps otherwise.
  (when (eq ai-code-backends-infra-terminal-backend 'vterm)
    (setq ai-code-backends-infra-prevent-reflow-glitch nil))
  (global-set-key (kbd "C-c a") #'ai-code-menu)
  (ai-code-prompt-filepath-completion-mode 1)
  (with-eval-after-load 'evil
    (ai-code-backends-infra-evil-setup))
  (with-eval-after-load 'magit
    (ai-code-magit-setup-transients)))
