require "test_helper"

class EditionFormTestClass
  include CanScheduleOrPublish
  include I18n::Base

  attr_reader :params, :content_block_edition

  def initialize(content_block_edition, params)
    @content_block_edition = content_block_edition
    @params = params
  end

  def scheduled_publication_params
    {
      "scheduled_publication(1i)" => params["scheduled_publication(1i)"],
      "scheduled_publication(2i)" => params["scheduled_publication(2i)"],
      "scheduled_publication(3i)" => params["scheduled_publication(3i)"],
      "scheduled_publication(4i)" => params["scheduled_publication(4i)"],
      "scheduled_publication(5i)" => params["scheduled_publication(5i)"],
    }
  end
end

class ContentBlockManager::ContentBlock::EditionFormTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  def it_raises_a_validation_error(object, error_key)
    error = assert_raises ActiveRecord::RecordInvalid do
      object.validate_scheduled_edition
    end

    assert_equal 1, error.record.errors.messages.count
    assert_equal I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.attributes.#{error_key}"), error.record.errors.full_messages[0]
  end

  describe "#validate_scheduled_edition" do
    before do
      Timecop.freeze "2018-06-07"
    end

    let(:content_block_edition) { build(:content_block_edition, :email_address) }
    let(:object) { EditionFormTestClass.new(content_block_edition, params) }

    context "when date params are valid" do
      let(:params) do
        {
          schedule_publishing: "schedule",
          "scheduled_publication(1i)" => "2024",
          "scheduled_publication(2i)" => "1",
          "scheduled_publication(3i)" => "11",
          "scheduled_publication(4i)" => "11",
          "scheduled_publication(5i)" => "22",
        }
      end

      it "does not raise a validation error" do
        assert_nothing_raised do
          object.validate_scheduled_edition
        end
      end
    end

    context "when schedule_publishing is blank" do
      let(:params) do
        {
          schedule_publishing: "",
        }
      end

      it "raises a validation error" do
        it_raises_a_validation_error(object, "schedule_publishing.blank")
      end
    end

    context "when date and time params are missing" do
      let(:params) do
        {
          schedule_publishing: "schedule",
          "scheduled_publication(1i)" => "",
          "scheduled_publication(2i)" => "",
          "scheduled_publication(3i)" => "",
          "scheduled_publication(4i)" => "",
          "scheduled_publication(5i)" => "",
        }
      end

      it "raises a validation error" do
        it_raises_a_validation_error(object, "scheduled_publication.blank")
      end
    end

    context "when time params are missing" do
      let(:params) do
        {
          schedule_publishing: "schedule",
          "scheduled_publication(1i)" => "2024",
          "scheduled_publication(2i)" => "1",
          "scheduled_publication(3i)" => "11",
          "scheduled_publication(4i)" => "",
          "scheduled_publication(5i)" => "",
        }
      end

      it "raises a validation error" do
        it_raises_a_validation_error(object, "scheduled_publication.time.blank")
      end
    end

    context "when date params are missing" do
      let(:params) do
        {
          schedule_publishing: "schedule",
          "scheduled_publication(1i)" => "",
          "scheduled_publication(2i)" => "",
          "scheduled_publication(3i)" => "",
          "scheduled_publication(4i)" => "11",
          "scheduled_publication(5i)" => "22",
        }
      end

      it "raises a validation error" do
        it_raises_a_validation_error(object, "scheduled_publication.date.blank")
      end
    end

    context "when any datetime params are missing" do
      let(:params) do
        {
          schedule_publishing: "schedule",
          "scheduled_publication(1i)" => "2024",
          "scheduled_publication(2i)" => "",
          "scheduled_publication(3i)" => "",
          "scheduled_publication(4i)" => "11",
          "scheduled_publication(5i)" => "",
        }
      end

      it "raises a validation error" do
        it_raises_a_validation_error(object, "scheduled_publication.invalid_date")
      end
    end

    context "when the date params are invalid" do
      let(:params) do
        {
          schedule_publishing: "schedule",
          "scheduled_publication(1i)" => "2024",
          "scheduled_publication(2i)" => "ssss",
          "scheduled_publication(3i)" => "dddd",
          "scheduled_publication(4i)" => "11",
          "scheduled_publication(5i)" => "11",
        }
      end

      it "raises a validation error" do
        it_raises_a_validation_error(object, "scheduled_publication.invalid_date")
      end
    end

    context "when date params are in the past" do
      let(:params) do
        {
          schedule_publishing: "schedule",
          "scheduled_publication(1i)" => "1900",
          "scheduled_publication(2i)" => "1",
          "scheduled_publication(3i)" => "11",
          "scheduled_publication(4i)" => "11",
          "scheduled_publication(5i)" => "22",
        }
      end

      it "does not raise a validation error" do
        it_raises_a_validation_error(object, "scheduled_publication.future_date")
      end
    end
  end
end
