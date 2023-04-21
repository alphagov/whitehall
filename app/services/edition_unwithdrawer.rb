class EditionUnwithdrawer < EditionPublisher
  def verb
    "unwithdraw"
  end

  def past_participle
    "unwithdrawn"
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
    edition.update!(state: :published)
    edition.reload
  end

  def fire_transition!
    unwithdrawn_edition = edition.create_draft(user)
    unwithdrawn_edition.minor_change = true
    unwithdrawn_edition.editorial_remarks << EditorialRemark.create(author: user, edition:, body: "Unwithdrawn")

    AuditTrail.acting_as(user) do
      force_publish! unwithdrawn_edition
    end
  end

  def force_publish!(unwithdrawn_edition)
    # The perform! method could be called instead, but this would lead to a nested transaction,
    # with possible race conditions
    force_publisher = EditionForcePublisher.new(unwithdrawn_edition)
    force_publisher.send(:prepare_edition)
    force_publisher.send(:fire_transition!)
    force_publisher.send(:update_publishing_api!)
  end

  def user
    options[:user]
  end
end
