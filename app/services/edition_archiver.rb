class EditionArchiver < EditionUnpublisher
  def verb
    'archive'
  end

  def past_participle
    'archived'
  end

private

  def prepare_edition
    edition.force_published = false
  end
end
