module Edition::NullAttachables
  extend ActiveSupport::Concern

  %w[
    allows_attachments?
    allows_attachment_references?
    allows_inline_attachments?
  ].each do |method|
    define_method(method) { false }
  end

  def attachables
    []
  end
end
