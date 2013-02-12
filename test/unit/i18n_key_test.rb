require "test_helper"

class I18nKeyTest < ActiveSupport::TestCase
  test "translations for all publication types are present" do
    assert_translations PublicationType, "document.type"
  end

  test "translations for all news article types are present" do
    assert_translations NewsArticleType, "document.type"
  end

  test "translations for all speech types are present" do
    assert_translation build(:speech, speech_type: SpeechType::WrittenStatement), "document.type", "statement_to_parliament"
    assert_translation build(:speech, speech_type: SpeechType::OralStatement), "document.type", "statement_to_parliament"
    assert_translations SpeechType, "document.type"
  end

  test "translations for all world location types are present" do
    assert_translations WorldLocationType, "world_location.type"
  end

  test "tranlsations for consultations are present" do
    assert_translation build(:open_consultation), "document.type"
    assert_translation build(:closed_consultation), "document.type"
    assert_translation create(:consultation_with_response), "document.type"
  end

  test "translations for misc other edition types are present" do
    assert_translation DetailedGuide.new, "document.type"
    assert_translation FatalityNotice.new, "document.type"
    assert_translation StatisticalDataSet.new, "document.type"
    assert_translation InternationalPriority.new, "document.type"
    assert_translation Policy.new, "document.type"
    assert_translation CaseStudy.new, "document.type"
  end

  private

  def assert_translations(type_class, translation_prefix)
    failed_types = []
    type_class.all.each do |type|
      begin
        I18n.t("#{translation_prefix}.#{type.key}")
      rescue => e
        failed_types << type
      end
    end
    if failed_types.any?
      flunk failed_types.map { |type| "No translation for #{type} (#{translation_prefix}.#{type.key})" }.to_sentence
    end
  end

  def assert_translation(instance, translation_prefix, specific_key=nil)
    key = specific_key || instance.display_type_key
    assert_nothing_raised("No translation for #{instance} (#{translation_prefix}.#{key})") do
      I18n.t("#{translation_prefix}.#{key}")
    end
  end
end
