require 'test_helper'

class HtmlAttachmentsControllerTest < ActionController::TestCase

  view_test '#show renders the HTML attachment of a publication' do
    publication, attachment = create_edition_and_attachment
    get :show, publication_id: publication.document, id: attachment

    assert_response :success
    assert_select 'header h1', attachment.title
  end

  view_test '#show renders the HTML attachment of a consultation' do
    consultation, attachment = create_edition_and_attachment(:consultation)
    get :show, consultation_id: consultation.document, id: attachment

    assert_response :success
    assert_select 'header h1', attachment.title
  end

  test '#show returns 404 if the edition is not published' do
    publication, attachment = create_edition_and_attachment(:publication, :draft)

    assert_raise ActiveRecord::RecordNotFound do
      get :show, publication_id: publication.document, id: attachment
    end
  end

  test '#show returns 404 if the edition cannot be found' do
    attachment = create(:html_attachment)

    assert_raise ActiveRecord::RecordNotFound do
      get :show, publication_id: 'bogus-edition-slug', id: attachment
    end
  end

  test '#show returns 404 if the attachment cannot be found' do
    publication = create(:published_publication)

    assert_raise ActiveRecord::RecordNotFound do
      get :show, publication_id: publication.document, id: 'bogus-attachment-slug'
    end
  end

  view_test '#show renders the HTML attachment if previewing an attachment on a draft edition' do
    login_as create(:departmental_editor)
    publication, attachment = create_edition_and_attachment(:publication, :draft)

    get :show, publication_id: publication.document, id: attachment, preview: attachment.id

    assert_response :success
    assert_select 'header h1', attachment.title
  end

  view_test '#show previews the latest html attachment, despite the slugs matching' do
    user = create(:departmental_editor)
    publication, attachment = create_edition_and_attachment(:publication)
    draft = publication.create_draft(user)
    draft_attachment = draft.attachments.first
    draft_attachment.update_attribute(:title, 'Updated HTML Attachment Title')

    login_as user
    get :show, publication_id: draft.document, id: draft_attachment, preview: draft_attachment.id

    assert_response :success
    assert_select 'header h1', draft_attachment.title
  end

private

  def create_edition_and_attachment(type = :publication, state = :published)
    publication = create([state, type].join('_'))
    attachment = create(:html_attachment, title: 'HTML Attachment Title')
    publication.attachments << attachment
    [publication, attachment]
  end
end
