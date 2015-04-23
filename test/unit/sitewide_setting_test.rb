require 'test_helper'

class SitewideSettingTest < ActiveSupport::TestCase
  test "enabled? returns false by default" do
    refute SitewideSetting.on?('undefined-key')
  end

  test "enabled returns true when set" do
    SitewideSetting.create(key: 'new-key', enabled: true)
    assert SitewideSetting.on?('new-key')
  end

  test "set sets the value of a flag" do
    SitewideSetting.set('set-key', true)
    assert SitewideSetting.on?('set-key')
    SitewideSetting.set('set-key', false)
    refute SitewideSetting.on?('set-key')
  end
end
