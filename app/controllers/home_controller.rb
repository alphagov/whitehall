class HomeController < PublicFacingController
  layout 'frontend'

  def home
    ministerial_department_type = OrganisationType.find_by_name('Ministerial department')
    sub_organisation_type = OrganisationType.find_by_name('Sub-organisation')
    @live_ministerial_departments = Organisation.where("organisation_type_id = ? AND govuk_status ='live'", ministerial_department_type)
    @live_other_departments = Organisation.where("organisation_type_id NOT IN (?,?) AND govuk_status='live'", ministerial_department_type, sub_organisation_type)
    @transitioning_ministerial_departments = Organisation.where("organisation_type_id = ? AND govuk_status ='transitioning'", ministerial_department_type)
    @transitioning_other_departments = Organisation.where("organisation_type_id NOT IN (?, ?) AND govuk_status='transitioning'", ministerial_department_type, sub_organisation_type)
    @topics = Topic.with_policies.alphabetical.all
  end

  def feed
    @recently_updated = Edition.published.in_reverse_chronological_order.includes(:document, :organisations).limit(10)
  end

  def sunset
    render layout: 'home'
  end

  def how_government_works
    @policy_count = Policy.published.count
    @non_ministerial_department_count = Organisation.where(organisation_type_id: OrganisationType.find_by_name('Non-ministerial department')).count
  end

end
