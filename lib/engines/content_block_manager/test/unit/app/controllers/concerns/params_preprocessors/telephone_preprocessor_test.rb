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

  let(:show_call_charges_info_url) { "true" }
  let(:show_video_relay_service) { "true" }
  let(:show_bsl_guidance) { "true" }

  let(:hours_available) { "1" }

  let(:call_charges) do
    {
      "show_call_charges_info_url" => show_call_charges_info_url,
      "label" => "Label",
      "call_charges_info_url" => "https://example.com",
    }
  end

  let(:bsl_guidance) do
    {
      "show" => show_bsl_guidance,
      "value" => "Some value",
    }
  end

  let(:video_relay_service) do
    {
      "show" => show_video_relay_service,
      "telephone_number_prefix" => "**Custom** prefix 121212 then",
      "telephone_number" => "1234 123 1234",
    }
  end

  let(:details) do
    {
      "telephones" => {
        "video_relay_service" => video_relay_service,
        "opening_hours" => opening_hours,
        "call_charges" => call_charges,
        "bsl_guidance" => bsl_guidance,
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

  describe "opening hours processing" do
    describe "when hours_available is set" do
      let(:hours_available) { "1" }

      it "formats the opening hours correctly" do
        result = ParamsPreprocessors::TelephonePreprocessor.new(params).processed_params

        assert_equal result["hours_available"], "1"
        assert_equal result["content_block/edition"]["details"]["telephones"]["opening_hours"], [
          {
            "day_from" => "Monday",
            "day_to" => "Friday",
            "time_from" => "9:00AM",
            "time_to" => "5:30PM",
            "_destroy" => "0",
          },
        ]
      end
    end

    describe "when hours_available is not set" do
      let(:hours_available) { nil }

      it "clears the opening_hours array" do
        result = ParamsPreprocessors::TelephonePreprocessor.new(params).processed_params

        assert_equal result["hours_available"], nil
        assert_equal result["content_block/edition"]["details"]["telephones"]["opening_hours"], []
      end
    end
  end

  describe "call charges processing" do
    describe "when show_call_charges_info_url is set to a `true` string" do
      let(:show_call_charges_info_url) { "true" }

      it "converts the string to a boolean" do
        result = ParamsPreprocessors::TelephonePreprocessor.new(params).processed_params

        assert_equal result["content_block/edition"]["details"]["telephones"]["call_charges"], {
          "show_call_charges_info_url" => true,
          "label" => "Label",
          "call_charges_info_url" => "https://example.com",
        }
      end
    end

    describe "when show_call_charges_info_url is empty" do
      let(:show_call_charges_info_url) { "" }

      it "empties the call charges object" do
        result = ParamsPreprocessors::TelephonePreprocessor.new(params).processed_params

        assert_equal result["content_block/edition"]["details"]["telephones"]["call_charges"], {}
      end
    end
  end

  describe "BSL guidance preprocessing" do
    describe "when show is set to a `true` string" do
      let(:show_bsl_guidance) { "true" }

      it "converts the string to a boolean" do
        result = ParamsPreprocessors::TelephonePreprocessor.new(params).processed_params

        assert_equal result["content_block/edition"]["details"]["telephones"]["bsl_guidance"], {
          "show" => true,
          "value" => "Some value",
        }
      end
    end

    describe "when show_call_charges_info_url is empty" do
      let(:show_bsl_guidance) { "" }

      it "empties the BSL Guidance object" do
        result = ParamsPreprocessors::TelephonePreprocessor.new(params).processed_params

        assert_equal result["content_block/edition"]["details"]["telephones"]["bsl_guidance"], {}
      end
    end
  end

  describe "processing of 'video relay service' object" do
    describe "when 'show' is set to a `true` string" do
      let(:show_video_relay_service) { "true" }

      it "converts the string to a boolean" do
        result = ParamsPreprocessors::TelephonePreprocessor.new(params).processed_params

        assert_equal(
          {
            "show" => true,
            "telephone_number_prefix" => "**Custom** prefix 121212 then",
            "telephone_number" => "1234 123 1234",
          },
          result["content_block/edition"]["details"]["telephones"]["video_relay_service"],
        )
      end
    end

    describe "when 'show' is set to a `false` string" do
      let(:show_video_relay_service) { "false" }

      it "empties the video relay service object" do
        result = ParamsPreprocessors::TelephonePreprocessor.new(params).processed_params

        assert_equal(
          {},
          result["content_block/edition"]["details"]["telephones"]["video_relay_service"],
        )
      end
    end

    describe "when 'show' is empty" do
      let(:show_video_relay_service) { "" }

      it "empties the video relay service object" do
        result = ParamsPreprocessors::TelephonePreprocessor.new(params).processed_params

        assert_equal(
          {},
          result["content_block/edition"]["details"]["telephones"]["video_relay_service"],
        )
      end
    end
  end
end
