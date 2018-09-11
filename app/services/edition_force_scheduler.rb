class EditionForceScheduler < EditionScheduler
  def verb
    'force_schedule'
  end

  def past_participle
    'force_scheduled'
  end

private

  def prepare_edition
    edition.force_published = true
    super
  end
end
