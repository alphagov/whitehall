require "slimmer/headers"

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  include Slimmer::Headers

  ANALYTICS_FORMAT = Hash.new("undefined")
  ANALYTICS_FORMAT.merge!(
    policy: "policy",
    news: "news",
    detailed_guidance: "detailed_guidance")

  protect_from_forgery

  before_filter :set_proposition

  layout 'frontend'

  private

  def skip_slimmer
    response.headers[Slimmer::Headers::SKIP_HEADER] = "true"
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
end
