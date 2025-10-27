require "component_test_helper"

class DatetimefieldsComponentTest < ComponentTestCase
  def component_name
    "datetime_fields"
  end

  test "renders the basic component" do
    render_component({
      prefix: "prefix",
      field_name: "field_name",
    })

    assert_select ".app-c-datetime-fields"
    assert_select "h3.govuk-fieldset__heading", text: "Date (required)"
    assert_select ".govuk-input[name='day']"
    assert_select ".govuk-input[name='month']"
    assert_select ".govuk-input[name='year']"
    assert_select "h3.govuk-fieldset__heading", text: "Time"
    assert_select ".govuk-label", text: "Hour"
    assert_select ".govuk-label", text: "Minute"
  end

  test "accepts an id" do
    render_component({
      prefix: "prefix",
      field_name: "field_name",
      id: "kevin",
    })

    assert_select "[id='kevin']"
    assert_select ".govuk-date-input[id='kevin_date']"
  end

  test "allows a different date heading, heading level and size" do
    render_component({
      prefix: "prefix",
      field_name: "field_name",
      date_heading: "i am heading",
      heading_level: 1,
      heading_size: "l",
    })

    assert_select "h1.govuk-fieldset__heading", text: "i am heading"
    assert_select "h1.govuk-fieldset__heading", text: "Time"
  end

  test "shows hint text" do
    render_component({
      prefix: "prefix",
      field_name: "field_name",
      date_hint: "For example, 01 August 2022",
      time_hint: "For example, 09:30 or 19:30",
    })

    assert_select ".govuk-hint", text: "For example, 01 August 2022"
    assert_select ".govuk-hint", text: "For example, 09:30 or 19:30"
  end

  test "renders custom date fields" do
    render_component({
      prefix: "prefix",
      field_name: "field_name",
      year: {
        id: "year_id",
        name: "year_name",
        width: 4,
        value: "2024",
      },
      month: {
        id: "month_id",
        name: "month_name",
        width: 3,
        value: "1",
      },
      day: {
        id: "day_id",
        name: "day_name",
        width: 2,
        value: "14",
      },
    })

    assert_select ".govuk-input.govuk-input--width-4[id='year_id'][name='year_name'][value='2024']"
    assert_select ".govuk-input.govuk-input--width-3[id='month_id'][name='month_name'][value='1']"
    assert_select ".govuk-input.govuk-input--width-2[id='day_id'][name='day_name'][value='14']"
  end

  test "accepts values and ids for hour and minute elements" do
    render_component({
      prefix: "prefix",
      field_name: "field_name",
      hour: {
        value: 2,
        id: "my-hour-id",
      },
      minute: {
        value: 3,
        id: "my-minute-id",
      },
    })

    assert_select "select[id='my-hour-id'] option[value='02'][selected='selected']"
    assert_select "select[id='my-minute-id'] option[value='03'][selected='selected']"
  end

  test "errors if hour data is incorrect" do
    assert_raises do
      render_component({
        prefix: "prefix",
        field_name: "field_name",
        hour: "oops",
      })
    end
  end

  test "errors if minute data is incorrect" do
    assert_raises do
      render_component({
        prefix: "prefix",
        field_name: "field_name",
        minute: "sorry",
      })
    end
  end

  test "renders error fields" do
    render_component({
      prefix: "prefix",
      field_name: "field_name",
      error_items: [
        {
          text: "Descriptive error 1",
        },
        {
          text: "Descriptive error 2",
        },
      ],
    })

    assert_select ".app-c-datetime-fields.govuk-form-group--error"
    assert_select ".govuk-form-group--error .govuk-error-message", text: "Error: Descriptive error 1Descriptive error 2"
  end

  test "accepts data attributes" do
    render_component({
      prefix: "prefix",
      field_name: "field_name",
      data_attributes: {
        module: "not-a-real-module",
        something_else: "i-just-thought-of",
      },
    })

    assert_select ".app-c-datetime-fields[data-module='not-a-real-module'][data-something-else='i-just-thought-of']"
  end

  test "with date only option" do
    render_component({
      prefix: "prefix",
      field_name: "field_name",
      date_only: true,
    })

    assert_select ".govuk-input[name='day']"
    assert_select ".govuk-input[name='month']"
    assert_select ".govuk-input[name='year']"
    assert_select ".app-c-datetime-fields__date-time-wrapper", false
  end
end
