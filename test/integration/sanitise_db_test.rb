require 'fast_test_helper'

class SanitiseDBTest < ActiveSupport::TestCase
  test 'scrub script runs' do
    `./script/scrub-database --no-copy -d whitehall_test -D whitehall_test`
    assert $?.to_i == 0, "Script exited non-zero"
  end
end
