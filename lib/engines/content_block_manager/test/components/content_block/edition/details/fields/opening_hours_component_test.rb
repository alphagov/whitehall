require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHoursComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :pension) }
  let(:field) { stub("field", name: "items", is_required?: true) }
  let(:field_value) { nil }

  let(:days) { ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHours::ItemComponent::DAYS }
  let(:hours) { ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHours::ItemComponent::HOURS }
  let(:minutes) { ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHours::ItemComponent::MINUTES }
  let(:meridian) { ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHours::ItemComponent::MERIDIAN }

  let(:component) do
    ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHoursComponent.new(
      content_block_edition:,
      field:,
      value: field_value,
    )
  end

  describe "when there are no items present" do
    it "renders with one empty item and a template" do
      render_inline component

      assert_selector ".govuk-checkboxes__conditional" do |conditional|
        conditional.assert_selector ".gem-c-add-another" do |component|
          component.assert_selector ".js-add-another__fieldset", count: 1
          component.assert_selector ".js-add-another__empty", count: 1

          component.assert_selector ".js-add-another__fieldset", text: /Opening Hour 1/ do |fieldset|
            expect_form_fields(fieldset, 0)
          end

          component.assert_selector ".js-add-another__empty", text: /Opening Hour 2/ do |fieldset|
            expect_form_fields(fieldset, 1)
          end
        end
      end
    end
  end

  describe "when there are items present" do
    let(:field_value) do
      [
        {
          "day_from" => "Tuesday",
          "day_to" => "Friday",
          "time_from" => "9:30AM",
          "time_to" => "5:45PM",
        },
        {
          "day_from" => "Saturday",
          "day_to" => "Sunday",
          "time_from" => "12:00PM",
          "time_to" => "3:00PM",
        },
      ]
    end

    it "renders a fieldset for each item and a template" do
      render_inline component

      assert_selector ".govuk-checkboxes__conditional" do |conditional|
        conditional.assert_selector ".gem-c-add-another" do |component|
          component.assert_selector ".js-add-another__fieldset", count: 2
          component.assert_selector ".js-add-another__empty", count: 1

          component.assert_selector ".js-add-another__fieldset", text: "Opening Hour 1" do |fieldset|
            expect_form_fields(fieldset, 0)

            fieldset.assert_selector "select[name='content_block/edition[details][items][][day_from]'] option[value='Tuesday'][selected]"
            fieldset.assert_selector "select[name='content_block/edition[details][items][][day_to]'] option[value='Friday'][selected]"

            fieldset.assert_selector "select[name='content_block/edition[details][items][][time_from(h)]'] option[value='9'][selected]"
            fieldset.assert_selector "select[name='content_block/edition[details][items][][time_from(m)]'] option[value='30'][selected]"
            fieldset.assert_selector "select[name='content_block/edition[details][items][][time_from(meridian)]'] option[value='AM'][selected]"

            fieldset.assert_selector "select[name='content_block/edition[details][items][][time_to(h)]'] option[value='5'][selected]"
            fieldset.assert_selector "select[name='content_block/edition[details][items][][time_to(m)]'] option[value='45'][selected]"
            fieldset.assert_selector "select[name='content_block/edition[details][items][][time_to(meridian)]'] option[value='PM'][selected]"
          end

          component.assert_selector ".js-add-another__fieldset", text: "Opening Hour 2" do |fieldset|
            expect_form_fields(fieldset, 1)

            fieldset.assert_selector "select[name='content_block/edition[details][items][][day_from]'] option[value='Saturday'][selected]"
            fieldset.assert_selector "select[name='content_block/edition[details][items][][day_to]'] option[value='Sunday'][selected]"

            fieldset.assert_selector "select[name='content_block/edition[details][items][][time_from(h)]'] option[value='12'][selected]"
            fieldset.assert_selector "select[name='content_block/edition[details][items][][time_from(m)]'] option[value='00'][selected]"
            fieldset.assert_selector "select[name='content_block/edition[details][items][][time_from(meridian)]'] option[value='PM'][selected]"

            fieldset.assert_selector "select[name='content_block/edition[details][items][][time_to(h)]'] option[value='3'][selected]"
            fieldset.assert_selector "select[name='content_block/edition[details][items][][time_to(m)]'] option[value='00'][selected]"
            fieldset.assert_selector "select[name='content_block/edition[details][items][][time_to(meridian)]'] option[value='PM'][selected]"
          end

          component.assert_selector ".js-add-another__empty", text: "Opening Hour 3" do |fieldset|
            expect_form_fields(fieldset, 2)
          end
        end
      end
    end
  end

private

  def expect_form_fields(fieldset, index)
    fieldset.assert_selector ".govuk-fieldset__legend", text: "Opening Hour #{index + 1}"
    fieldset.assert_selector ".app-c-content-block-manager-opening-hours-item-component" do |component|
      component.assert_selector ".govuk-fieldset", text: "Days" do |days_fieldset|
        days_fieldset.assert_selector "select#content_block_manager_content_block_edition_details_items_#{index}_day_from" do |select|
          days.each do |day|
            select.assert_selector "option[value='#{day}']", text: day
          end
        end

        days_fieldset.assert_selector "select#content_block_manager_content_block_edition_details_items_#{index}_day_to" do |select|
          days.each do |day|
            select.assert_selector "option[value='#{day}']", text: day
          end
        end
      end

      component.assert_selector ".govuk-fieldset", text: "Time" do |time_fieldset|
        %w[from to].each do |from_to|
          time_fieldset.assert_selector "select#content_block_manager_content_block_edition_details_items_#{index}_time_#{from_to}_h" do |select|
            hours.each do |hour|
              select.assert_selector "option[value='#{hour}']", text: hour
            end
          end

          time_fieldset.assert_selector "select#content_block_manager_content_block_edition_details_items_#{index}_time_#{from_to}_m" do |select|
            minutes.each do |minute|
              select.assert_selector "option[value='#{minute}']", text: minute
            end
          end

          time_fieldset.assert_selector "select#content_block_manager_content_block_edition_details_items_#{index}_time_#{from_to}_meridian" do |select|
            meridian.each do |am_pm|
              select.assert_selector "option[value='#{am_pm}']", text: am_pm
            end
          end
        end
      end
    end
  end
end
