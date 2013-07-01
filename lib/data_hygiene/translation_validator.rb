require 'yaml'

module DataHygiene
  class TranslationValidator
    def initialize(translation_file_path, logger = Logger.new(nil))
      @translation_file_path = translation_file_path
      @logger = logger
    end

    def check!
      @logger.info "Checking translation files in '#{@translation_file_path}' for unexpected interpolation keys"
      @logger.info "Loading reference file (#{reference_file_name})"
      @logger.info "Checking..."
      reference = load_translation_file("#{@translation_file_path}/#{reference_file_name}")
      Dir["#{@translation_file_path}/*.yml"].reject do |entry|
        File.basename(entry) == reference_file_name
      end.inject([]) do |errors, entry|
        translation_file = load_translation_file(entry)
        errors + unexpected_substitution_keys(reference, translation_file)
      end
    end

    def unexpected_substitution_keys(reference, translation_file)
      reference_substitutions = substitutions_in(reference)
      target_substitutions = substitutions_in(translation_file)

      targets_by_path = target_substitutions.each_with_object({}) do |target, hash|
        hash[exclude_locale_from_path(target.path)] = target
      end

      reference_substitutions.each_with_object([]) do |reference, unexpected_substitutions|
        target = targets_by_path[exclude_locale_from_path(reference.path)]
        next if target.nil? || reference.has_all_substitutions?(target)
        unexpected_substitutions << UnexpectedSubstition.new(target, reference)
      end
    end

    def substitutions_in(translation_file)
      flatten(translation_file).reject do |translation|
        translation.substitutions.empty?
      end
    end

    class TranslationEntry < Struct.new(:path, :value)
      def substitutions
        @substitutions ||= self.value.scan(/%{([^}]*)}/)
      end

      def has_all_substitutions?(other)
        (other.substitutions - self.substitutions).empty?
      end
    end

    class UnexpectedSubstition < Struct.new(:target, :reference)
      def to_s
        missing = (self.reference.substitutions - self.target.substitutions)
        extras = (self.target.substitutions - self.reference.substitutions)
        message = %Q{Key "#{target.path.join('.')}":}
        if extras.any?
          message << %Q{ Extra substitutions: ["#{extras.join('", "')}"].}
        end
        if missing.any?
          message << %Q{ Missing substitutions: ["#{missing.join('", "')}"].}
        end
        message
      end
    end

    def flatten(translation_file, path=[])
      translation_file.map do |key, value|
        case value
        when Hash
          flatten(value, path + [key])
        else
          TranslationEntry.new(path + [key], value || "")
        end
      end.flatten
    end

    def load_translation_file(filename)
      YAML.load_file(filename)
    end

    def reference_file_name
      "en.yml"
    end

  private
    def exclude_locale_from_path(path)
      path[1..-1]
    end
  end
end