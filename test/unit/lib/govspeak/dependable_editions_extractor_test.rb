require "test_helper"

class Govspeak::DependableEditionsExtractorTest < ActiveSupport::TestCase
  test "extracts references to draft editions" do
    speech = create(:speech)
    govspeak = "[latest speech](/government/admin/speeches/#{speech.id})"

    assert_equal [speech], Govspeak::DependableEditionsExtractor.new(govspeak).editions
  end

  test "extracts references to organisation corporate information pages in draft" do
    cip = create(:corporate_information_page)
    govspeak = "[CIP](/government/admin/organisations/organisation-5/corporate_information_pages/#{cip.id})"

    assert_equal [cip], Govspeak::DependableEditionsExtractor.new(govspeak).editions
  end

  test "extracts references to worldwide organisation corporate information pages in draft" do
    world_org = create(:worldwide_organisation)
    cip = create(:corporate_information_page, organisation: nil, worldwide_organisation: world_org)
    govspeak = "[CIP](/government/admin/worldwide_organisations/worldwide-organisation-1/corporate_information_pages/#{cip.id})"

    assert_equal [cip], Govspeak::DependableEditionsExtractor.new(govspeak).editions
  end

  test "silently ignores references to non-existent editions" do
    govspeak = "Governor's latest [speech](/government/admin/speeches/243)."
    assert_empty Govspeak::DependableEditionsExtractor.new(govspeak).editions
  end

  test "ignores published editions" do
    published_speech = create(:published_speech)
    govspeak = "[speech](/government/admin/speeches/#{published_speech.id})"

    assert_empty Govspeak::DependableEditionsExtractor.new(govspeak).editions
  end

  test "ignores post-published editions" do
    superseded_speech = create(:superseded_speech)
    govspeak = "[old speech](/government/admin/speeches/#{superseded_speech.id})"

    assert_empty Govspeak::DependableEditionsExtractor.new(govspeak).editions
  end

  test "will remove duplicate dependable editions" do
    speech = create(:speech)
    govspeak = "[old speech](/government/admin/speeches/#{speech.id})
                  [same speech](/government/admin/speeches/#{speech.id})"

    assert_equal [speech], Govspeak::DependableEditionsExtractor.new(govspeak).editions
  end
end
