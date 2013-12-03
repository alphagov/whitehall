Translations = Class.new
class Locale < Struct.new(:code)
  ENGLISH_LOCALE_CODE = :en

  extend ActiveModel::Naming

  def initialize(code)
    super(code.to_sym)
  end

  def self.model_name
    ActiveModel::Name.new(Translations)
  end

  def self.current
    new(I18n.locale)
  end

  def self.all
    I18n.available_locales.map do |l|
      new(l)
    end
  end

  def self.non_english
    all.reject(&:english?)
  end

  def self.right_to_left
    all.select(&:rtl?)
  end

  def self.find_by_language_name(native_language_name)
    all.detect { |l| l.native_language_name == native_language_name }
  end

  def self.find_by_code(code)
    all.detect { |l| l.code == code.to_sym }
  end

  def self.coerce(value)
    case value
    when Symbol, String
      Locale.new(value)
    when Locale
      value
    else
      raise ArgumentError.new("Could not coerce #{value.inspect} to a Locale")
    end
  end

  def english?
    code == ENGLISH_LOCALE_CODE
  end

  def native_language_name
    I18n.t("language_names.#{code}", locale: code)
  end

  def english_language_name
    I18n.t("language_names.#{code}", locale: ENGLISH_LOCALE_CODE)
  end

  def native_and_english_language_name
    "#{native_language_name} (#{english_language_name})"
  end

  def rtl?
    I18n.t("i18n.direction", locale: code, default: "ltr") == "rtl"
  end

  def to_param
    code.to_s
  end
end

