require "test_helper"

class ParamsPreprocessors::TelephonePreprocessorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:opening_hours) do
    [
      {
        "day_from" => "Monday",
        "day_to" => "Friday",
        "time_from(h)" => "9",
        "time_from(m)" => "00",
        "time_from(meridian)" => "AM",
        "time_to(h)" => "5",
        "time_to(m)" => "30",
        "time_to(meridian)" => "PM",
        "_destroy" => "0",
      },
    ]
  end

  let(:details) do
    {
      "telephones" => {
        "opening_hours" => opening_hours,
      },
    }
  end

  let(:params) do
    {
      "hours_available" => hours_available,
      "content_block/edition" => {
        "details" => details,
      },
    }
  end

  describe "when hours_available is set" do
    let(:hours_available) { "1" }

    it "formats the opening hours correctly" do
      result = ParamsPreprocessors::TelephonePreprocessor.new(params).processed_params
      expected_result = {
        "hours_available" => "1",
        "content_block/edition" => {
          "details" => {
            "telephones" => {
              "opening_hours" => [
                {
                  "day_from" => "Monday",
                  "day_to" => "Friday",
                  "time_from" => "9:00AM",
                  "time_to" => "5:30PM",
                  "_destroy" => "0",
                },
              ],
            },
          },
        },
      }

      assert_equal result, expected_result
    end
  end

  describe "when hours_available is not set" do
    let(:hours_available) { nil }

    it "clears the opening_hours array" do
      result = ParamsPreprocessors::TelephonePreprocessor.new(params).processed_params
      expected_result = {
        "hours_available" => nil,
        "content_block/edition" => {
          "details" => {
            "telephones" => {
              "opening_hours" => [],
            },
          },
        },
      }

      assert_equal result, expected_result
    end
  end
end
