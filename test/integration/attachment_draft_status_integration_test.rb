require 'test_helper'

class AttachmentDraftStatusIntegrationTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  context 'when draft document with file attachment is published' do
    let(:edition) { create(:news_article) }

    before do
      add_file_attachment('whitepaper.pdf', to: edition)

      stub_whitehall_asset('whitepaper.pdf', id: 'asset-id', draft: true)
      stub_whitehall_asset('thumbnail_whitepaper.pdf.png', id: 'thumbnail-asset-id', draft: true)
    end

    test 'attachment & its thumbnail are marked as published in Asset Manager' do
      Services.asset_manager.expects(:update_asset).with('asset-id', 'draft' => false)
      Services.asset_manager.expects(:update_asset).with('thumbnail-asset-id', 'draft' => false)

      force_publisher = Whitehall.edition_services.force_publisher(edition)
      assert force_publisher.perform!, force_publisher.failure_reason
    end
  end

  context 'when published document with file attachment is unpublished' do
    let(:edition) { create(:published_news_article) }

    before do
      add_file_attachment('whitepaper.pdf', to: edition)

      stub_whitehall_asset('whitepaper.pdf', id: 'asset-id', draft: false)
      stub_whitehall_asset('thumbnail_whitepaper.pdf.png', id: 'thumbnail-asset-id', draft: false)
    end

    test 'attachment & its thumbnail are marked as draft in Asset Manager' do
      Services.asset_manager.expects(:update_asset).with('asset-id', 'draft' => true)
      Services.asset_manager.expects(:update_asset).with('thumbnail-asset-id', 'draft' => true)

      unpublisher = Whitehall.edition_services.unpublisher(edition, unpublishing: {
        unpublishing_reason: UnpublishingReason::PublishedInError
      })
      assert unpublisher.perform!, unpublisher.failure_reason
    end
  end

  context 'when draft consultation with outcome with file attachment is published' do
    let(:edition) { create(:draft_consultation) }
    let(:outcome_attributes) { FactoryBot.attributes_for(:consultation_outcome) }
    let(:outcome) { edition.create_outcome!(outcome_attributes) }

    before do
      add_file_attachment('whitepaper.pdf', to: outcome)

      stub_whitehall_asset('whitepaper.pdf', id: 'asset-id', draft: true)
      stub_whitehall_asset('thumbnail_whitepaper.pdf.png', id: 'thumbnail-asset-id', draft: true)
    end

    test 'attachment & its thumbnail are marked as published in Asset Manager' do
      Services.asset_manager.expects(:update_asset).with('asset-id', 'draft' => false)
      Services.asset_manager.expects(:update_asset).with('thumbnail-asset-id', 'draft' => false)

      force_publisher = Whitehall.edition_services.force_publisher(edition)
      assert force_publisher.perform!, force_publisher.failure_reason
    end
  end

  context 'when draft consultation with feedback with file attachment is published' do
    let(:edition) { create(:draft_consultation) }
    let(:feedback_attributes) { FactoryBot.attributes_for(:consultation_public_feedback) }
    let(:feedback) { edition.create_public_feedback!(feedback_attributes) }

    before do
      add_file_attachment('whitepaper.pdf', to: feedback)

      stub_whitehall_asset('whitepaper.pdf', id: 'asset-id', draft: true)
      stub_whitehall_asset('thumbnail_whitepaper.pdf.png', id: 'thumbnail-asset-id', draft: true)
    end

    test 'attachment & its thumbnail are marked as published in Asset Manager' do
      Services.asset_manager.expects(:update_asset).with('asset-id', 'draft' => false)
      Services.asset_manager.expects(:update_asset).with('thumbnail-asset-id', 'draft' => false)

      force_publisher = Whitehall.edition_services.force_publisher(edition)
      assert force_publisher.perform!, force_publisher.failure_reason
    end
  end

  context 'when file attachment is added to outcome belonging to published consultation' do
    let(:edition) { create(:published_consultation) }
    let(:outcome_attributes) { FactoryBot.attributes_for(:consultation_outcome) }
    let(:outcome) { edition.create_outcome!(outcome_attributes) }

    before do
      stub_whitehall_asset('whitepaper.pdf', id: 'asset-id', draft: true)
      stub_whitehall_asset('thumbnail_whitepaper.pdf.png', id: 'thumbnail-asset-id', draft: true)
    end

    test 'attachment & its thumbnail are marked as published in Asset Manager' do
      Services.asset_manager.expects(:update_asset).with('asset-id', 'draft' => false)
      Services.asset_manager.expects(:update_asset).with('thumbnail-asset-id', 'draft' => false)

      add_file_attachment('whitepaper.pdf', to: outcome)
      Whitehall.consultation_response_notifier.publish('update', outcome)
    end
  end

  context 'when file attachment is added to policy group' do
    let(:policy_group) { create(:policy_group) }

    before do
      stub_whitehall_asset('whitepaper.pdf', id: 'asset-id', draft: true)
      stub_whitehall_asset('thumbnail_whitepaper.pdf.png', id: 'thumbnail-asset-id', draft: true)
    end

    test 'attachment & its thumbnail are marked as published in Asset Manager' do
      Services.asset_manager.expects(:update_asset).with('asset-id', 'draft' => false)
      Services.asset_manager.expects(:update_asset).with('thumbnail-asset-id', 'draft' => false)

      add_file_attachment('whitepaper.pdf', to: policy_group)
      Whitehall.policy_group_notifier.publish('update', policy_group)
    end
  end

private

  def ends_with(expected)
    ->(actual) { actual.end_with?(expected) }
  end

  def add_file_attachment(filename, to:)
    to.attachments << FactoryBot.build(
      :file_attachment,
      attachable: to,
      file: File.open(fixture_path.join(filename))
    )
  end

  def stub_whitehall_asset(filename, id:, draft:)
    Services.asset_manager.stubs(:whitehall_asset)
      .with(&ends_with(filename))
      .returns('id' => "http://asset-manager/assets/#{id}", 'draft' => draft)
  end
end
