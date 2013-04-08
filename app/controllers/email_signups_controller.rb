class EmailSignupsController < PublicFacingController
  layout 'frontend'

  def show
    @classifications = EmailSignup.valid_topics.alphabetical
    ministerial_department_type = OrganisationType.find_by_name('Ministerial department')
    sub_organisation_type = OrganisationType.find_by_name('Sub-organisation')
    @live_ministerial_departments = Organisation.with_translations.where("organisation_type_id = ? AND govuk_status ='live'", ministerial_department_type)
    @live_other_departments = Organisation.with_translations.where("organisation_type_id NOT IN (?,?) AND govuk_status='live'", ministerial_department_type, sub_organisation_type)
    @email_signup = EmailSignup.new
    @email_signup.alerts = [@email_signup.build_alert]
  end

end
