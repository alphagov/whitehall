require 'test_helper'

class Edition::HtmlVersionsTest < ActiveSupport::TestCase
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
