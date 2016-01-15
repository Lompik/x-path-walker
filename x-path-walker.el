;;; x-path-walker.el --- Navigation feature for JSON/XML/HTML based on path (imenu like)  -*- lexical-binding: t; -*-

;; Copyright (C) 2015

;; Author:  <lompik@ArchOrion>
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(defvar x-path-walker-source-dir (concat (if load-file-name
                                             (file-name-directory load-file-name)
                                           default-directory)
                                         "xpathwalker"))

(defvar x-path-walker-objects-separators ".")

(defvar x-path-walker-command `(,(concat "PYTHONPATH=" x-path-walker-source-dir)
                                "python3"
                                "-m xpathwalker") )

(defvar x-path-walker-verbose nil)

(defun x-path-build-cmd-line (args)
  (mapconcat #'identity
             (append x-path-walker-command
                     (eval 'args))
             " "))

(defun x-path-run-py-script (args)
  (let ((cmd (x-path-build-cmd-line args)))
    (shell-command-to-string cmd)))

(defun helm-x-path-walker-init (file)
  (let ((cmd-line (x-path-build-cmd-line (list
                                          (if (bound-and-true-p x-path-walker-verbose)
                                              "-a"
                                            "")
                                          "-m"
                                          "JSON"
                                          file ))))
    (prog1
        (start-process-shell-command
         "x-path-walker" helm-buffer cmd-line)
      (set-process-sentinel
       (get-buffer-process helm-buffer)
       (lambda (_process event)
         (when (string= event "finished\n")
           (with-helm-window
             (setq mode-line-format
                   '(" " mode-line-buffer-identification " "
                     (:eval (format "L%s" (helm-candidate-number-at-point))) " "
                     (:eval (propertize
                             (format
                              "[%s process finished] "
                              "x-path-helper")
                             'face 'helm-grep-finish))))
             (force-mode-line-update))))))))

(defun x-path-get-mode ()
  (let ((mm (pcase major-mode
              (`json-mode "JSON")
              (`xml-mode "XML")
              (`nxml-mode "XML")
              (`html-mode "HTML")
              (`web-mode "XML")
              (code nil))))
    (unless (and (buffer-file-name) mm)
      (keyboard-quit))
    mm))

(defun x-path-walker-ask ()
  (interactive)
  (if (and (buffer-modified-p)
           (yes-or-no-p "Buffer will be linted. Do you want to save the current buffer (required)?"))
      (save-current-buffer)
    (if (buffer-modified-p)
        (keyboard-quit))))

(defun x-path-walker-jump-line (line)
  (let* ((mode (x-path-get-mode))
         (path (if (not (bound-and-true-p x-path-walker-verbose))
                   line
                 (if (or (string= mode "HTML")
                         (string= mode "XML"))
                     (car (split-string line " | "))
                   (if (and (string= mode "JSON") )
                       (car (cdr (split-string line " | ")))
                     ""))))
         (line (replace-regexp-in-string "\n$" ""
                                         (x-path-run-py-script `("-x"
                                                                 ,(shell-quote-argument path)
                                                                 "-m"
                                                                 ,mode
                                                                 ,(buffer-file-name) )))))
    (if (string= mode "JSON")
        (progn  (x-path-walker-ask)
                (erase-buffer)
                (shell-command-on-region (point-min) (point-max)
                                         (concat "python3 -m json.tool "
                                                 (buffer-file-name))
                                         (current-buffer))))
    (unless (or (string= "" line))
      (goto-line (string-to-number line))
      (recenter)
      (back-to-indentation))))

(defun helm-x-path-walker()
  (interactive)
  (let* ((mode (x-path-get-mode))
         (file (buffer-file-name))
         (cmd-line `(,(if (bound-and-true-p x-path-walker-verbose)
                          "-a"
                        "")
                     "-m"
                     ,mode
                     ,file ))
         (cands  (split-string (x-path-run-py-script cmd-line)"\n")))
    (setq helm-source-x-path-walker
          (helm-build-sync-source "PATH-WALKER"
            :keymap helm-map
            :candidates  cands
            :candidate-number-limit 500
            :action (helm-make-actions
                     "Jump to path" 'x-path-walker-jump-line)))
    (helm
     :sources 'helm-source-x-path-walker
     :prompt "Select Path:"
     :resume 'noresume
     :keymap helm-map
     :buffer "*helm path-walker*")))


(provide 'x-path-walker)
;;; x-path-walker.el ends here
