require 'test_helper'

class BadMarkdownLinkCleanerTest < ActiveSupport::TestCase
  def setup
    @logger = Logger.new(nil)
    @router_prefix = "/government"
    @b = BadMarkdownLinkCleaner.new(logger: @logger, router_prefix: @router_prefix, actor: stub("actor"))
  end

  def stub_edition(body)
    @editorial_remarks = stub_everything("editorial_remarks")
    @edition = stub("edition", force_published?: false, id: 123, editorial_remarks: @editorial_remarks)
    @edition_translation = stub("edition_translation", body: body, edition: @edition, edition_id: @edition.id, state: "draft")
  end

  def test_replacement_urls_preserve_url_params
    original_url = 'https://whitehall-admin.production.alphagov.co.uk/government/publications?my_param=1&param2=3'
    expected_replacement_url = 'https://www.gov.uk/government/publications?my_param=1&param2=3'
    stub_edition("[GOV.UK](#{original_url})")
    assert_equal "[GOV.UK](#{expected_replacement_url})", @b.replacement_body_for(@edition_translation)
  end

  def test_replacement_urls_strip_preview_params
    original_url = 'https://whitehall-admin.production.alphagov.co.uk/government/publications?cachebust=1363696439&preview=151084'
    expected_replacement_url = 'https://www.gov.uk/government/publications'
    stub_edition("[GOV.UK](#{original_url})")
    assert_equal "[GOV.UK](#{expected_replacement_url})", @b.replacement_body_for(@edition_translation)
  end

  def test_replacement_urls_preserve_anchor_tags
    original_url = 'https://whitehall-admin.production.alphagov.co.uk/government/publications#my_anchor'
    expected_replacement_url = 'https://www.gov.uk/government/publications#my_anchor'
    stub_edition("[GOV.UK](#{original_url})")
    assert_equal "[GOV.UK](#{expected_replacement_url})", @b.replacement_body_for(@edition_translation)
  end

  def test_combination_of_params_and_anchor_handled_correctly
    original_url = 'https://whitehall-admin.production.alphagov.co.uk/government/publications?cachebust=1363696439&preview=151084&my_param=1#my_anchor'
    expected_replacement_url = 'https://www.gov.uk/government/publications?my_param=1#my_anchor'
    stub_edition("[GOV.UK](#{original_url})")
    assert_equal "[GOV.UK](#{expected_replacement_url})", @b.replacement_body_for(@edition_translation)
  end
end
