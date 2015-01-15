module EmailSignupHelper

  def email_signup_path(atom_url)
    signup_page = EmailSignupPagesFinder.signup_page_for_atom_url(atom_url)

    if signup_page
      signup_page.email_signup_path
    else
      new_email_signups_path(email_signup: {feed: atom_url})
    end
  end

end
