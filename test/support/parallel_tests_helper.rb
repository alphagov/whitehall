# Fixes Rails 6 native parallelize behaviour.
#
# The spec DSL creates anonymous classes for tests.
# When these Class objects are passed through `Drb`, they are wrapped in a `DrbObject`.
# This causes parallel tests to fail with the following error message:
#     `current_server': DRb::DRbServerNotFound (DRb::DRbConnError)
#
# The solution, based on https://github.com/blowmage/minitest-rails/issues/217#issuecomment-493195882,
# is to assign each Class object to a constant, so that the constant is used when passing to Drb.

module Minitest
  module FixParallelTests
  end
end

module Kernel
  alias_method :describe_before_minitest_spec_constant_fix, :describe
  private :describe_before_minitest_spec_constant_fix
  def describe(*args, &block)
    anonymous_class = describe_before_minitest_spec_constant_fix(*args, &block)
    ::Minitest::FixParallelTests.const_set("Test__#{anonymous_class.object_id}", anonymous_class)
    anonymous_class
  end
end
