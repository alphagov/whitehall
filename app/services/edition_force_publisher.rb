class EditionForcePublisher < EditionPublisher

private

  def verb
    :force_publish
  end

  def prepare_edition
    edition.force_published = true
    super
  end

  def fire_transition!
    edition.force_publish!
  end
end
