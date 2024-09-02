require "test_helper"

class Admin::Editions::HistoryModeFormControlsTest < ViewComponent::TestCase
  setup do
    @test_strategy = Flipflop::FeatureSet.current.test!
  end

  test "hides the government selector for GDS editor users when the feature flag is disabled" do
    @test_strategy.switch!(:override_government, false)
    government = create(:current_government)
    published_edition = create(:published_news_article, government_id: government.id)
    new_draft = create(:news_article, document: published_edition.document, government_id: government.id)
    render_inline(Admin::Editions::HistoryModeFormControls.new(new_draft, create(:gds_editor)))
    assert_selector "select#edition_government_id", count: 0
  end

  test "conditionally displays the government selector for gds editor users" do
    @test_strategy.switch!(:override_government, true)
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
    @test_strategy.switch!(:override_government, true)
    published_edition = create(:published_news_article)
    new_draft = create(:news_article, document: published_edition.document)
    render_inline(Admin::Editions::HistoryModeFormControls.new(new_draft, create(:managing_editor)))
    assert_selector "input[name='edition[political]'][value='0']", visible: false
  end

  test "displays the political checkbox for managing editor users " do
    @test_strategy.switch!(:override_government, true)
    published_edition = create(:published_news_article)
    new_draft = create(:news_article, document: published_edition.document)
    render_inline(Admin::Editions::HistoryModeFormControls.new(new_draft, create(:managing_editor)))
    assert_selector "#edition_political"
  end

  test "doesn't display the government selector for managing editor users " do
    @test_strategy.switch!(:override_government, true)
    published_edition = create(:published_news_article)
    new_draft = create(:news_article, document: published_edition.document)
    render_inline(Admin::Editions::HistoryModeFormControls.new(new_draft, create(:managing_editor)))
    assert_selector "select#edition_government_id", count: 0
  end

  test "doesn't display the political checkbox for writer users " do
    @test_strategy.switch!(:override_government, true)
    published_edition = create(:published_news_article)
    new_draft = create(:news_article, document: published_edition.document)
    render_inline(Admin::Editions::HistoryModeFormControls.new(new_draft, create(:writer)))
    assert_selector "#edition_political", count: 0
  end

  test "doesn't display the political checkbox on creation" do
    @test_strategy.switch!(:override_government, true)
    new_draft = create(:news_article)
    render_inline(Admin::Editions::HistoryModeFormControls.new(new_draft, create(:managing_editor)))
    assert_selector "#edition_political", count: 0
  end
end
