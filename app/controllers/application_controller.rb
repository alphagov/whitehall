require "slimmer/headers"

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  include Slimmer::Headers
  include Slimmer::Template

  protect_from_forgery

  before_filter :set_slimmer_proposition
  before_filter :set_slimmer_application_name
  before_filter :set_audit_trail_whodunnit

  layout 'frontend'
  after_filter :set_slimmer_template

  private

  def set_audit_trail_whodunnit
    Edition::AuditTrail.whodunnit = current_user
  end

  def skip_slimmer
    response.headers[Slimmer::Headers::SKIP_HEADER] = "true"
  end

  def slimmer_template(template_name)
    response.headers[Slimmer::Headers::TEMPLATE_HEADER] = template_name
  end

  def set_slimmer_template
    slimmer_template('header_footer_only')
  end

  def set_slimmer_application_name
    set_slimmer_headers(application_name: 'inside_government')
  end

  def set_slimmer_proposition
    set_slimmer_headers(proposition: "government")
  end

  def set_slimmer_organisations_header(organisations)
    set_slimmer_headers(organisations: "<#{organisations.map(&:analytics_identifier).join('><')}>")
  end

  def set_slimmer_page_owner_header(organisation)
    identifier = page_owner_identifier_for(organisation)
    set_slimmer_headers(page_owner: identifier) if identifier
  end

  def page_owner_identifier_for(organisation)
    organisation = organisation.is_a?(WorldwideOrganisation) ? organisation.sponsoring_organisation : organisation

    if organisation && organisation.acronym.present?
      organisation.acronym.downcase.parameterize.underscore
    end
  end

  def set_slimmer_format_header(format_name)
    set_slimmer_headers(format: format_name)
  end

  def set_meta_description(description)
    @meta_description = description
  end

  # Facebook referer changes the Rails array syntax in URLs.
  # Use this when the expected filter value can have multiple values.
  # This method converts a nested hash to a hash with just the values
  def clean_malformed_params_array(key)
    if params[key].kind_of?(Hash)
      params[key] = params[key].values
    end
  end

  # Wrap the params to cope with either an array or singular param value as
  # some URLs with keywords[]= are causing errors as they treated as an empty array.
  # @param [Symbol] key
  # @example
  #   params[:keywords] = []
  #   clean_malformed_params(:keywords)
  #   params[:keywords] #=> nil
  def clean_malformed_params(key)
    params[key] = Array.wrap(params[key]).first if params.has_key?(key)
  end
end
