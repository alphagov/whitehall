# DO NOT ADD ANYTHING TO THIS FILE!

# We want to keep this extremely lean to keep the tests that use it
# extremely fast.

# If you feel like you want to add something, first, consider whether or not
# it's a dependency you actually want to include in your test at all. Can you
# stub or mock it?

# If you're sure you need to load the dependency, then add it to your test
# file first. Only when it's something that basically every test needs should
# you add it here.


require 'bundler/setup'
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift File.expand_path("..", __FILE__)

require 'active_support/test_case'
require 'minitest/autorun'

require 'logger'
