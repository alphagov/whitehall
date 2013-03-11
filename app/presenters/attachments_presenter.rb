class AttachmentsPresenter < Struct.new(:edition)
  def any?
    edition.attachments.any?
  end

  def first
    edition.attachments.first
  end

  def more_than_one?
    remaining.any?
  end

  def remaining
    edition.attachments[1..-1]
  end
end
