class Locale < Struct.new(:code)
  class << self
    def all
      I18n.available_locales.map do |l|
        new(l)
      end
    end

    def non_english
      all - [Locale.new(:en)]
    end

    def find(native_language_name)
      all.find { |l| l.native_language_name == native_language_name }
    end
  end

  def native_language_name
    I18n.t("language_names.#{code}", locale: code)
  end

  def english_language_name
    I18n.t("language_names.#{code}", locale: :en)
  end

  def rtl?
    I18n.t("i18n.direction", locale: code, default: "ltr") == "rtl"
  end

  def to_param
    code.to_s
  end
end

