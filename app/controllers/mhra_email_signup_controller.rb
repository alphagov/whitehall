class MhraEmailSignupController < PublicFacingController
  def show
    @organisation = Organisation.friendly.find(params[:organisation_slug])

    return render_not_found unless mhra_email_signup?

    @mhra_email_signup_pages = mhra_email_signup_pages
  end

private

  def mhra_email_signup?
    @organisation.slug == "medicines-and-healthcare-products-regulatory-agency"
  end

  def mhra_email_signup_pages
    [
      OpenStruct.new(
        title: t("mhra_email_signup.pages.drug_alerts.title"),
        description: t("mhra_email_signup.pages.drug_alerts.description_html"),
      ),
      OpenStruct.new(
        title: t("mhra_email_signup.pages.drug_safety.title"),
        description: t("mhra_email_signup.pages.drug_safety.description_html"),
      ),
      OpenStruct.new(
        title: t("mhra_email_signup.pages.news_and_publications.title"),
        description: t("mhra_email_signup.pages.news_and_publications.description_html"),
      ),
    ]
  end
end
