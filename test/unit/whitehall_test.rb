require 'test_helper'

class WhitehallTest < ActiveSupport::TestCase
  test 'all required system binaries are absolute paths, exist and are executable' do
    Whitehall.system_binaries.each_value do |binary_path|
      assert_match %r{\A/}, binary_path
      assert File.exist?(binary_path), "#{binary_path} must exist"
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
