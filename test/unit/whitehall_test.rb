require 'test_helper'

class WhitehallTest < ActiveSupport::TestCase
  test '.platform returns FACTER_govuk_platform if set' do
    ENV['FACTER_govuk_platform'] = 'preview'
    assert_equal 'preview', Whitehall.platform
  end

  test '.platform returns Rails.env if FACTER_govuk_platform is unavailable' do
    ENV['FACTER_govuk_platform'] = nil
    assert_equal 'test', Whitehall.platform
  end
end