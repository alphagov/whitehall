require 'test_helper'
require 'attachment_uploader'
require 'document'
require 'attachment'
require 'attachment_data'
require 'cleanups/attachment_ordering_fixer'

class AttachmentOrderingFixerTest < ActiveSupport::TestCase

  def load_sample_doc(document_id)
    c = ActiveRecord::Base.connection
    c.execute "insert into documents select * from whitehall_development.documents where id=#{document_id}"
    c.execute "insert into editions select e.* from whitehall_development.editions e join whitehall_test.documents d on e.document_id=d.id"
    c.execute "insert into edition_translations select et.* from whitehall_development.edition_translations et join whitehall_test.editions e on e.id=et.edition_id"
    c.execute "insert into attachments select a.* from whitehall_development.attachments a join whitehall_test.editions e on e.id=a.attachable_id where a.attachable_type='Edition'"
    c.execute "insert into old_attachments select a.* from whitehall_development.old_attachments a join whitehall_test.editions e on e.id=a.attachable_id where a.attachable_type='Edition'"
    c.execute "insert into attachment_data select distinct ad.* from whitehall_development.attachment_data ad join whitehall_test.attachments a on ad.id=a.attachment_data_id"
    c.execute "insert ignore into attachment_data select distinct ad.* from whitehall_development.attachment_data ad join whitehall_test.old_attachments a on ad.id=a.attachment_data_id"
  end

  test 'should fix ordering of attachments in the normal case' do
    load_sample_doc(80781)

    AttachmentOrderingFixer.run!

    pre_7_oct_attachments = [
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
      "ECO brokerage results: 24 September (CSV)"
    ]

    post_7_oct_attachments = [
      "ECO brokerage results: 8 October 2013 (PDF)",
      "ECO brokerage results: 8 October 2013 (CSV)"
    ]

    assert_equal pre_7_oct_attachments, Edition.find(248348).attachments.map(&:title)

    assert_equal pre_7_oct_attachments + post_7_oct_attachments, Edition.find(248750).attachments.map(&:title)
  end

  test 'should fix ordering of attachments even with dodgy created_at on attachments' do
    load_sample_doc(9406)

    bad_attachment_order = [
      "Felixstowe port traffic",
      "Aberdeen port traffic",
      "Ballylumford port traffic",
      "Belfast port traffic",
      "Boston port traffic",
      "Bristol port traffic",
      "Cairnryan port traffic",
      "Cardiff port traffic",
      "Clyde port traffic",
      "Cromarty Firth port traffic",
      "Dover port traffic",
      "Dundee port traffic",
      "Fishguard port traffic",
      "Fleetwood port traffic",
      "Forth port traffic",
      "Fowey port traffic",
      "Glensanda port traffic",
      "Goole port traffic",
      "Great Yarmouth port traffic",
      "Grimsby and Immingham port traffic",
      "Harwich port traffic",
      "Heysham port traffic",
      "Holyhead port traffic",
      "Hull port traffic",
      "Ipswich port traffic",
      "Larne port traffic",
      "Liverpool port traffic",
      "London port traffic",
      "Londonderry port traffic",
      "Manchester port traffic",
      "Medway port traffic",
      "Milford Haven port traffic",
      "Newhaven port traffic",
      "Newport port traffic",
      "Orkney port traffic",
      "Peterhead port traffic",
      "Plymouth port traffic",
      "Poole port traffic",
      "Port Talbot port traffic",
      "Portsmouth port traffic",
      "Ramsgate port traffic",
      "Rivers Hull and Humber port traffic",
      "River Trent port traffic",
      "Shoreham port traffic",
      "Southampton port traffic",
      "Stranraer port traffic",
      "Sullom Voe port traffic",
      "Sunderland port traffic",
      "Swansea port traffic",
      "Tees and Hartlepool port traffic",
      "Tyne port traffic",
      "Warrenpoint port traffic",
      "UK major port traffic, port level downloadable dataset, tonnage",
      "UK major port traffic, port level downloadable dataset, unitised traffic"
    ]

    good_attachment_order = [
      "Aberdeen port traffic",
      "Ballylumford port traffic",
      "Belfast port traffic",
      "Boston port traffic",
      "Bristol port traffic",
      "Cairnryan port traffic",
      "Cardiff port traffic",
      "Clyde port traffic",
      "Cromarty Firth port traffic",
      "Dover port traffic",
      "Dundee port traffic",
      "Felixstowe port traffic",
      "Fishguard port traffic",
      "Fleetwood port traffic",
      "Forth port traffic",
      "Fowey port traffic",
      "Glensanda port traffic",
      "Goole port traffic",
      "Great Yarmouth port traffic",
      "Grimsby and Immingham port traffic",
      "Harwich port traffic",
      "Heysham port traffic",
      "Holyhead port traffic",
      "Hull port traffic",
      "Ipswich port traffic",
      "Larne port traffic",
      "Liverpool port traffic",
      "London port traffic",
      "Londonderry port traffic",
      "Manchester port traffic",
      "Medway port traffic",
      "Milford Haven port traffic",
      "Newhaven port traffic",
      "Newport port traffic",
      "Orkney port traffic",
      "Peterhead port traffic",
      "Plymouth port traffic",
      "Poole port traffic",
      "Port Talbot port traffic",
      "Portsmouth port traffic",
      "Ramsgate port traffic",
      "Rivers Hull and Humber port traffic",
      "River Trent port traffic",
      "Shoreham port traffic",
      "Southampton port traffic",
      "Stranraer port traffic",
      "Sullom Voe port traffic",
      "Sunderland port traffic",
      "Swansea port traffic",
      "Tees and Hartlepool port traffic",
      "Tyne port traffic",
      "Warrenpoint port traffic",
      "UK major port traffic, port level downloadable dataset, tonnage",
      "UK major port traffic, port level downloadable dataset, unitised traffic"
    ]

    assert_equal bad_attachment_order, Edition.find(244489).attachments.map(&:title)

    AttachmentOrderingFixer.run!

    assert_equal good_attachment_order, Edition.find(244489).attachments.map(&:title)
  end
end
