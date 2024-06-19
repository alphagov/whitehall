class UnmodifiableValidator < ActiveModel::Validator
  def validate(record)
    significant_changed_attributes(record).each do |attribute|
      record.errors.add(attribute, "cannot be modified when edition is in the #{record.state} state")
    end
  end

  def significant_changed_attributes(record)
    record.changed - modifiable_attributes(record.state_was, record.state)
  end

  def modifiable_attributes(previous_state, current_state)
    modifiable = %w[state updated_at force_published]
    if previous_state == "scheduled"
      modifiable += %w[major_change_published_at first_published_at access_limited]
    end
    if Edition::PRE_PUBLICATION_STATES.include?(previous_state) || being_unpublished?(previous_state, current_state)
      modifiable += %w[published_major_version published_minor_version]
    end
    modifiable
  end

  def being_unpublished?(previous_state, current_state)
    previous_state == "published" && %w[unpublished withdrawn].include?(current_state)
  end
end
