module Whitehall::DocumentFilter
  class CleanedParams < ActiveSupport::HashWithIndifferentAccess
    # These filter parameters are expected to be an array of values
    PERMITTED_ARRAY_PARAMETER_KEYS  = %w(topics departments people_ids world_locations)
    # These filter params are expected to be scalar values, as defined by the strong_parameters code
    PERMITTED_SCALAR_PARAMETER_KEYS = %w(page
                                         per_page
                                         from_date
                                         to_date
                                         keywords
                                         locale
                                         relevant_to_local_government
                                         include_world_location_news
                                         official_document_status
                                         publication_type
                                         announcement_type
                                         publication_filter_option
                                         announcement_filter_option
                                         announcement_type_option)


    def initialize(unclean_params)
      @params = unclean_params.clone

      PERMITTED_ARRAY_PARAMETER_KEYS.each do |param_key|
        clean_malformed_array_params(param_key)
      end

      super params.permit(*PERMITTED_SCALAR_PARAMETER_KEYS +
                           PERMITTED_ARRAY_PARAMETER_KEYS.map {|key| { key => [] }})
    end

    def unpermitted_keys
      @params.keys - permitted_filter_keys
    end

  private

    def permitted_filter_keys
      PERMITTED_SCALAR_PARAMETER_KEYS + PERMITTED_ARRAY_PARAMETER_KEYS + ActionController::Parameters::NEVER_UNPERMITTED_PARAMS
    end

    def params
      @params
    end

    # Facebook referer changes the Rails array syntax in URLs.
    # Use this when the expected filter value can have multiple values.
    # This method converts a nested hash to a hash with just the values
    def clean_malformed_array_params(key)
      params[key] = params[key].values if params[key].kind_of?(Hash)
    end
  end
end
