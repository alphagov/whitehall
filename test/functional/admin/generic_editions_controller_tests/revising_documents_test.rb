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

  view_test "should not be possible to revise an archived edition" do
    archived_edition = create(:archived_edition)

    get :show, id: archived_edition

    refute_select "form[action='#{revise_admin_edition_path(archived_edition)}']"
  end
end