require "test_helper"

class HtmlVersionTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :title, :body

  test 'belong to publications' do
    publication = build(:publication)
    HtmlVersion.new(edition_id: publication.id)
  end

  test 'is invalid without a title' do
    refute build(:html_version, title: nil).valid?
  end

  test 'is invalid without a body' do
    refute build(:html_version, body: nil).valid?
  end

  test 'will tell friendlyId to generate a new slug if the slug is nil' do
    assert build(:html_version, slug: nil).should_generate_new_friendly_id?
  end

  test 'will tell friendlyId to generate a new slug if it has a slug, but its\' edition is nil' do
    assert build(:html_version, slug: 'meh', edition: nil).should_generate_new_friendly_id?
  end

  test 'will tell friendlyId to generate a new slug if it has a slug, has an edition, and it\'s edition\'s document has not been published' do
    edition = build(:edition, :with_document)
    edition.document.stubs(:published?).returns(false)
    assert build(:html_version, slug: 'meh', edition: edition).should_generate_new_friendly_id?
  end

  test 'will not tell friendlyId to generate a new slug if has a slug, has an edition, and it\'s edition\'s document has been published' do
    edition = build(:edition, :with_document)
    edition.document.stubs(:published?).returns(true)
    refute build(:html_version, slug: 'meh', edition: edition).should_generate_new_friendly_id?
  end
end
