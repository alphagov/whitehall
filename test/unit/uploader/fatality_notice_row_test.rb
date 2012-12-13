# encoding: UTF-8

require File.expand_path("../../../fast_test_helper", __FILE__)
require 'test_helper'

class Whitehall::Uploader::FatalityNoticeRowTest < ActiveSupport::TestCase
  setup do
    @attachment_cache = stub('attachment cache')
    @image_cache = stub('image cache')
    @iraq = create(:operational_field, name: "Iraq")
  end

  test "validates row headings" do
    assert_equal [], Whitehall::Uploader::FatalityNoticeRow.heading_validation_errors(sample_row.keys)
  end

  test "validation reports missing row headings" do
    keys = sample_row.keys - ['title']
    assert_equal ["missing fields: 'title'"], Whitehall::Uploader::FatalityNoticeRow.heading_validation_errors(keys)
  end

  test "validation reports extra row headings" do
    keys = sample_row.keys + ['extra_stuff']
    assert_equal ["unexpected fields: 'extra_stuff'"], Whitehall::Uploader::FatalityNoticeRow.heading_validation_errors(keys)
  end

  test "validation complains of missing image headings" do
    keys = sample_row.keys - %w{image_1_imgalt}
    assert_equal [
      "missing fields: 'image_1_imgalt'",
      ], Whitehall::Uploader::FatalityNoticeRow.heading_validation_errors(keys)
  end

  test "takes title from the title column" do
    row = Whitehall::Uploader::FatalityNoticeRow.new({"title" => "a-title"}, 1, @attachment_cache)
    assert_equal "a-title", row.attributes[:title]
  end

  test "takes summary from the summary column" do
    row = Whitehall::Uploader::FatalityNoticeRow.new({"summary" => "a-summary"}, 1, @attachment_cache)
    assert_equal "a-summary", row.attributes[:summary]
  end

  test "takes body from the body column" do
    row = Whitehall::Uploader::FatalityNoticeRow.new({"body" => "Some body goes here"}, 1, @attachment_cache)
    assert_equal "Some body goes here", row.attributes[:body]
  end

  test "takes legacy url from the old_url column" do
    row = Whitehall::Uploader::FatalityNoticeRow.new({"old_url" => "http://example.com/old-url"}, 1, @attachment_cache)
    assert_equal "http://example.com/old-url", row.legacy_url
  end

  test "takes organisation by finding the org with slug 'ministry-of-defence'" do
    o = stub(:ministry_of_defence)
    Organisation.stubs(:find_by_slug).with("ministry-of-defence").returns(o)
    row = Whitehall::Uploader::FatalityNoticeRow.new({}, 1, @attachment_cache)
    assert_equal [o], row.organisations
  end

  test "generates lead_edition_organisations by asking the edition organisation builder to build a lead with each found organisation" do
    o = stub(:organisation)
    row = Whitehall::Uploader::FatalityNoticeRow.new({}, 1, @attachment_cache)
    row.stubs(:organisations).returns([o])
    leo = stub(:lead_edition_organisation)
    Whitehall::Uploader::Builders::EditionOrganisationBuilder.stubs(:build_lead).with(o, 1).returns(leo)
    assert_equal [leo], row.lead_edition_organisations
  end

  test "finds operational field by name" do
    row = Whitehall::Uploader::FatalityNoticeRow.new({"field_of_operation" => "Iraq"}, 1, @attachment_cache)
    assert_equal @iraq, row.attributes[:operational_field]
  end

  test "finds first published" do
    row = Whitehall::Uploader::FatalityNoticeRow.new({"first_published" => "11-Jan-2011"}, 1, @attachment_cache)
    assert_equal Time.zone.parse("2011-01-11"), row.attributes[:first_published_at]
  end

  test "creates image fetched from fatality notice image cache" do
    logger = stub("logger")
    logger.expects(:error).never
    filehandle = File.open(Rails.root.join("test/fixtures/example_fatality_notice_image.jpg"), 'r:binary')
    @image_cache.stubs(:fetch).with("http://www.mod.uk/NR/rdonlyres/B4F6766E-8A5B-469B-878F-4D22F14963BD/0/MODBADGE600x800.jpg").returns(filehandle)
    row = Whitehall::Uploader::FatalityNoticeRow.new(sample_row, 1, @attachment_cache, logger, @image_cache)

    filehandle = File.open(Rails.root.join("test/fixtures/example_fatality_notice_image.jpg"), 'r:binary')
    expected_image = Image.new(image_data: ImageData.new(file: filehandle),
      alt_text: "MOD Announcement",
      caption: "Acting Chief Petty Officer Joseph Bloggs
    [Picture: via MOD]")

    assert_equal [expected_image.attributes], row.attributes[:images].map {|i| i.attributes}
    assert_equal [expected_image.image_data.attributes], row.attributes[:images].map {|i| i.image_data.attributes}
  end

  def sample_row
    {
      "old_url" => "http://www.mod.uk/DefenceInternet/DefenceNews/MilitaryOperations/example.htm",
      "title" => "Acting Chief Petty Officer Joe Bloggs",
      "summary" => "It is with great regret that the Ministry of Defence has to confirm that Acting Chief Petty Officer Joeseph Bloggs died while serving in HMS Illustrious on 3 March 2008, while the ship was on patrol in the Gulf.",
      "body" => "Aged 33, he was married and lived in Portsmouth. His death is believed to have been from natural causes. Our thoughts are very much with his family at this difficult time. ",
      "first_published" => "2009-05-28",
      "field_of_operation" => "Iraq",
      "image_1_imgalt" => "MOD Announcement",
      "image_1_imgcap" => "Acting Chief Petty Officer Joseph Bloggs <br>[Picture: via MOD]",
      "image_1_imgcapmd" => "Acting Chief Petty Officer Joseph Bloggs
    [Picture: via MOD]",
      "image_1_imgurl" => "http://www.mod.uk/NR/rdonlyres/B4F6766E-8A5B-469B-878F-4D22F14963BD/0/MODBADGE600x800.jpg",
      "image_2_imgalt" => "",
      "image_2_imgcap" => "",
      "image_2_imgcapmd" => "",
      "image_2_imgurl" => "",
      "image_3_imgalt" => "",
      "image_3_imgcap" => "",
      "image_3_imgcapmd" => "",
      "image_3_imgurl" => "",
      "image_4_imgalt" => "",
      "image_4_imgcap" => "",
      "image_4_imgcapmd" => "",
      "image_4_imgurl" => ""
    }
  end
end