require 'test_helper'

class DocumentListExportWorkerTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @worker = DocumentListExportWorker.new
  end

  test 'instantiates an EditionFilter with passed options converted to symbols' do
    Admin::EditionFilter.expects(:new).with(Edition, @user, state: "draft", include_unpublishing: true)
    @worker.stubs(:generate_csv)
    @worker.stubs(:send_mail)
    @worker.perform({ "state" => "draft" }, @user.id)
  end

  test 'generate_csv calls presenter once for each edition' do
    filter = mock
    filter.expects(:each_edition_for_csv).multiple_yields(1, 2, 3)
    @worker.stubs(:create_filter).returns(filter)
    @worker.stubs(:send_mail)
    DocumentListExportPresenter.expects(:new).returns(stub(row: [])).times(3)
    @worker.perform({ "state" => "draft" }, @user.id)
  end

  test 'sends mail with CSV to user' do
    csv = 'this|is|my|csv'
    title = "Everyone's editions"
    @worker.stubs(:create_filter).returns(stub(page_title: title))
    @worker.stubs(generate_csv: csv)
    Notifications.expects(:document_list).with(csv, @user.email, title).returns(stub(:deliver_now))
    @worker.perform({ "state" => "draft" }, @user.id)
  end
end
