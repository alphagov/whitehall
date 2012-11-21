module Whitehall::Uploader
  class Row
    def self.heading_validation_errors(headings)
      required_fields = required_fields(headings)
      missing_fields = required_fields.map(&:downcase) - headings.map(&:downcase)
      extra_fields = headings.map(&:downcase) - required_fields.map(&:downcase)

      errors = []
      errors << "Missing fields: '#{missing_fields.join("', '")}'" if missing_fields.any?
      errors << "Unexpected fields: '#{extra_fields.join("', '")}'" if extra_fields.any?
      errors
    end

  protected
    def self.required_fields(headings)
      %w{old_url title summary body organisation}
    end

    def self.provided_response_ids(headings)
      headings.map do |k|
        if match = k.match(/^response_([0-9]+).*$/)
          match[1]
        end
      end.compact.uniq
    end

    def self.provided_attachment_ids(headings)
      headings.map do |k|
        if match = k.match(/^attachment_([0-9]+).*$/)
          match[1]
        end
      end.compact.uniq
    end

  end
end