require 'test_helper'
require 'capybara/rails'

class AttachmentAccessLimitedIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  let(:organisation) { create(:organisation) }
  let(:managing_editor) { create(:managing_editor, organisation: organisation, uid: 'user-uid') }

  before do
    login_as managing_editor
  end

  context 'given a draft document with file attachment' do
    let(:edition) { create(:news_article, organisations: [organisation]) }

    before do
      setup_publishing_api_for(edition)
      publishing_api_has_linkables([], document_type: "topic")

      add_file_attachment('logo.png', to: edition)
      VirusScanHelpers.simulate_virus_scan(include_versions: true)

      stub_whitehall_asset('logo.png', id: 'asset-id', draft: true)
    end

    it 'marks attachment as access limited in Asset Manager when document is marked as access limited in Whitehall' do
      visit edit_admin_news_article_path(edition)
      check 'Limit access to producing organisations prior to publication'

      Services.asset_manager.expects(:update_asset).with('asset-id', 'access_limited' => ['user-uid'])

      click_button 'Save'
      AssetManagerUpdateAssetWorker.drain
    end
  end

private

  def setup_publishing_api_for(edition)
    publishing_api_has_links(
      content_id: edition.document.content_id,
      links: {}
    )
  end

  def add_file_attachment(filename, to:)
    to.attachments << FactoryBot.build(
      :file_attachment,
      attachable: to,
      file: File.open(path_to_attachment(filename))
    )
  end

  def path_to_attachment(filename)
    fixture_path.join(filename)
  end

  def stub_whitehall_asset(filename, attributes = {})
    url_id = "http://asset-manager/assets/#{attributes[:id]}"
    Services.asset_manager.stubs(:whitehall_asset)
      .with(&ends_with(filename))
      .returns(attributes.merge(id: url_id).stringify_keys)
  end

  def ends_with(expected)
    ->(actual) { actual.end_with?(expected) }
  end
end
