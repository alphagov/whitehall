require 'test_helper'

class WhitehallTest < ActiveSupport::TestCase
  test 'use quarantined file store in preview' do
    Whitehall.stubs(:platform).returns('preview')
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('not-test-environment'))
    assert_equal :quarantined_file, Whitehall.asset_storage_mechanism
  end

  test 'use quarantined file store in production' do
    Whitehall.stubs(:platform).returns('production')
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('not-test-environment'))
    assert_equal :quarantined_file, Whitehall.asset_storage_mechanism
  end

  test 'always uses file storage in test environment' do
    Whitehall.stubs(:platform).returns('production')
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('test'))
    assert_equal :file, Whitehall.asset_storage_mechanism
  end

  test 'use file storage if no access details set' do
    assert_equal :file, Whitehall.asset_storage_mechanism
  end

  test '.platform returns FACTER_govuk_platform if set' do
    ENV['FACTER_govuk_platform'] = 'preview'
    assert_equal 'preview', Whitehall.platform
  end

  test '.platform returns Rails.env if FACTER_govuk_platform is unavailable' do
    ENV['FACTER_govuk_platform'] = nil
    assert_equal 'test', Whitehall.platform
  end

  test 'public host for public-api preview requests is main preview host' do
    assert_equal 'www.preview.alphagov.co.uk', Whitehall.public_host_for('public-api.preview.alphagov.co.uk')
  end

  test 'public host for public-api preview is www.gov.uk' do
    assert_equal 'www.gov.uk', Whitehall.public_host_for('public-api.production.alphagov.co.uk')
  end

  test 'all required system binaries are absolute paths, exist and are executable' do
    Whitehall.system_binaries.values.each do |binary_path|
      assert_match %r{\A/}, binary_path
      assert File.exists?(binary_path), "#{binary_path} must exist"
      assert File.executable?(binary_path), "#{binary_path} must be executable"
    end
  end
end