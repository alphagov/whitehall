require 'test_helper'

class WhitehallTest < ActiveSupport::TestCase
  test 'use S3 storage if AWS access details set' do
    Whitehall.stubs(:aws_access_key_id).returns('an-id')
    Whitehall.stubs(:aws_secret_access_key).returns('private-key')
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('anything-other-than-test'))
    assert Whitehall.use_s3?
  end

  test 'never use S3 storage in test environment' do
    Whitehall.stubs(:aws_access_key_id).returns('an-id')
    Whitehall.stubs(:aws_secret_access_key).returns('private-key')
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('test'))
    refute Whitehall.use_s3?
  end

  test 'use file storage if no access details set' do
    refute Whitehall.use_s3?
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
end