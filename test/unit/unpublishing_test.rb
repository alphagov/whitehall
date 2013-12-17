require 'test_helper'

class UnpublishingTest < ActiveSupport::TestCase
  test 'is not valid without an unpublishing reason' do
    unpublishing = build(:unpublishing, unpublishing_reason_id: nil)
    refute unpublishing.valid?
  end

  test 'is not valid without an edition' do
    unpublishing = build(:unpublishing, edition: nil)
    refute unpublishing.valid?
  end

  test 'is not valid without a document type' do
    unpublishing = build(:unpublishing)
    unpublishing.document_type = nil

    refute unpublishing.valid?
  end

  test 'is not valid without a slug' do
    unpublishing = build(:unpublishing, slug: nil)
    refute unpublishing.valid?
  end

  test 'is not valid without a url if redirect is chosen' do
    unpublishing = build(:unpublishing, redirect: true)
    refute unpublishing.valid?

    unpublishing = build(:unpublishing, redirect: true, alternative_url: "#{Whitehall.public_protocol}://#{Whitehall.public_host}/example")
    assert unpublishing.valid?

    unpublishing = build(:unpublishing, redirect: false, alternative_url: "#{Whitehall.public_protocol}://#{Whitehall.public_host}/example")
    assert unpublishing.valid?
  end

  test 'alternative_url cannot be the same url as the edition' do
    unpublishing = build(:unpublishing, redirect: true)
    unpublishing.alternative_url = Whitehall.url_maker.public_document_url(unpublishing.edition)
    assert_equal unpublishing.alternative_url, unpublishing.edition_url
    refute unpublishing.valid?
    assert unpublishing.errors[:alternative_url].include?("cannot redirect to itself")
  end

  test 'alternative_url must not be external (must be in the form of https://www.gov.uk/example)' do
    unpublishing = build(:unpublishing, redirect: true, alternative_url: "http://example.com")
    refute unpublishing.valid?

    unpublishing = build(:unpublishing, redirect: true, alternative_url: "#{Whitehall.public_protocol}://#{Whitehall.public_host}/example")
    assert unpublishing.valid?
  end

  test 'returns an unpublishing reason' do
    unpublishing = build(:unpublishing, unpublishing_reason_id: reason.id)
    assert_equal reason, unpublishing.unpublishing_reason
  end

  test 'returns the unpublishing reason as a sentence' do
    assert_equal reason.as_sentence, build(:unpublishing, unpublishing_reason_id: reason.id).reason_as_sentence
  end

  test 'can be retrieved by slug and document type' do
    case_study = create(:case_study)
    unpublishing = create(:unpublishing, edition: case_study, slug: 'some-slug')

    refute Unpublishing.from_slug('not-a-match','CaseStudy')
    refute Unpublishing.from_slug('some-slug','OtherDocumentType')
    assert_equal unpublishing, Unpublishing.from_slug('some-slug', 'CaseStudy')
  end

  test 'alternative_url is required if the reason is Consolidated' do
    unpublishing = build(:unpublishing, unpublishing_reason_id: UnpublishingReason::Consolidated.id, alternative_url: nil)
    refute unpublishing.valid?
    assert_equal ['must be provided to redirect the document'], unpublishing.errors[:alternative_url]
  end

  test 'always redirects if the reason is Consolidated' do
    unpublishing = Unpublishing.new(unpublishing_reason_id: UnpublishingReason::Consolidated.id)
    assert unpublishing.redirect?
  end

  test 'explanation is required if the reason is Archived' do
    unpublishing = build(:unpublishing, unpublishing_reason_id: UnpublishingReason::Archived.id, explanation: nil)
    refute unpublishing.valid?
    assert_equal ['must be provided when archiving'], unpublishing.errors[:explanation]
  end

  def reason
    UnpublishingReason::PublishedInError
  end
end
