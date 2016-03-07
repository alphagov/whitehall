class EditionUnwithdrawer < EditionService
  def verb
    'unwithdraw'
  end

  def past_participle
    'unwithdrawn'
  end

  def failure_reason
    @failure_reason ||= failure_reasons.first
  end

  def failure_reasons
    reasons = []

    reasons << "This action must be attributed to a user" if user.nil?
    reasons << "An edition that is #{edition.current_state} cannot be #{past_participle}" unless can_transition?

    reasons
  end

private

  def prepare_edition
    # The withdrawn edition needs to be in the published state so as a draft can be created
    edition.update_attribute(:state, :published)
    edition.reload
  end

  def fire_transition!
    unwithdrawn_edition = edition.create_draft(user)
    unwithdrawn_edition.minor_change = true
    unwithdrawn_edition.editorial_remarks << EditorialRemark.create(author: user, edition: edition, body: "Unwithdrawn")

    Edition::AuditTrail.acting_as(user) do
      Whitehall.edition_services.force_publisher(unwithdrawn_edition).perform!
    end
  end

  def user
    options[:user]
  end
end
