# frozen_string_literal: true

require "test_helper"

class Admin::DatetimeComponentTest < ViewComponent::TestCase
  test "builds the name of the select inputs based on the class of the object" do
    consultation = create(:consultation)

    render_inline(
      Admin::DatetimeComponent.new(
        object: consultation,
        field_name: "first_published_at",
      ),
    )

    assert_selector "select[name='consultation[first_published_at(1i)]']"
    assert_selector "select[name='consultation[first_published_at(2i)]']"
    assert_selector "select[name='consultation[first_published_at(3i)]']"
    assert_selector "select[name='consultation[first_published_at(4i)]']"
    assert_selector "select[name='consultation[first_published_at(5i)]']"
  end

  test "overrides the name of the select inputs with a prefix if one is passed in" do
    consultation = create(:consultation)

    render_inline(
      Admin::DatetimeComponent.new(
        object: consultation,
        field_name: "first_published_at",
        prefix: "edition",
      ),
    )

    assert_selector "select[name='edition[first_published_at(1i)]']"
    assert_selector "select[name='edition[first_published_at(2i)]']"
    assert_selector "select[name='edition[first_published_at(3i)]']"
    assert_selector "select[name='edition[first_published_at(4i)]']"
    assert_selector "select[name='edition[first_published_at(5i)]']"
  end

  test "renders a blank set of datetime inputs when the relevant datetime field on the object passed in is nil" do
    edition = build_stubbed(:edition, first_published_at: nil)
    render_inline(
      Admin::DatetimeComponent.new(
        object: edition,
        field_name: "first_published_at",
      ),
    )

    assert_equal page.all("h3")[0].text, "Date"
    assert_equal page.all("label")[0].text, "Day"
    assert_equal page.all("select")[0].value, ""
    assert_equal page.all("label")[1].text, "Month"
    assert_equal page.all("select")[1].value, ""
    assert_equal page.all("label")[2].text, "Year"
    assert_equal page.all("select")[2].value, ""

    assert_equal page.all("h3")[1].text, "Time"
    assert_equal page.all("label")[3].text, "Hour"
    assert_equal page.all("select")[3].value, ""
    assert_equal page.all("label")[4].text, "Minute"
    assert_equal page.all("select")[4].value, ""
  end

  test "populates the datetime fields when a relevant datetime field on the object has a value" do
    edition = build_stubbed(:edition, first_published_at: Time.zone.local(2020, 1, 1, 12, 30))

    render_inline(
      Admin::DatetimeComponent.new(
        object: edition,
        field_name: "first_published_at",
      ),
    )

    assert_equal page.all("select")[0].value, "1"
    assert_equal page.all("select")[1].value, "1"
    assert_equal page.all("select")[2].value, "2020"
    assert_equal page.all("select")[3].value, "12"
    assert_equal page.all("select")[4].value, "30"
  end

  test "populates the datetime fields with a default date if one is passed in and the relevant datetime field on the object is nil" do
    edition = build_stubbed(:edition, first_published_at: nil)

    render_inline(
      Admin::DatetimeComponent.new(
        object: edition,
        field_name: "first_published_at",
        default_date: Time.zone.local(2022, 2, 2, 11, 45),
      ),
    )

    assert_equal page.all("select")[0].value, "2"
    assert_equal page.all("select")[1].value, "2"
    assert_equal page.all("select")[2].value, "2022"
    assert_equal page.all("select")[3].value, "11"
    assert_equal page.all("select")[4].value, "45"
  end

  test "prioritises the relevant datetime fields value over a default date" do
    edition = build_stubbed(:edition, first_published_at: Time.zone.local(2020, 1, 1, 12, 30))

    render_inline(
      Admin::DatetimeComponent.new(
        object: edition,
        field_name: "first_published_at",
        default_date: Time.zone.local(2022, 2, 2, 11, 45),
      ),
    )

    assert_equal page.all("select")[0].value, "1"
    assert_equal page.all("select")[1].value, "1"
    assert_equal page.all("select")[2].value, "2020"
    assert_equal page.all("select")[3].value, "12"
    assert_equal page.all("select")[4].value, "30"
  end

  test "uses the start year and and year to populate the year fields options if passed in" do
    edition = build_stubbed(:edition, first_published_at: Time.zone.local(2020, 1, 1, 12, 30))

    render_inline(
      Admin::DatetimeComponent.new(
        object: edition,
        field_name: "first_published_at",
        start_year: 1999,
        end_year: 2022,
      ),
    )

    [*1999..2022].each do |year|
      assert_selector "option[value='#{year}']", count: 1
    end

    assert_selector "option[value='2023']", count: 0
    assert_selector "option[value='1998']", count: 0
  end
end
