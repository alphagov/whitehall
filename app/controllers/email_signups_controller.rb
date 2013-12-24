class EmailSignupsController < PublicFacingController

  def new
    @email_signup = EmailSignup.new(params)
  rescue ArgumentError
    render text: 'Not found', status: :not_found
  end

  def create
    @email_signup = EmailSignup.create(params[:email_signup])
    redirect_to @email_signup.govdelivery_url
  end

end
