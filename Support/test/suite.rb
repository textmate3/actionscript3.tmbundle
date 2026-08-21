#!/usr/bin/env ruby -w
# encoding: utf-8

require 'test/unit'

# The cases require the bundle's Support/lib and the shared Bundle Support
# libraries (TM_SUPPORT_PATH). Inside TextMate both come from the editor via
# Apple-R. From a terminal this suite provides them itself, defaulting
# TM_SUPPORT_PATH to the sibling bundle-support.tmbundle checkout, so:
#
#   ruby Support/test/suite.rb
#
# works from any working directory.

$:.unshift File.expand_path('../lib', __dir__)
ENV['TM_SUPPORT_PATH'] ||= File.expand_path('../../../bundle-support.tmbundle/Support/shared', __dir__)

cases = __dir__ + "/cases"

tests =  Dir["#{cases}/test_*.rb"]
tests << Dir["#{cases}/as3/test_*.rb"]
tests << Dir["#{cases}/as3/parsers/test_*.rb"]
tests << Dir["#{cases}/fm/test_*.rb"]

tests.flatten.each do |file|
  require file
end
