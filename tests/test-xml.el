;;; test-xml.el --- Tests for xml files              -*- lexical-binding: t; -*-

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
 "xml tests"
 (before-each
  (require 'x-path-walker))

 (it "should match line numbers in XML files"
     (find-file "tests/data/complex.xml")
     (goto-char (random (point-max)))
     (x-path-walker-jump-path "/league/scoreboard/matchups/matchup[1]/teams/team[1]/team_logos/team_logo/url | ")
     (message (format "%s" x-path-walker-source-dir))
     (expect (line-number-at-pos) :to-equal 46)) )

(provide 'test-xml)
;;; test-xml.el ends here
