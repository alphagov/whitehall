class HomeController < PublicFacingController
  layout 'frontend'

  def home
    ministerial_department_type = OrganisationType.find_by_name('Ministerial department')
    @live_ministerial_departments = Organisation.where("organisation_type_id = ? AND govuk_status ='live'", ministerial_department_type)
    @live_other_departments = Organisation.where("organisation_type_id != ? AND govuk_status='live'", ministerial_department_type)
    @transitioning_ministerial_departments = Organisation.where("organisation_type_id = ? AND govuk_status ='transitioning'", ministerial_department_type)
    @transitioning_other_departments = Organisation.where("organisation_type_id != ? AND govuk_status='transitioning'", ministerial_department_type)
  end

  def feed
    @recently_updated = Edition.published.in_reverse_chronological_order.includes(:document, :organisations).limit(10)
  end

  def sunset
    render layout: 'home'
  end

  def how_government_works
    @policy_count = Policy.published.count
  end

end
