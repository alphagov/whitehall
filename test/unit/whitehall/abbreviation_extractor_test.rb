require 'test_helper'

class AbbreviationExtractorTest < ActiveSupport::TestCase
  test "extracts a single abbreviation couple from an edition" do
    edition = create(:edition, body:
      "This is the DVLA\n\n" +
      "*[DVLA]:Driver and Vehicle Licensing Agency")

    abbreviations = Whitehall::AbbreviationExtractor.new(edition).extract

    assert_equal [{terms: ["Driver and Vehicle Licensing Agency", "DVLA"], type: "abbreviation"}], abbreviations
  end

  test "extracts multiple abbreviation couples from an edition" do
    edition = create(:edition, body:
      "This is the MOD\n\n" +
      "This is the MOJ\n\n" +
      "*[MOD]:Ministry of Defence\n" +
      "*[MOJ]:Ministry of Justice")

    abbreviations = Whitehall::AbbreviationExtractor.new(edition).extract

    assert_equal [
      {terms: ["Ministry of Defence", "MOD"], type: "abbreviation"},
      {terms: ["Ministry of Justice", "MOJ"], type: "abbreviation"}
    ], abbreviations
  end

  test "only extracts unique abbreviations" do
    edition = create(:edition, body:
      "This is the MOD\n\n" +
      "This is the MOD\n\n" +
      "*[MOD]:Ministry of Defence\n")

    abbreviations = Whitehall::AbbreviationExtractor.new(edition).extract

    assert_equal [
      {terms: ["Ministry of Defence", "MOD"], type: "abbreviation"}
    ], abbreviations
  end
end
