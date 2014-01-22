class EmailSignupsController < PublicFacingController

  def new
    feed = Rack::Utils.unescape(new_email_signup_params[:feed]) if new_email_signup_params[:feed]
    @email_signup = EmailSignup.new(feed, new_email_signup_params[:local_government])
  rescue ArgumentError
    render text: 'Not found', status: :not_found
  end

  def create
    @email_signup = EmailSignup.create(create_email_signup_params[:feed], create_email_signup_params[:local_government] == '1')

    if @email_signup.valid?
      redirect_to @email_signup.govdelivery_url
    else
      render action: 'new'
    end
  end

private

  def new_email_signup_params
    @new_email_signup_params ||= {
      feed: params[:feed],
      local_government: params[:local_government]
    }
  end

  def create_email_signup_params
    @create_email_signup_params ||= params[:email_signup].permit(:feed, :local_government)
  end
end
