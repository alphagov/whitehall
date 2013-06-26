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

  test 'Whitehall.uploads_root segregates per-test environment' do
    begin
      before = ENV['TEST_ENV_NUMBER']

      ENV['TEST_ENV_NUMBER'] = ''
      assert_equal Rails.root.join('tmp/test/env_1').to_s, Whitehall.uploads_root

      ENV['TEST_ENV_NUMBER'] = '1'
      assert_equal Rails.root.join('tmp/test/env_1').to_s, Whitehall.uploads_root

      ENV['TEST_ENV_NUMBER'] = '2'
      assert_equal Rails.root.join('tmp/test/env_2').to_s, Whitehall.uploads_root
    ensure
      ENV['TEST_ENV_NUMBER'] = before
    end
  end
end
