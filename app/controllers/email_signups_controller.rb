class EmailSignupsController < PublicFacingController
  layout 'frontend'

  def show
    fetch_topics
    fetch_organisations
    fetch_document_types
    @email_signup = EmailSignup.new
    @email_signup.alerts = [@email_signup.build_alert]
  end

  def create
    @email_signup = EmailSignup.new
    @email_signup.alerts = extract_alerts_params
    if @email_signup.valid?
      redirector = EmailSignup::GovUkDeliveryRedirectUrlExtractor.new(@email_signup.alerts.first)
      redirect_to redirector.redirect_url
    else
      fetch_topics
      fetch_organisations
      fetch_document_types
      render :show
    end
  end

  protected
  def fetch_topics
    @classifications = EmailSignup.valid_topics
  end
  def fetch_organisations
    orgs_by_type = EmailSignup.valid_organisations_by_type
    @live_ministerial_departments = orgs_by_type[:ministerial]
    @live_other_departments = orgs_by_type[:other]
  end
  def fetch_document_types
    @document_types = EmailSignup.valid_document_types_by_type
  end

  def extract_alerts_params
    alerts_params = (params[:email_signup] || {})[:alerts]
    case alerts_params
    when Array
      alerts_params
    when Hash
      convert_alerts_params_from_hash_to_array(alerts_params)
    else
      []
    end
  end

  # rails will turn param called a[0][b] into {a: { "0": { b: ...} } }
  # we want [{b: ...}], so if all the keys are numeric then we'll use
  # the values, otherwise, assume it's a hash for a single element and
  # put it in an array on it's own
  def convert_alerts_params_from_hash_to_array(alerts_params)
    if alerts_params.keys.all? { |k| k =~ /\A\d+\Z/ }
      alerts_params.values
    else
      [alerts_params]
    end
  end

end
