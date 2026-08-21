#!/usr/bin/env ruby -w
# encoding: utf-8

require "test/unit"
require "fm/bundle_tool"

class TestBundleTool < Test::Unit::TestCase

  # BundleTool searches bundle directories under ENV['HOME'], so point HOME
  # at a fixture home containing the two bundles the assertions expect, in
  # the spirit of ruby.tmbundle's fake_rvm_home fixture. The original test
  # probed the real ~/Library and only passed on a machine with Flex and
  # ActionScript 3 installed as user bundles.
  def setup
    @original_home = ENV['HOME']
    ENV['HOME'] = File.expand_path('../../assets/fake_home', __dir__)
  end

  def teardown
    ENV['HOME'] = @original_home
  end

  def user_app_sup
    "#{ENV['HOME']}/Library/Application Support"
  end

  def test_find_without_extension
    assert_equal("#{user_app_sup}/TextMate/Bundles/Flex.tmbundle", FlexMate::BundleTool.find_bundle('Flex')[0])
    assert_equal("#{user_app_sup}/TextMate/Bundles/ActionScript 3.tmbundle", FlexMate::BundleTool.find_bundle('ActionScript 3')[0])
  end

  def test_find_with_extension
    assert_equal("#{user_app_sup}/TextMate/Bundles/Flex.tmbundle", FlexMate::BundleTool.find_bundle('Flex.tmbundle')[0])
    assert_equal("#{user_app_sup}/TextMate/Bundles/ActionScript 3.tmbundle", FlexMate::BundleTool.find_bundle('ActionScript 3.tmbundle')[0])
  end
end
