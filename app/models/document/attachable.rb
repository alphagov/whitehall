module Document::Attachable
  extend ActiveSupport::Concern

  included do
    belongs_to :attachment
  end

  def allows_attachment?
    true
  end

  def attach_file=(file)
    self.attachment = build_attachment(file: file)
  end
end