# encoding: utf-8

# Gembuild: create Arch Linux PKGBUILDs for ruby gems.
# Copyright (C) 2015  Mario Finelli <mario@finel.li>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module Gembuild
  # Exception raised when rubygems.org returns a 404 error.
  class GemNotFoundError < StandardError; end

  # Exception raised when a non-string pkgbuild is passed.
  class InvalidPkgbuildError < StandardError; end

  # Exception raised when no gemname is specified.
  class UndefinedGemNameError < StandardError; end

  # Exception raised when no pkgname is specified.
  class UndefinedPkgnameError < StandardError; end
end
