require "test_helper"

class Admin::Editions::HistoryModeFormControlsTest < ViewComponent::TestCase
  test "conditionally displays the government selector for gds editor users" do
    previous_government = create(:previous_government)
    governments = [create(:current_government), previous_government]
    published_edition = create(:published_news_article, government_id: previous_government.id)
    new_draft = create(:news_article, document: published_edition.document, government_id: previous_government.id)
    render_inline(Admin::Editions::HistoryModeFormControls.new(new_draft, create(:gds_editor)))
    assert_selector "#edition_political-0-conditional-0 select#edition_government_id"
    assert_selector "option[value='']"
    governments.each do |government|
      assert_selector "option[value='#{government.id}']"
    end
    assert_selector "option[value='#{previous_government.id}'][selected='selected']"
  end

  test "displays a hidden political input set to false for managing editor users " do
    published_edition = create(:published_news_article)
    new_draft = create(:news_article, document: published_edition.document)
    render_inline(Admin::Editions::HistoryModeFormControls.new(new_draft, create(:managing_editor)))
    assert_selector "input[name='edition[political]'][value='0']", visible: false
  end

  test "displays the political checkbox for managing editor users " do
    published_edition = create(:published_news_article)
    new_draft = create(:news_article, document: published_edition.document)
    render_inline(Admin::Editions::HistoryModeFormControls.new(new_draft, create(:managing_editor)))
    assert_selector "#edition_political"
  end

  test "doesn't display the government selector for managing editor users " do
    published_edition = create(:published_news_article)
    new_draft = create(:news_article, document: published_edition.document)
    render_inline(Admin::Editions::HistoryModeFormControls.new(new_draft, create(:managing_editor)))
    assert_selector "select#edition_government_id", count: 0
  end

  test "doesn't display the political checkbox for writer users " do
    published_edition = create(:published_news_article)
    new_draft = create(:news_article, document: published_edition.document)
    render_inline(Admin::Editions::HistoryModeFormControls.new(new_draft, create(:writer)))
    assert_selector "#edition_political", count: 0
  end

  test "doesn't display the political checkbox on creation" do
    new_draft = create(:news_article)
    render_inline(Admin::Editions::HistoryModeFormControls.new(new_draft, create(:managing_editor)))
    assert_selector "#edition_political", count: 0
  end
end
