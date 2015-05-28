class EditionWithdrawer < EditionUnpublisher
  def verb
    'withdraw'
  end

  def past_participle
    'withdrawn'
  end

private

  def prepare_edition
    edition.force_published = false
  end
end
