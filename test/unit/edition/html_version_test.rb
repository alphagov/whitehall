require 'test_helper'

class Edition::HtmlVersionTest < ActiveSupport::TestCase
  test 'has optional html version' do
    publication = build(:publication, :without_html_version)
    refute publication.html_version.present?

    publication.html_version_attributes = {
      title: "title",
      body: "body"
    }
    publication.save!

    assert_equal "title", publication.reload.html_version.title
  end

  test 'html version is destroyed if the publication is destroyed' do
    publication = create(:publication, :with_html_version)
    html_version = publication.html_version
    publication.destroy
    refute HtmlVersion.find_by_id(html_version.id)
  end

  test 'html version is not saved if all blank' do
    publication = build(:publication, :without_html_version)
    publication.html_version_attributes = {
      title: "",
      body: ""
    }
    publication.save!
    refute publication.html_version
  end

  test 'html version errors mean the publication will not save' do
    publication = build(:publication)
    publication.html_version_attributes = {
      title: "something",
      body: ""
    }
    refute publication.valid?
    refute publication.html_version.errors.empty?
  end

  test 'html version is copied over on republish' do
    publication = create(:published_publication, :with_html_version)
    new_draft = publication.create_draft(create(:author))

    assert_equal publication.html_version.title, new_draft.html_version.title
    assert_equal publication.html_version.body, new_draft.html_version.body
    assert_equal publication.html_version.slug, new_draft.html_version.slug

    new_draft.html_version.title = 'new title'
    refute_equal 'new title', publication.reload.html_version.title
  end

  test 'slugs are saved on new html versions for editions that previously didn\'t have one' do
    editor = create(:gds_editor)
    pub = create(:draft_publication, html_version: nil)
    pub.publish_as(editor, force: true)
    draft = pub.create_draft(editor)
    draft.change_note = 'Added html version'
    draft.html_version = build(:html_version, title: 'things')
    draft.save!

    hv = draft.html_version
    hv.reload
    refute_nil hv.slug
  end

  test 'html versions are copied from edition to edition' do
    editor = create(:gds_editor)
    pub = create(:draft_publication, html_version: build(:html_version, title: 'things'))
    pub.publish_as(editor, force: true)
    draft = pub.create_draft(editor)
    draft.change_note = 'Added html version'
    draft.save!

    assert_not_nil draft.html_version
    assert_not_equal pub.html_version, draft.html_version
  end

  test 'slugs are copied from previous html versions for editions' do
    editor = create(:gds_editor)
    pub = create(:draft_publication, html_version: build(:html_version, title: 'things'))
    pub.publish_as(editor, force: true)
    draft = pub.create_draft(editor)
    draft.change_note = 'Added html version'
    draft.save!

    hv = draft.html_version
    assert_equal pub.html_version.slug, hv.slug
  end
end
