require 'test_helper'

class HtmlAttachmentsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  view_test '#show renders the HTML attachment of a published publication' do
    publication, attachment = create_edition_and_attachment
    get :show, publication_id: publication.document, id: attachment

    assert_response :success
    assert_select 'header h1', attachment.title
    assert_cache_control("max-age=#{Whitehall.default_cache_max_age}")
  end

  view_test '#show renders the HTML attachment of a published publication in a non-english locale' do
    publication, attachment = create_edition_and_attachment(locale: "fr")
    get :show, publication_id: publication.document, id: attachment

    assert_response :success
    assert_select 'header h1', attachment.title
    assert_cache_control("max-age=#{Whitehall.default_cache_max_age}")
  end

  view_test '#show renders the HTML attachment of a published consultation' do
    consultation, attachment = create_edition_and_attachment(type: :consultation)
    get :show, consultation_id: consultation.document, id: attachment

    assert_response :success
    assert_select 'header h1', attachment.title
  end

  test '#show returns 404 if the edition is not published' do
    publication, attachment = create_edition_and_attachment(state: :draft)

    assert_raise ActiveRecord::RecordNotFound do
      get :show, publication_id: publication.document, id: attachment
    end
  end

  test '#show returns 404 if the attachment cannot be found' do
    publication = create(:published_publication)

    assert_raise ActiveRecord::RecordNotFound do
      get :show, publication_id: publication.document, id: 'bogus-attachment-slug'
    end
  end

  view_test '#show renders the HTML attachment (without caching) on draft edition if previewing' do
    login_as create(:departmental_editor)
    publication, attachment = create_edition_and_attachment(state: :draft)

    get :show, publication_id: publication.document, id: attachment, preview: attachment.id

    assert_response :success
    assert_equal 'no-cache, max-age=0, private', response.headers['Cache-Control']
    assert_select 'header h1', attachment.title
  end

  view_test '#show previews the latest html attachment (without caching), despite the slugs matching' do
    user = create(:departmental_editor)
    publication, attachment = create_edition_and_attachment
    draft = publication.create_draft(user)
    draft_attachment = draft.attachments.first
    draft_attachment.update_attribute(:title, 'Updated HTML Attachment Title')

    login_as user
    get :show, publication_id: draft.document, id: draft_attachment, preview: draft_attachment.id

    assert_response :success
    assert_equal 'no-cache, max-age=0, private', response.headers['Cache-Control']
    assert_select 'header h1', draft_attachment.title
  end

  test '#show redirects to the edition if the edition has been unpublished' do
    publication, attachment = create_edition_and_attachment(state: :draft, build_unpublishing: true)

    get :show, publication_id: publication.document, id: attachment

    assert_redirected_to publication_url(publication.document)
  end

  test '#show redirects to the edition if the edition has been unpublished and deleted' do
    publication, attachment = create_edition_and_attachment(state: :deleted, build_unpublishing: true)

    get :show, publication_id: publication.document, id: attachment

    assert_redirected_to publication_url(publication.document)
  end

  view_test '#show does not redirect if an unpublished edition is subsequently published' do
    publication, attachment = create_edition_and_attachment(build_unpublishing: true)

    get :show, publication_id: publication.document, id: attachment

    assert_response :success
    assert_select 'header h1', attachment.title
  end

private
  def create_edition_and_attachment(options = {})
    type = options.fetch(:type, :publication)
    state = options.fetch(:state, :published)
    build_unpublishing = options.fetch(:build_unpublishing, false)
    locale = options.fetch(:locale, nil)

    publication = create("#{state}_#{type}", translated_into: [locale].compact, attachments: [
      attachment = build(:html_attachment, title: 'HTML Attachment Title', locale: locale)
    ])

    create(:unpublishing, edition: publication, slug: publication.slug) if build_unpublishing

    [publication, attachment]
  end
end
