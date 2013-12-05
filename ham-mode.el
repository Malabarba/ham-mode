;;; ham-mode.el --- Html As Markdown. Transparently edit an html file using markdown.

;; Copyright (C) 2013 Artur Malabarba <bruce.connor.am@gmail.com>

;; Author: Artur Malabarba <bruce.connor.am@gmail.com>
;; URL: http://github.com/Bruce-Connor/ham-mode
;; Version: 1.0
;; Package-Requires: ((html-to-markdown "1.1"))
;; Keywords: convenience emulation wp
;; Prefix: ham
;; Separator: -

;;; Commentary:
;;
;; ;; ### Seamlessly edit an html file using markdown. ###
;; 
;; HTML as Markdown.
;; 
;; This package defines a major-mode, `ham-mode', which allows you to
;; edit HTML files exactly as if they were Markdown files. Activate it
;; while visiting an HTML file. The buffer will be converted to Markdown,
;; but the file will still be kept in HTML format behind the scenes.
;;  
;; Instructions
;; ------
;; 
;; To use this package, simply:
;; 
;; 1. Install it from Melpa (M-x `package-install' RET ham-mode) and the
;; `ham-mode' command will be autoloaded.
;;
;; 2. Activate it inside any HTML files you'd like to edit as Markdown.
;; You can manually invoke M-x `ham-mode', or add it to `auto-mode-alist'
;; so that it can load automatically.

;;; License:
;;
;; This file is NOT part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 

;;; Change Log:
;; 1.0 - 2013/12/05 - Created File.
;;; Code:

(defconst ham-mode-version "1.0" "Version of the ham-mode.el package.")
(defconst ham-mode-version-int 1 "Version of the ham-mode.el package, as an integer.")
(defun ham-bug-report ()
  "Opens github issues page in a web browser. Please send any bugs you find.
Please include your emacs and ham-mode versions."
  (interactive)
  (message "Your ham-version is: %s, and your emacs version is: %s.\nPlease include this in your report!"
           ham-mode-version emacs-version)
  (browse-url "https://github.com/Bruce-Connor/ham-mode/issues/new"))


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Here starts ham-mode
(defcustom ham-mode-markdown-command
  (list (or (executable-find "markdown")
            (executable-find "Markdown"))
        "--html4tags" 'file)
  "Command used to convert markdown contents into hmtl.

This variable is a list:
  First element is the full path to the markdown executable.
  Other elements are either the symbol 'file (replaced with the
  filename), or strings (arguments to the passed to the
  executable)."
  :type '(cons string
               (repeat (choice (const :tag "The file being edited." file)
                               (string :tag "String argument."))))
  :group 'html-to-markdown)
(put 'ham-mode-markdown-command 'risky-local-variable-p t)

(defun ham-mode--save-as-html ()
  "Take the current markdown buffer, and OVERWRITE its file with HTML.

This is meant to be used as an `after-save-hook', because it
assumes the buffer has already been saved.

The buffer contents won't change (will remain as markdown), but
the visited file will contain HTML code. This means the buffer
and file contents will not match (that's intended). As long as
this is an `after-save-hook', that will happen every time the
buffer is saved, and the file will remain an HTMLized version of
the current buffer."
  (interactive)
  (unless (file-executable-p (car ham-mode-markdown-command))
    (error "Can't find the markdown executable! Is it installed? See `ham-mode-markdown-command'"))
  (let ((file (buffer-file-name))
        output return)
    (unless file
      (error (substitute-command-keys "This buffer isn't visiting a file. \\[write-file] to save it.")))
    (setq output 
          (with-temp-buffer
            (setq return
                  (apply 'call-process
                         (car ham-mode-markdown-command)
                         nil t nil
                         (mapcar
                          (lambda (x) (if (eq x 'file) file x))
                          (cdr ham-mode-markdown-command))))
            (buffer-string)))
    (when (= return 0)
      (write-region output nil file nil t)
      output)))

;;;###autoload
(define-derived-mode ham-mode markdown-mode "Ham"
  "Html As Markdown. Transparently edit an html file using markdown.

When this mode is activated in an html file, the buffer is
converted to markdown and you may edit at will, but the file is
still saved as html behind the scenes. 

To have it activate automatically on html files, do something like:
  (add-to-list 'auto-mode-alist '(\".*\\\\.html\\\\'\" . ham-mode))

Initial conversion uses the `html-to-markdown-this-buffer'
command (handled entirely in elisp by this package :-D).

Subsequent conversions (after every save) are handled by the
markdown executable (which needs to be installed on your system).
See `ham-mode-markdown-command' and `ham-mode--save-as-html' on
how to customize this part."
  :group 'html-to-markdown
  (html-to-markdown-this-buffer)
  (set-buffer-modified-p nil)
  (add-hook 'after-save-hook 'ham-mode--save-as-html nil :local))

(provide 'ham-mode)
;;; ham-mode.el ends here.
