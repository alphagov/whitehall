module HasAboutUsCorporateInformationPage
  extend ActiveSupport::Concern

  def summary
    about_us.summary if about_us.present?
  end

  def body
    about_us.body if about_us.present?
  end

  def about_us
    @about_us ||= corporate_information_pages.published.for_slug("about")
  end

  def draft_about_us
    @draft_about_us ||= corporate_information_pages.draft.for_slug("about")
  end
end
