module Whitehall
  module Uploader
    class HeadingValidator
      def initialize
        @required_fields = []
        @optional_fields = []
        @correlated_fields = []
        @ignored_patterns = []
        @translatable_fields = []
      end

      def required(fields)
        @required_fields.concat([*fields].map(&:downcase))
        self
      end

      def optional(fields)
        @optional_fields.concat([*fields].map(&:downcase))
        self
      end

      def multiple(correlated_fields, multiplicity = 1..Float::INFINITY)
        @correlated_fields << CorrelatedFieldValidator.new(correlated_fields, multiplicity)
        self
      end

      def ignored(pattern)
        @ignored_patterns << Regexp.new('\A' + Regexp.escape(pattern.downcase).gsub('\*', '.*') + '\z')
        self
      end

      def translatable(fields)
        @translatable_fields.concat([*fields].map(&:downcase))
        self
      end

      def valid?(headings)
        validate(headings).valid?
      end

      def errors(headings)
        validate(headings).errors
      end

      def validate(headings)
        headings = normalise(headings)
        ValidationResult.new(
          duplicates: duplicates(headings),
          missing: missing(headings),
          extra: extra(headings)
        )
      end

    private
      def duplicates(headings)
        normalise(headings).group_by {|heading| heading}.reject {|_, list| list.size<2}.keys
      end

      def missing(headings)
        missing_correlations = @correlated_fields.map do |correlation|
          correlation.missing(headings)
        end
        missing_fields(headings) + missing_correlations.flatten
      end

      def missing_fields(headings)
        if includes_translation?(headings)
          @required_fields + required_translation_fields - headings
        else
          @required_fields - headings
        end
      end

      def extra(headings)
        correlated = @correlated_fields.map { |c| c.accepted(headings) }.flatten
        if includes_translation?(headings)
          normalise(headings) - (@required_fields + translation_fields + @optional_fields + correlated)
        else
          normalise(headings) - (@required_fields + @optional_fields + correlated)
        end
      end

      def includes_translation?(headings)
        headings.include?('locale')
      end

      def translation_fields
        %w(locale translation_url) + @translatable_fields.map {|field| "#{field}_translation" }
      end

      def required_translation_fields
        %w(locale translation_url) + (@translatable_fields & @required_fields).map {|field| "#{field}_translation" }
      end

      def normalise(headings)
        without_ignored(headings.reject(&:nil?).map(&:downcase))
      end

      def without_ignored(headings)
        headings.reject do |heading|
          @ignored_patterns.any? {|pattern| pattern.match(heading)}
        end
      end

      class ValidationResult
        def initialize(errors_by_category = {})
          @errors_by_category = errors_by_category
        end

        def valid?
          errors.size == 0
        end

        def errors
          @errors_by_category.map do |category, errors|
            next if errors.empty?
            "#{describe_category(category)} fields: '#{errors.join("', '")}'"
          end.compact
        end

        def method_missing(method, *args, &block)
          @errors_by_category.fetch(method)
        end

        def respond_to_missing?(method)
          @errors_by_category.has_key?(method)
        end

      private
        def describe_category(category)
          case category
          when :duplicates then "duplicate"
          when :extra then "unexpected"
          when :missing then "missing"
          else category.to_s
          end
        end
      end

      class CorrelatedFieldValidator
        def initialize(correlated_fields, acceptable_cohort_count = 1..Float::INFINITY)
          @correlated_fields = [*correlated_fields].map(&:downcase)
          @acceptable_cohort_count = acceptable_cohort_count
          bad_fields = @correlated_fields.reject {|f| f.count('#') == 1 }
          if bad_fields.any?
            raise "All numerically correlated fields must contain exactly one number placeholder '#' (these ones didn't: '#{bad_fields.join("', '")}')"
          end
        end

        def accepted(headings)
          cohorts = group_into_cohorts(headings).select do |cohort_number|
            cohort_number > 0 && @acceptable_cohort_count.cover?(cohort_number)
          end.values.flatten
        end

        def missing(headings)
          cohorts = group_into_cohorts(headings)
          if cohorts.count < @acceptable_cohort_count.first
            (1..@acceptable_cohort_count.first).map do |cohort_number|
              required_fields_for_cohort(cohort_number) - (cohorts[cohort_number] || [])
            end.flatten
          else
            cohorts.map do |cohort_number, cohort|
              required_fields_for_cohort(cohort_number) - cohort
            end.flatten
          end
        end

      private
        def field_regexps
          @correlated_fields.map do |f|
            Regexp.new('\A' + f.gsub('#', '([0-9]+)') + '\Z')
          end
        end

        def required_fields_for_cohort(cohort_number)
          @correlated_fields.map do |field_pattern|
            field_pattern.gsub('#', cohort_number.to_s)
          end
        end

        def group_into_cohorts(headings)
          cohorts = {}
          field_regexps.map do |field_regexp|
            headings.grep(field_regexp).each do |heading|
              cohort_number = heading.match(field_regexp)[1].to_i
              cohorts[cohort_number] ||= []
              cohorts[cohort_number] << heading
            end
          end
          cohorts
        end

      end

    end
  end
end
