require "test_helper"

class WhitehallTest < ActiveSupport::TestCase
  test "all required system binaries are absolute paths, exist and are executable" do
    Whitehall.system_binaries.each_value do |binary_path|
      assert_match %r{\A/}, binary_path
      assert File.exist?(binary_path), "#{binary_path} must exist"
      assert File.executable?(binary_path), "#{binary_path} must be executable"
    end
  end

  test "Whitehall.uploads_root segregates per-test environment" do
    before = ENV["TEST_ENV_NUMBER"]

    ENV["TEST_ENV_NUMBER"] = ""
    assert_equal Rails.root.join("tmp/test/env_1").to_s, Whitehall.uploads_root

    ENV["TEST_ENV_NUMBER"] = "1"
    assert_equal Rails.root.join("tmp/test/env_1").to_s, Whitehall.uploads_root

    ENV["TEST_ENV_NUMBER"] = "2"
    assert_equal Rails.root.join("tmp/test/env_2").to_s, Whitehall.uploads_root
  ensure
    ENV["TEST_ENV_NUMBER"] = before
  end

  test "Whitehall.image_kinds is populated with defaults from config" do
    assert_pattern do
      Whitehall.image_kinds["default"] => {
        name: "default",
        valid_width: 960,
        valid_height: 640,
        versions: [
          { name: "s960" },
          *_rest
        ],
      }
    end
  end

  test "Whitehall.image_kinds all have distinct version names" do
    # It's important that version names are globally unique to ensure that
    # asset variants in the database are not ambiguous
    all_version_names = Whitehall.image_kinds.values.flat_map(&:version_names)
    unique_version_names = all_version_names.uniq
    assert_equal all_version_names.size, unique_version_names.size
  end

  test "Whitehall.integration_or_staging? tells us if we are in the right env" do
    before = ENV["GOVUK_ENVIRONMENT"]

    ENV["GOVUK_ENVIRONMENT"] = "integration"
    assert Whitehall.integration_or_staging?

    ENV["GOVUK_ENVIRONMENT"] = "staging"
    assert Whitehall.integration_or_staging?

    ENV["GOVUK_ENVIRONMENT"] = "production"
    assert_equal false, Whitehall.integration_or_staging?

    ENV.delete("GOVUK_ENVIRONMENT")
    assert_equal false, Whitehall.integration_or_staging?
  ensure
    ENV["GOVUK_ENVIRONMENT"] = before
  end

  test "Whitehall.integration? is only true on integration" do
    before = ENV["GOVUK_ENVIRONMENT"]

    ENV["GOVUK_ENVIRONMENT"] = "integration"
    assert Whitehall.integration?

    ENV["GOVUK_ENVIRONMENT"] = "staging"
    assert_equal false, Whitehall.integration?

    ENV.delete("GOVUK_ENVIRONMENT")
    assert_equal false, Whitehall.integration?
  ensure
    ENV["GOVUK_ENVIRONMENT"] = before
  end

  test "Whitehall's environment doesn't depend on where GOVUK_WEBSITE_ROOT points" do
    before = ENV.values_at("GOVUK_ENVIRONMENT", "GOVUK_WEBSITE_ROOT")

    ENV["GOVUK_ENVIRONMENT"] = "integration"
    ENV["GOVUK_WEBSITE_ROOT"] = "http://frontend-abc1234.govuk-preview-app.dev.gov.uk"
    assert Whitehall.integration_or_staging?
  ensure
    ENV["GOVUK_ENVIRONMENT"], ENV["GOVUK_WEBSITE_ROOT"] = before
  end
end
