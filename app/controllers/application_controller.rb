require "slimmer/headers"

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  include Slimmer::Headers
  include Slimmer::Template
  include Slimmer::GovukComponents
  include LocalisedUrlPathHelper

  protect_from_forgery

  before_action :set_slimmer_application_name
  before_action :set_slimmer_show_organisations_filter
  before_action :set_audit_trail_whodunnit
  before_action :set_authenticated_user_header

  layout 'frontend'
  after_action :set_slimmer_template

private

  def set_audit_trail_whodunnit
    Edition::AuditTrail.whodunnit = current_user
  end

  def skip_slimmer
    response.headers[Slimmer::Headers::SKIP_HEADER] = "true"
  end

  def set_slimmer_template
    slimmer_template "header_footer_only"
  end

  def set_slimmer_application_name
    set_slimmer_headers(application_name: 'inside_government')
  end

  # Always open the finder (organisations filter box) on the search results page
  # to make it more obvious to users that the results can be filtered
  def set_slimmer_show_organisations_filter
    set_slimmer_headers(search_parameters: {show_organisations_filter: true}.to_json)
  end

  def set_slimmer_organisations_header(organisations)
    if organisations.any?
      set_slimmer_headers(organisations: "<#{organisations.map(&:analytics_identifier).join('><')}>")
    end
  end

  def set_slimmer_world_locations_header(locations)
    if locations.any?
      set_slimmer_headers(world_locations: "<#{locations.map(&:analytics_identifier).join('><')}>")
    end
  end

  def set_slimmer_page_owner_header(organisation)
    identifier = page_owner_identifier_for(organisation)
    set_slimmer_headers(page_owner: identifier) if identifier
    set_slimmer_search_parameter_header(organisation) if organisation
  end

  def set_slimmer_search_parameter_header(organisation)
    organisation = organisation.is_a?(WorldwideOrganisation) ? organisation.sponsoring_organisation : organisation
    if organisation && organisation.has_scoped_search?
      set_slimmer_headers(search_parameters: {filter_organisations: [organisation.slug]}.to_json)
    end
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
    @meta_description = Govspeak::Document.new(description).to_text
  end

  def set_authenticated_user_header
    if current_user && GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user].nil?
      GdsApi::GovukHeaders.set_header(:x_govuk_authenticated_user, current_user.uid)
    end
  end
end
