class EmailSignupsController < PublicFacingController

  def new
    @email_signup = EmailSignup.new(email_signup_params)
  rescue ArgumentError
    render text: 'Not found', status: :not_found
  end

  def create
    @email_signup = EmailSignup.create(email_signup_params)

    if @email_signup.valid?
      redirect_to @email_signup.govdelivery_url
    else
      render action: 'new'
    end
  end

private

  def email_signup_params
    params.require(:email_signup).permit(:feed, :local_government)
  end
end
