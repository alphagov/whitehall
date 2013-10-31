class EditionForcePublisher < EditionPublisher
  def verb
    'force_publish'
  end

private

  def prepare_edition
    edition.force_published = true
    super
  end
end
