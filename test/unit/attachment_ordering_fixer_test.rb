require 'test_helper'
require 'attachment_uploader'
require 'document'
require 'attachment'
require 'attachment_data'
require 'cleanups/attachment_ordering_fixer'

class AttachmentOrderingFixerTest < ActiveSupport::TestCase

  def load_sample_doc(document_id)
    filename = Rails.root+"test/fixtures/attachment_ordering_fixer/#{document_id}.sql"
    config = ActiveRecord::Base.configurations['test']
    `mysql -u"#{config['username']}" -p"#{config['password']}" "#{config['database']}" < "#{filename}"`
  end

  teardown do
    DatabaseCleaner.clean_with :truncation
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

  test 'should fix ordering of attachments where attachment_data with `replaced_by_id` set' do
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
      "UK major port traffic, port level downloadable dataset, units"
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
      "UK major port traffic, port level downloadable dataset, units"
    ]

    assert_equal bad_attachment_order, Edition.find(235015).attachments.map(&:title)

    AttachmentOrderingFixer.run!

    assert_equal good_attachment_order, Edition.find(235015).attachments.map(&:title)
  end

  test 'should fix ordering of attachments if bad order cemented in first edition after 2013-10-07' do
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

    assert_equal bad_attachment_order, Edition.find(250555).attachments.map(&:title)

    AttachmentOrderingFixer.run!

    assert_equal good_attachment_order, Edition.find(250555).attachments.map(&:title)
  end

  test 'should retain ordering of attachments manually ordered before 2013-10-11' do
    load_sample_doc(42828)

    manual_attachment_order = [
      "Afghanistan: Progress Report - March 2013",
      "Afghanistan: Progress Report - February 2013",
      "Afghanistan: Progress Report - January 2013",
      "Afghanistan: Progress Report - November and December 2012",
      "Afghanistan: Progress Report - October 2012",
      "Afghanistan: Progress Report - September 2012",
      "Afghanistan: Progress Report - July to August 2012",
      "Afghanistan: Progress Report - June 2012",
      "Afghanistan: Progress Report - May 2012",
      "Afghanistan: Progress Report - April 2012",
      "Afghanistan: Progress Report - March 2012",
      "Afghanistan: Progress Report - February 2012",
      "Afghanistan: Progress Report - January 2012",
      "Afghanistan: Progress Report - December 2011",
      "Afghanistan: Progress Report - November 2011",
      "Afghanistan: Progress Report - October 2011",
      "Afghanistan: Progress Report - September 2011",
      "Afghanistan: Progress Report - July to August 2011",
      "Afghanistan: Progress Report - June 2011",
      "Afghanistan: Progress Report - May 2011",
      "Afghanistan: Progress Report - April 2011",
      "Afghanistan: Progress Report - March 2011",
      "Afghanistan: Progress Report - February 2011",
      "Afghanistan: Progress Report - January 2011",
      "Afghanistan: Progress Report - December 2010",
      "Afghanistan: Progress Report - November 2010"
    ]

    assert_equal manual_attachment_order, Edition.find(220944).attachments.map(&:title)

    AttachmentOrderingFixer.run!

    assert_equal manual_attachment_order, Edition.find(220944).attachments.map(&:title)
  end

  test 'should not screw up documents created after 2013-10-07' do
    load_sample_doc(197426)

    current_attachment_order = [
      "Chapter 1 - Introduction and Overview ",
      "Chapter 2 - Strategic Working Relationships, Working with Partners ",
      "Chapter 3 - Eligibility and initial engagement ",
      "Chapter 4 - Completion of ESF14 and Attachments",
      "Chapter 5 - Action planning and working with families ",
      "Chapter 6 - Progress Measures ",
      "Chapter 7 - Payments, Timing and Evidence Requirements ",
      "Chapter 8 - Performance Management and ESF Compliance ",
      "Chapter 9 - Completing ESF and Updating ESF Customer Records",
      "Chapter 10 - Management Information "
    ]

    assert_equal current_attachment_order, Edition.find(248643).attachments.map(&:title)

    AttachmentOrderingFixer.run!

    assert_equal current_attachment_order, Edition.find(248643).attachments.map(&:title)
  end

  test 'when fixing a document which was editioned after 2013-10-07 and had attachments added the original attachments are ordered using the last_known_good ordering and the new attachments go on the end' do
    load_sample_doc(80781)

    e2 = Edition.find(248750)
    attachments = e2.attachments.to_a
    attachments[0...27].each do |a|
      a.update_column(:ordering, nil)
    end
    attachments[27..-1].each.with_index do |a, i|
      a.update_column(:ordering, i)
    end

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
end
