require "test_helper"

class I18nKeyTest < ActiveSupport::TestCase
  test "the default locale has values for all keys" do
    default_translation_data = YAML.load_file default_locale_file_path

    refute any_nil_values?(default_translation_data), "Default translation #{I18n.default_locale}.yml contains keys with nil values."
  end

  test "all locale files are up-to-date" do
    default_keys = keys_in_locale_file(default_locale_file_path)
    required_keys = default_keys - optional_keys
    locale_files = Dir[Rails.root.join('config', 'locales', '*.yml')] - [default_locale_file_path.to_s]

    locale_files.each do |locale_file|
      missing_keys = required_keys - keys_in_locale_file(locale_file)
      assert(missing_keys.empty?,
        "#{locale_file} is missing '#{missing_keys.join("', '")}'. Have you run " +
        "rake translation:regenerate to add any missing keys?")
    end
  end

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
    assert_translation create(:consultation_with_outcome), "document.type"
  end

  test "translations for misc other edition types are present" do
    assert_translation DetailedGuide.new, "document.type"
    assert_translation StatisticalDataSet.new, "document.type"
    assert_translation CaseStudy.new, "document.type"
  end

  private

  def assert_translations(type_class, translation_prefix)
    failed_types = []
    type_class.all.each do |type|
      begin
        I18n.t("#{translation_prefix}.#{type.key}", count: 1)
        I18n.t("#{translation_prefix}.#{type.key}", count: 2)
      rescue => e
        failed_types << type
      end
    end
    if failed_types.any?
      flunk failed_types.map { |type| "No translation for #{type} (#{translation_prefix}.#{type.key})" }.to_sentence
    end
  end

  def assert_translation(instance, translation_prefix, specific_key = nil)
    key = specific_key || instance.display_type_key
    assert_nothing_raised("No translation for #{instance} (#{translation_prefix}.#{key})") do
      I18n.t("#{translation_prefix}.#{key}", count: 1)
      I18n.t("#{translation_prefix}.#{key}", count: 2)
    end
  end

  def default_locale_file_path
    Rails.root.join('config', 'locales', "#{I18n.default_locale}.yml")
  end

  def any_nil_values?(hash)
    hash.detect {|k, v| v.nil? or (v.is_a?(Hash) && any_nil_values?(v)) }
  end

  def keys_in_locale_file(locale_file)
    yaml = YAML.load_file(locale_file)
    flatten_keys(yaml, [])
  end

  def optional_keys
    # These keys are optional, and the code will work around their absence
    [
      'corporate_information_page.type.link_text.about',
      'corporate_information_page.type.link_text.about_our_services',
      'corporate_information_page.type.link_text.access_and_opening',
      'corporate_information_page.type.link_text.complaints_procedure',
      'corporate_information_page.type.link_text.equality_and_diversity',
      'corporate_information_page.type.link_text.media_enquiries',
      'corporate_information_page.type.link_text.membership',
      'corporate_information_page.type.link_text.our_energy_use',
      'corporate_information_page.type.link_text.our_governance',
      'corporate_information_page.type.link_text.personal_information_charter',
      'corporate_information_page.type.link_text.petitions_and_campaigns',
      'corporate_information_page.type.link_text.procurement',
      'corporate_information_page.type.link_text.publication_scheme',
      'corporate_information_page.type.link_text.recruitment',
      'corporate_information_page.type.link_text.research',
      'corporate_information_page.type.link_text.social_media_use',
      'corporate_information_page.type.link_text.staff_update',
      'corporate_information_page.type.link_text.statistics',
      'corporate_information_page.type.link_text.terms_of_reference',
      'corporate_information_page.type.link_text.welsh_language_scheme',
    ]
  end

  def flatten_keys(hash, context)
    hash.map do |key, value|
      if context.size == 1 && key == "language_names"
        # don't care about language names, each language should define
        # its own language name and nothing more
        next
      elsif value.is_a?(Hash)
        flatten_keys(value, context + [key])
      else
        context[1..-1].join(".") << "." << key
      end
    end.flatten
  end
end
