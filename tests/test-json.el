;;; test-json.el --- Tests for json files              -*- lexical-binding: t; -*-

;; Copyright (C) 2016

;; Author:  <lompik@oriontabArch>
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

(describe
 "JSON tests"
 (before-each
  (setq bcup_savedir default-directory)
  (require 'x-path-walker)
  (require 'json-mode) )

 (after-each
  (setq  default-directory bcup_savedir))

 (it "should match line numbers in JSON files
"
     (find-file "tests/data/complex.json")
     (goto-char (random (point-max)))
     (x-path-walker-jump-path "[\"[tricky]\"][4][0]")
     (expect (line-number-at-pos) :to-equal 16)) )

(provide 'test-json)
;;; test-json.el ends here
