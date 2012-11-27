require 'whitehall/uploader/heading_validator'

module Whitehall::Uploader
  class Row
    def self.heading_validation_errors(headings)
      validator.errors(headings)
    end

  protected
    def self.validator
      HeadingValidator.new
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