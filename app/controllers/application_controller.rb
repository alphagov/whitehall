require "slimmer/headers"

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  include Slimmer::Headers
  include Slimmer::Template

  protect_from_forgery

  before_filter :set_proposition
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

  def set_proposition
    set_slimmer_headers(proposition: "government")
  end

  def set_slimmer_organisations_header(organisations)
    set_slimmer_headers(organisations: "<#{organisations.map(&:analytics_identifier).join('><')}>")
  end

  def set_slimmer_format_header(format_name)
    set_slimmer_headers(format: format_name)
  end

  def clean_malformed_params_array(key)
    if params[key].kind_of?(Hash)
      params[key] = params[key].values
    end
  end
end
