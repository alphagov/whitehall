require 'test_helper'
require 'attachment_uploader'
require 'document'
require 'attachment'
require 'attachment_data'
require 'cleanups/attachment_ordering_fixer'

class AttachmentOrderingFixerTest < ActiveSupport::TestCase

  setup do
    c = ActiveRecord::Base.connection
    @document_id = 80781
    c.execute "insert into documents select * from whitehall_development.documents where id=#{document_id}"
    c.execute "insert into editions select e.* from whitehall_development.editions e join whitehall_test.documents d on e.document_id=d.id"
    c.execute "insert into edition_translations select et.* from whitehall_development.edition_translations et join whitehall_test.editions e on e.id=et.edition_id"
    c.execute "insert into attachments select a.* from whitehall_development.attachments a join whitehall_test.editions e on e.id=a.attachable_id where a.attachable_type='Edition'"
    c.execute "insert into old_attachments select a.* from whitehall_development.old_attachments a join whitehall_test.editions e on e.id=a.attachable_id where a.attachable_type='Edition'"
    c.execute "insert into attachment_data select distinct ad.* from whitehall_development.attachment_data ad join whitehall_test.attachments a on ad.id=a.attachment_data_id"
    c.execute "insert ignore into attachment_data select distinct ad.* from whitehall_development.attachment_data ad join whitehall_test.old_attachments a on ad.id=a.attachment_data_id"
  end

  test 'should fix ordering of attachments in the normal case' do
    AttachmentOrderingFixer.run!
    expected_order = [
      "ECO brokerage results: 29 January 2013",
      "ECO brokerage results: 12 February 2013",
      "ECO brokerage results: 15 January 2013",
      "ECO brokerage results: 26 February 2013",
      "ECO brokerage results: 12 March 2013",
      "ECO brokerage results: 26 March 2013",
      "ECO brokerage results: 9 April 2013",
      "ECO brokerage results: 23 April 2013",
      "ECO brokerage results: 7 May 2013",
      "ECO brokerage results: 21 May 2013",
      "ECO brokerage results: 4 June 2013",
      "ECO brokerage results: 18 June 2013 (PDF)",
      "ECO brokerage results: 18 June 2013 (CSV)",
      "ECO brokerage results: 02 July 2013 (PDF)",
      "ECO brokerage results: 02 July 2013 (CSV)",
      "ECO brokerage results: 16 July 2013 (PDF)",
      "ECO brokerage results: 16 July 2013 (CSV)",
      "ECO brokerage results: 30 July 2013 (PDF)",
      "ECO brokerage results: 30 July 2013 (CSV)",
      "ECO brokerage results: 13 August 2013 (PDF)",
      "ECO brokerage results: 13 August 2013 (CSV)",
      "ECO brokerage results: 27 August 2013 (PDF)",
      "ECO brokerage results: 27 August 2013 (CSV)",
      "ECO brokerage results: 10 September (PDF)",
      "ECO brokerage results: 10 September (CSV)",
      "ECO brokerage results: 24 September (PDF)",
      "ECO brokerage results: 24 September (CSV)",
      "ECO brokerage results: 8 October 2013 (PDF)",
      "ECO brokerage results: 8 October 2013 (CSV)"
    ]

    attachments_248348 = Edition.find(248348).attachments.map(&:title)
    assert_equal expected_order[0...attachments_248348.length], attachments_248348

    assert_equal expected_order, Edition.find(248750).attachments.map(&:title)
  end
end
