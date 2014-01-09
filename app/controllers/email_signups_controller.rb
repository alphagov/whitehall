class EmailSignupsController < PublicFacingController

  def new
    @email_signup = EmailSignup.new(params)
  rescue ArgumentError
    render text: 'Not found', status: :not_found
  end

  def create
    @email_signup = EmailSignup.create(params[:email_signup])

    if @email_signup.valid?
      redirect_to @email_signup.govdelivery_url
    else
      render action: 'new'
    end
  end

end
