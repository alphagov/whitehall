require "test_helper"

class Admin::Editions::HistoryModeFormControlTest < ViewComponent::TestCase
  test "doesn't render unless document has a previously published edition" do
    edition = create(:draft_news_article)
    render_inline(Admin::Editions::HistoryModeFormControl.new(edition:, current_user: create(:managing_editor)))

    assert page.text.blank?
  end

  test "doesn't render if the edition cannot be marked political" do
    previous_edition = create(:published_fatality_notice)
    edition = create(:draft_fatality_notice, document: previous_edition.document)

    render_inline(Admin::Editions::HistoryModeFormControl.new(edition:, current_user: create(:managing_editor)))

    assert page.text.blank?
  end

  test "does not render if the user does not have permission to mark documents as political" do
    previous_edition = create(:published_news_article)
    edition = create(:draft_news_article, document: previous_edition.document)

    render_inline(Admin::Editions::HistoryModeFormControl.new(edition:, current_user: create(:writer)))

    assert page.text.blank?
  end

  test "renders government selector when user has permission to override government" do
    previous_edition = create(:published_news_article)
    edition = create(:draft_news_article, document: previous_edition.document)
    governments = [create(:current_government), create(:previous_government)]

    render_inline(Admin::Editions::HistoryModeFormControl.new(edition:, current_user: create(:gds_editor)))

    assert_selector "select#edition_political[name='edition[government_id]']"
    governments.each do |government|
      assert_selector "select#edition_political[name='edition[government_id]'] option[value='#{government.id}']"
    end
  end

  test "displays selected government when edition is associated with government" do
    government = create(:current_government)
    previous_edition = create(:published_news_article)
    edition = create(:draft_news_article, document: previous_edition.document, government:)

    render_inline(Admin::Editions::HistoryModeFormControl.new(edition:, current_user: create(:gds_editor)))

    assert_selector "select#edition_political[name='edition[government_id]']"
    assert_selector "select#edition_political[name='edition[government_id]'] option[value='#{government.id}'][selected='selected']"
  end

  test "renders political checkbox and hidden default input when user does not have permission to override government" do
    create(:current_government)
    previous_edition = create(:published_news_article)
    edition = create(:draft_news_article, document: previous_edition.document)

    render_inline(Admin::Editions::HistoryModeFormControl.new(edition:, current_user: create(:managing_editor)))

    assert_selector "input[type='hidden'][name='edition[government_id]'][value='']", { visible: false }
    assert_selector "#edition_political input[type='checkbox']"
  end

  test "sets political checkbox value to edition's default government ID when it doesn't have an associated government" do
    create(:government, start_date: 3.years.ago, end_date: 1.year.ago)
    previous_edition = create(:published_news_article)
    edition = create(:draft_news_article, document: previous_edition.document, first_published_at: 2.years.ago)

    render_inline(Admin::Editions::HistoryModeFormControl.new(edition:, current_user: create(:managing_editor)))

    assert_selector "#edition_political input[type='checkbox'][value='#{edition.default_government.id}']"
  end

  test "checks box and sets value to associated government ID when edition has associated government" do
    government = create(:government, start_date: 3.years.ago, end_date: 1.year.ago)
    previous_edition = create(:published_news_article)
    edition = create(:draft_news_article, document: previous_edition.document, government:)

    render_inline(Admin::Editions::HistoryModeFormControl.new(edition:, current_user: create(:managing_editor)))

    assert_selector "#edition_political input[type='checkbox'][value='#{edition.government.id}'][checked='checked']"
  end
end
