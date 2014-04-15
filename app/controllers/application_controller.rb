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
end
