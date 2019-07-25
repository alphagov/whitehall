require 'test_helper'

class UnpublishingTest < ActiveSupport::TestCase
  test 'is not valid without an unpublishing reason' do
    unpublishing = build(:unpublishing, unpublishing_reason: nil)
    assert_not unpublishing.valid?
  end

  test 'is not valid without an edition' do
    unpublishing = build(:unpublishing)
    unpublishing.edition = nil

    assert_not unpublishing.valid?
  end

  test 'is not valid without a document type' do
    unpublishing = build(:unpublishing)
    unpublishing.document_type = nil

    assert_not unpublishing.valid?
  end

  test 'is not valid without a slug' do
    unpublishing = build(:unpublishing)
    unpublishing.slug = nil

    assert_not unpublishing.valid?
  end

  test 'is not valid without a url if redirect is chosen' do
    unpublishing = build(:unpublishing, redirect: true)
    assert_not unpublishing.valid?

    unpublishing = build(:unpublishing, redirect: true, alternative_url: "#{Whitehall.public_protocol}://#{Whitehall.public_host}/example")
    assert unpublishing.valid?

    unpublishing = build(:unpublishing, redirect: false, alternative_url: "#{Whitehall.public_protocol}://#{Whitehall.public_host}/example")
    assert unpublishing.valid?
  end

  test 'alternative_url cannot be the same url as the edition' do
    document = create(:document, slug: 'document-path')
    edition = create(:detailed_guide, document: document)
    unpublishing = build(:unpublishing, redirect: true, alternative_url: 'https://www.test.gov.uk/guidance/document-path', edition: edition)

    assert_not unpublishing.valid?
    assert unpublishing.errors[:alternative_url].include?("cannot redirect to itself")
  end

  test 'alternative_url must not be external (must be in the form of https://www.gov.uk/example)' do
    unpublishing = build(:unpublishing, redirect: true, alternative_url: "http://example.com")
    assert_not unpublishing.valid?

    unpublishing = build(:unpublishing, redirect: true, alternative_url: "#{Whitehall.public_protocol}://#{Whitehall.public_host}/example")
    assert unpublishing.valid?
  end

  test 'alternative_url is stripped before validate' do
    unpublishing = build(:unpublishing, redirect: true, alternative_url: "https://gov.uk/guidance ")
    unpublishing.valid?

    assert_equal "https://gov.uk/guidance", unpublishing.alternative_url
  end

  test 'alternative_path returns the path of alternative_url' do
    unpublishing = build(:unpublishing, redirect: true, alternative_url: 'https://www.test.gov.uk/guidance/document-path')
    assert_equal "/guidance/document-path", unpublishing.alternative_path
  end

  test 'alternative_path returns nil if alternative_url is nil' do
    unpublishing = build(:unpublishing, redirect: true, alternative_url: nil)
    assert_nil unpublishing.alternative_path
  end

  test 'alternative_path returns the fragment of alternative_url' do
    unpublishing = build(:unpublishing, redirect: true, alternative_url: 'https://www.test.gov.uk/guidance/document-path#part-one')
    assert_includes unpublishing.alternative_path, "#part-one"
  end

  test 'returns an unpublishing reason' do
    unpublishing = build(:unpublishing, unpublishing_reason: reason)
    assert_equal reason, unpublishing.unpublishing_reason
  end

  test 'returns the unpublishing reason as a sentence' do
    assert_equal reason.as_sentence, build(:unpublishing, unpublishing_reason: reason).reason_as_sentence
  end

  test 'can be retrieved by slug and document type' do
    case_study = create(:case_study)
    unpublishing = create(:unpublishing, edition: case_study)

    assert_not Unpublishing.from_slug('wrong-slug', 'CaseStudy')
    assert_not Unpublishing.from_slug(unpublishing.slug, 'OtherDocumentType')
    assert_equal unpublishing, Unpublishing.from_slug(unpublishing.slug, 'CaseStudy')
  end

  test 'Unpublishing.from_slug returns the most recent unpublishing' do
    case_study          = create(:published_case_study)
    _first_unpublishing = create(:unpublishing, edition: case_study, slug: case_study.slug)
    new_edition         = case_study.create_draft(create(:user))
    second_unpublishing = create(:unpublishing, edition: new_edition, slug: new_edition.slug)

    assert_equal second_unpublishing, Unpublishing.from_slug(new_edition.slug, 'CaseStudy')
  end

  test 'alternative_url is required if the reason is Consolidated' do
    unpublishing = build(:unpublishing, unpublishing_reason: UnpublishingReason::Consolidated, alternative_url: nil)
    assert_not unpublishing.valid?
    assert_equal ['must be provided to redirect the document'], unpublishing.errors[:alternative_url]
  end

  test 'always redirects if the reason is Consolidated' do
    unpublishing = Unpublishing.new(unpublishing_reason: UnpublishingReason::Consolidated)
    assert unpublishing.redirect?
  end

  test 'explanation is required if the reason is Withdrawn' do
    unpublishing = build(:unpublishing, unpublishing_reason: UnpublishingReason::Withdrawn, explanation: nil)
    assert_not unpublishing.valid?
    assert_equal ['must be provided when withdrawing'], unpublishing.errors[:explanation]
  end

  test '#document_path returns the URL path for the unpublished edition' do
    edition = create(:detailed_guide, :draft)
    original_path = Whitehall.url_maker.public_document_path(edition)
    unpublishing = create(:unpublishing, edition: edition,
                          unpublishing_reason: UnpublishingReason::PublishedInError)

    assert_equal original_path, unpublishing.document_path
  end

  test '#document_path returns the URL path using the slug from the unpublishing' do
    edition = create(:detailed_guide, :draft)
    unpublishing = create(:unpublishing, edition: edition,
                          unpublishing_reason: UnpublishingReason::PublishedInError)
    unpublishing.update_attribute(:slug, 'a-different-slug')

    assert_equal '/guidance/a-different-slug', unpublishing.document_path
  end

  test '#document_url returns the URL for the unpublished edition' do
    edition = create(:detailed_guide, :draft)
    original_url = Whitehall.url_maker.public_document_url(edition)
    unpublishing = create(:unpublishing, edition: edition,
                          unpublishing_reason: UnpublishingReason::PublishedInError)

    assert_equal original_url, unpublishing.document_url
  end

  test '#document_url returns the URL using the slug from the unpublishing' do
    edition = create(:detailed_guide, :draft)
    unpublishing = create(:unpublishing, edition: edition,
                          unpublishing_reason: UnpublishingReason::PublishedInError)
    unpublishing.update_attribute(:slug, 'a-different-slug')

    assert_match '/guidance/a-different-slug', unpublishing.document_url
  end

  test '#translated_locales is delegated to the edition' do
    edition = create(:case_study)
    I18n.with_locale(:es) do
      edition.title = "Spanish title"
      edition.save!
    end
    unpublishing = create(:unpublishing, edition: edition)

    assert_equal %i[en es], unpublishing.translated_locales
  end

  test "generates its own content ID on creation" do
    assert_not_nil Unpublishing.new.content_id
  end

  test "does not overwrite a provided content ID" do
    content_id = SecureRandom.uuid
    unpublishing = Unpublishing.new(content_id: content_id)
    assert_equal content_id, unpublishing.content_id
  end

  def reason
    UnpublishingReason::PublishedInError
  end
end
