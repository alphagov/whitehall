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
    unpublishing = build(:unpublishing, document_type: nil)
    refute unpublishing.valid?
  end

  test 'is not valid without a slug' do
    unpublishing = build(:unpublishing, slug: nil)
    refute unpublishing.valid?
  end

  test 'is not valid without a url if redirect is chosen' do
    unpublishing = build(:unpublishing, redirect: true)
    unpublishing.stubs(edition_url: "http://example.com/new")
    refute unpublishing.valid?

    unpublishing = build(:unpublishing, redirect: true, alternative_url: "http://example.com")
    unpublishing.stubs(edition_url: "http://example.com/new")
    assert unpublishing.valid?

    unpublishing = build(:unpublishing, redirect: false, alternative_url: "http://example.com")
    unpublishing.stubs(edition_url: "http://example.com/new")
    assert unpublishing.valid?
  end

  test 'cannot redirect to itself' do
    unpublishing = build(:unpublishing, redirect: true, alternative_url: "http://example.com")
    unpublishing.stubs(edition_url: "http://example.com")
    refute unpublishing.valid?
    assert_equal ["cannot redirect to itself"], unpublishing.errors[:alternative_url]
  end

  test 'returns an unpublishing reason' do
    unpublishing = build(:unpublishing, unpublishing_reason_id: reason.id)
    assert_equal reason, unpublishing.unpublishing_reason
  end

  test 'returns the unpublishing reason as a sentence' do
    assert_equal reason.as_sentence, build(:unpublishing, unpublishing_reason_id: reason.id).reason_as_sentence
  end

  test 'can be retrieved by slug and document type' do
    unpublishing = create(:unpublishing, document_type: 'CaseStudy', slug: 'some-slug', alternative_url: "http://example.com")

    refute Unpublishing.from_slug('not-a-match','CaseStudy')
    refute Unpublishing.from_slug('some-slug','OtherDocumentType')
    assert_equal unpublishing, Unpublishing.from_slug('some-slug', 'CaseStudy')
  end

  def reason
    UnpublishingReason::PublishedInError
  end
end
