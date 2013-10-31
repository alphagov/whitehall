require 'test_helper'

class Admin::GenericEditionsController::RevisingDocumentsTest < ActionController::TestCase
  tests Admin::GenericEditionsController

  setup do
    login_as :policy_writer
  end

  view_test "should be possible to revise a published edition" do
    published_edition = create(:published_edition)

    get :show, id: published_edition

    assert_select "form[action='#{revise_admin_edition_path(published_edition)}']"
  end

  view_test "should not be possible to revise a draft edition" do
    draft_edition = create(:draft_edition)

    get :show, id: draft_edition

    refute_select "form[action='#{revise_admin_edition_path(draft_edition)}']"
  end

  view_test "should not be possible to revise an superseded edition" do
    superseded_edition = create(:superseded_edition)

    get :show, id: superseded_edition

    refute_select "form[action='#{revise_admin_edition_path(superseded_edition)}']"
  end

  view_test "show for a new draft links back to its published edition" do
    original_edition = create(:published_edition)
    new_draft = original_edition.create_draft(create(:policy_writer))

    get :show, id: new_draft

    assert_select ".alert a", href: Whitehall.url_maker.admin_edition_path(original_edition)
  end

  view_test "show for a published edition links to a new draft" do
    original_edition = create(:published_edition)
    new_draft = original_edition.create_draft(create(:policy_writer))

    get :show, id: original_edition

    assert_select ".alert a", href: Whitehall.url_maker.admin_edition_path(new_draft)
  end
end

