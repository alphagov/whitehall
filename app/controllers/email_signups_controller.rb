class EmailSignupsController < PublicFacingController
  layout 'frontend'

  def show
    fetch_topics
    fetch_organisations
    fetch_document_types
    fetch_policies
    @email_signup = EmailSignup.new
    @email_signup.alerts = extract_alerts_params
  end

  def create
    @email_signup = EmailSignup.new
    @email_signup.alerts = extract_alerts_params
    if @email_signup.valid?
      begin
        redirector = EmailSignup::GovUkDeliveryRedirectUrlExtractor.new(@email_signup.alerts.first)
        redirect_to redirector.redirect_url
      rescue EmailSignup::InvalidSlugError => e
        @email_signup.alerts.first.errors.add(e.attribute, "is not a valid #{e.attribute}")
        signup_failed
      end
    else
      signup_failed
    end
  end

  protected

  def signup_failed
    fetch_topics
    fetch_organisations
    fetch_document_types
    fetch_policies
    render :show
  end

  def fetch_topics
    @classifications = EmailSignup.valid_topics_by_type
  end

  def fetch_organisations
    orgs_by_type = EmailSignup.valid_organisations_by_type
    @live_ministerial_departments = orgs_by_type[:ministerial]
    @live_other_departments = orgs_by_type[:other]
  end

  def fetch_document_types
    @document_types = EmailSignup.valid_document_types_by_type
  end

  def fetch_policies
    @policies = EmailSignup.valid_policies
  end

  def extract_alerts_params
    alerts_params = normalize_params
    case alerts_params
    when Array
      alerts_params
    when Hash
      convert_alerts_params_from_hash_to_array(alerts_params)
    else
      [@email_signup.build_alert]
    end
  end

  def normalize_params
    if params[:email_signup]
      (params[:email_signup] || {})[:alerts]
    elsif (relevant_params = params.slice(:organisation, :topic, :document_type, :info_for_local, :policy)).any?
      [relevant_params]
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
