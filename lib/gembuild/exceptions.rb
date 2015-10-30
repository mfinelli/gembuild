# encoding: utf-8

module Gembuild
  # Exception raised when no pkgname is specified.
  class UndefinedPkgnameError < StandardError; end

  # Exception raised when no gemname is specified.
  class UndefinedGemNameError < StandardError; end
end
