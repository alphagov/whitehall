class DraftEditionUpdater < EditionService

  def initialize(edition, options = {})
    super(edition, options)
    @current_tab = options[:current_tab]
  end

  def perform!
    if can_perform?
      update_publishing_api!
      notify!
      true
    end
  end

  def failure_reason
    if !edition.pre_publication?
      "A #{edition.state} edition may not be updated."
    elsif should_check_current_user_will_retain_access? && access_limit_excludes_current_user?
      "Access can only be limited by users belonging to an organisation tagged to the document"
    elsif tabbed_form?
      validate_tabbed_form
    elsif !edition.valid?
      "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
    end
  end

  def verb
    "update_draft"
  end

private

  def should_check_current_user_will_retain_access?
    @options[:current_user].present? && edition.access_limited?
  end

  def access_limit_excludes_current_user?
    edition.organisation_association_enabled? && edition.edition_organisations.map(&:organisation_id).exclude?(@options[:current_user].organisation.id)
  end

  def tabbed_form?
    @current_tab.present?
  end

  def validate_tabbed_form
    if @current_tab == "social_media_accounts"
      tab = TabForms::SocialMediaTabForm.new(@edition)
      return if tab.valid?

      tab.errors.each do |err|
        edition.errors.import(err)
      end
    end
  end
end
