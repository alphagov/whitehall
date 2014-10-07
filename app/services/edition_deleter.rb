class EditionDeleter < EditionService
  def verb
    'delete'
  end

  def past_participle
    'deleted'
  end

  def failure_reason
    "An edition that is #{edition.current_state} cannot be deleted" unless can_transition?
  end

private
  def fire_transition!
    edition.public_send(verb)
    edition.save(validate: false)
    edition.clear_slug
  end
end
