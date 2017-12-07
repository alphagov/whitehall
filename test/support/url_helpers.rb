# rubocop:disable Lint/NestedMethodDefinition

module UrlHelpers
  extend ActiveSupport::Concern

  class_methods do
    def enable_url_helpers
      # See http://jakegoulding.com/blog/2011/02/26/using-named-routes-in-actionmailer-tests-with-rails-3/
      include Rails.application.routes.url_helpers
      Rails.application.routes.default_url_options[:host] = "example.com"

      def default_url_options
        Rails.application.routes.default_url_options
      end
    end
  end
end

# rubocop:enable Lint/NestedMethodDefinition
