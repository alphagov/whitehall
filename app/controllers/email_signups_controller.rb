class EmailSignupsController < PublicFacingController
  layout 'frontend'

  def show
    @classifications = EmailSignup.valid_topics.alphabetical
    orgs_by_type = EmailSignup.valid_organisations_by_type
    @live_ministerial_departments = orgs_by_type[:ministerial]
    @live_other_departments = orgs_by_type[:other]
    @document_types = EmailSignup.valid_document_types_by_type
    @email_signup = EmailSignup.new
    @email_signup.alerts = [@email_signup.build_alert]
  end

end
