require 'test_helper'

class AttachmentsHelperTest < ActionView::TestCase

  test 'CSV attachments attached to editions can be previewed' do
    csv_on_edition = create(:csv_attachment, attachable: create(:edition))
    assert previewable?(csv_on_edition)
  end

  test 'non-CSV attachments are not previewable' do
    non_csv_on_edition = create(:file_attachment, attachable: create(:edition))
    refute previewable?(non_csv_on_edition)
  end

  test 'CSV attachments attached to non-editions are not previewable' do
    csv_on_policy_group = create(:csv_attachment, attachable: create(:policy_group))
    refute previewable?(csv_on_policy_group)
  end
end
