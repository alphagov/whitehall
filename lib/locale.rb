Translations = Class.new

ENGLISH_LOCALE_CODE = :en

Locale = Struct.new(:code) do
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :languages

  def initialize(code)
    super(code.to_sym)
    @languages = Locale.load_language_configs
  end

  def self.load_language_configs
    @load_language_configs ||= YAML.load_file(Rails.root.join("config/languages.yml"))
  end

  def self.model_name
    ActiveModel::Name.new(Translations)
  end

  def self.current
    new(I18n.locale)
  end

  def self.all
    load_language_configs.keys.map do |l|
      new(l)
    end
  end

  def self.all_keys
    load_language_configs.keys
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
      raise ArgumentError, "Could not coerce #{value.inspect} to a Locale"
    end
  end

  def english?
    code == ENGLISH_LOCALE_CODE
  end

  def native_language_name
    languages[code.to_s]["native_name"]
  end

  def english_language_name
    languages[code.to_s]["english_name"]
  end

  def native_and_english_language_name
    "#{native_language_name} (#{english_language_name})"
  end

  def rtl?
    languages[code.to_s]["direction"] == "rtl"
  end

  def to_param
    code.to_s
  end

  def persisted?
    true
  end
end
