# frozen_string_literal: true

require "test_helper"

class Admin::Editions::FirstPublishedAtComponentTest < ViewComponent::TestCase
  test "renders a hidden checkbox with the value set to false when the document can't set previously published and has never been published before" do
    edition = build(:worldwide_organisation)

    render_inline(Admin::Editions::FirstPublishedAtComponent.new(edition:, previously_published: false))

    assert_selector "input[type='hidden'][name='edition[previously_published]'][value='false']", visible: :hidden
    assert_selector ".govuk-checkboxes", count: 0
  end

  test "renders nothing when the document can't set previously published and has been published before" do
    edition = build(:published_worldwide_organisation)

    render_inline(Admin::Editions::FirstPublishedAtComponent.new(edition:, previously_published: true))

    assert_selector "input[type='hidden'][name='edition[previously_published]'][value='false']", visible: :hidden, count: 0
    assert_selector ".govuk-checkboxes", count: 0
    assert_selector ".govuk-fieldset", text: "First published", count: 0
  end

  test "when the document has never been published it renders with the correct fields" do
    edition = build(:publication)

    render_inline(Admin::Editions::FirstPublishedAtComponent.new(edition:, previously_published: false))

    assert_selector "input[type='hidden'][name='edition[previously_published]'][value='false']", visible: :hidden
    assert_selector ".govuk-checkboxes" do
      assert_selector "input[type='checkbox'][name='edition[previously_published]'][value='true']"
      assert_selector "input[type='checkbox'][name='edition[previously_published]'][value='true'][checked]", count: 0
      assert_selector "input[type='text'][name='edition[first_published_at(3i)]']"
      assert_selector "label[for=edition_first_published_at_3i]", text: "Day"
      assert_selector "input[type='text'][name='edition[first_published_at(2i)]']"
      assert_selector "label[for=edition_first_published_at_2i]", text: "Month"
      assert_selector "input[type='text'][name='edition[first_published_at(1i)]']"
      assert_selector "label[for=edition_first_published_at_1i]", text: "Year"
    end
  end

  test "when the document has not been published on GOV.UK but has been published on another website it checks the checkbox" do
    edition = build(:publication)

    render_inline(Admin::Editions::FirstPublishedAtComponent.new(edition:, previously_published: true))

    assert_selector "input[type='hidden'][name='edition[previously_published]'][value='false']", visible: :hidden
    assert_selector ".govuk-checkboxes" do
      assert_selector "input[type='checkbox'][name='edition[previously_published]'][value='true'][checked]"
      assert_selector "input[type='text'][name='edition[first_published_at(3i)]']"
      assert_selector "input[type='text'][name='edition[first_published_at(2i)]']"
      assert_selector "input[type='text'][name='edition[first_published_at(1i)]']"
    end
  end

  test "when a first published at date is passed into the component it assigns the correct values to the date inputs" do
    edition = build(:publication)

    render_inline(Admin::Editions::FirstPublishedAtComponent.new(
                    edition:,
                    previously_published: true,
                    year: 2022,
                    month: 10,
                    day: 1,
                  ))

    assert_selector "input[type='hidden'][name='edition[previously_published]'][value='false']", visible: :hidden
    assert_selector ".govuk-checkboxes" do
      assert_selector "input[type='checkbox'][name='edition[previously_published]'][value='true'][checked]"
      assert_selector "input[type='text'][name='edition[first_published_at(3i)]'][value='1']"
      assert_selector "input[type='text'][name='edition[first_published_at(2i)]'][value='10']"
      assert_selector "input[type='text'][name='edition[first_published_at(1i)]'][value='2022']"
    end
  end

  test "when a first published at datetime with hour and minute is passed into the component it assigns the correct values" do
    edition = build(:publication)

    render_inline(Admin::Editions::FirstPublishedAtComponent.new(
                    edition:,
                    previously_published: true,
                    year: 2022,
                    month: 10,
                    day: 1,
                    hour: 14,
                    minute: 30,
                  ))

    assert_selector "input[type='hidden'][name='edition[previously_published]'][value='false']", visible: :hidden
    assert_selector ".govuk-checkboxes" do
      assert_selector "input[type='checkbox'][name='edition[previously_published]'][value='true'][checked]"
      assert_selector "input[type='text'][name='edition[first_published_at(3i)]'][value='1']"
      assert_selector "input[type='text'][name='edition[first_published_at(2i)]'][value='10']"
      assert_selector "input[type='text'][name='edition[first_published_at(1i)]'][value='2022']"
      assert_selector "select[name='edition[first_published_at(4i)]']" do
        assert_selector "option[value='14'][selected]"
      end
      assert_selector "select[name='edition[first_published_at(5i)]']" do
        assert_selector "option[value='30'][selected]"
      end
    end
  end

  test "when a document has been published on GOV.UK it doesn't render a checkbox and assigns the correct values to the date inputs" do
    edition = build(:published_publication)

    render_inline(Admin::Editions::FirstPublishedAtComponent.new(
                    edition:,
                    previously_published: true,
                    year: 2022,
                    month: 10,
                    day: 1,
                  ))

    assert_selector "input[type='hidden'][name='edition[previously_published]'][value='false']", visible: :hidden, count: 0
    assert_selector ".govuk-fieldset", text: "First published" do
      assert_selector "input[type='text'][name='edition[first_published_at(3i)]'][value='1']"
      assert_selector "label[for=edition_first_published_at_3i]", text: "Day"
      assert_selector "input[type='text'][name='edition[first_published_at(2i)]'][value='10']"
      assert_selector "label[for=edition_first_published_at_2i]", text: "Month"
      assert_selector "input[type='text'][name='edition[first_published_at(1i)]'][value='2022']"
      assert_selector "label[for=edition_first_published_at_1i]", text: "Year"
    end
  end
end
