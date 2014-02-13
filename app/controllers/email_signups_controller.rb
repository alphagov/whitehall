class EmailSignupsController < PublicFacingController

  def new
    @email_signup = EmailSignup.new(email_signup_params)
  end

  def create
    @email_signup = EmailSignup.new(email_signup_params)

    if @email_signup.save
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
