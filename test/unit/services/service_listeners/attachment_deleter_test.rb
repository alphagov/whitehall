require 'test_helper'

module ServiceListeners
  class AttachmentDeleterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    let(:deleter) { AttachmentDeleter.new(attachment_data) }

    context 'when attachment data is not nil' do
      let(:id) { 123 }
      let(:attachment_data) { AttachmentData.new(id: id) }

      it 'deletes related assets in Asset Manager' do
        AssetManagerAttachmentDeleteWorker.expects(:perform_async).with(id)

        deleter.delete!
      end
    end

    context 'when attachment data is nil' do
      let(:attachment_data) { nil }

      it 'does not delete any assets in Asset Manager' do
        AssetManagerAttachmentDeleteWorker.expects(:perform_async).never

        deleter.delete!
      end
    end
  end
end
