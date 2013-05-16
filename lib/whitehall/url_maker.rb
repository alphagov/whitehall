module Whitehall
  class UrlMaker
    include Rails.application.routes.url_helpers
    include PublicDocumentRoutesHelper
    include MainstreamCategoryRoutesHelper
    include FilterRoutesHelper
    include Admin::EditionRoutesHelper
    include LocalisedUrlPathHelper

    def initialize(default_options = {})
      unless default_options.empty?
        self.singleton_class.default_url_options = UrlMaker.default_url_options.merge(default_options)
      end
    end

    # LocalliseUrlPathHelper rewrites many helpers to look into
    # params[:locale] before deciding what url to produce, we need this to
    # make sure we can cope with that.
    def params
      {}
    end
  end
end
