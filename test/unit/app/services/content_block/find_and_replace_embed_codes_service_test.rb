require "test_helper"

class ContentBlock::FindAndReplaceEmbedCodesServiceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:markup) do
    <<~HTML
      <p>Hello there</p>
      <p>{{embed:content_block_pension:basic-pension}}</p>
      <p>{{embed:content_block_pension:other-pension}}</p>
      <p>{{embed:content_block_pension:basic-pension}}</p>
    HTML
  end

  let(:api_response) do
    {
      "results" => [
        {
          "title" => "Basic Pension",
          "content_id_aliases" => [
            { "name" => "basic-pension" },
          ],
          "content_id" => "abc123",
          "details" => {
            "rates" => {
              "basic-pension-amount" => {
                "title" => "Basic Pension",
                "amount" => "£176.45",
                "frequency" => "a week",
              },
            },
            "description" => "The basic Pension amount.",
          },
          "document_type" => "content_block_pension",
        },
        {
          "title" => "Other Pension",
          "content_id_aliases" => [
            { "name" => "other-pension" },
          ],
          "content_id" => "xyz456",
          "details" => {
            "rates" => {
              "other-pension-amount" => {
                "title" => "Other Pension",
                "amount" => "£236.65",
                "frequency" => "a week",
              },
            },
            "description" => "The other Pension amount.",
          },
          "document_type" => "content_block_pension",
        },
      ],
    }
  end

  let(:publishing_api) { mock("publishing_api") }

  let(:basic_pension_block_for_rendering) { mock("ContentBlockTools::ContentBlock") }
  let(:other_pension_block_for_rendering) { mock("ContentBlockTools::ContentBlock") }

  before do
    Services.expects(:publishing_api).returns(publishing_api)

    ContentBlockTools::ContentBlock.expects(:new)
      .with(has_entry(embed_code: "basic-pension"))
      .returns(basic_pension_block_for_rendering)

    ContentBlockTools::ContentBlock.expects(:new)
      .with(has_entry(embed_code: "other-pension"))
      .returns(other_pension_block_for_rendering)

    basic_pension_block_for_rendering.expects(:render)
      .returns("<span class='content-block'>Basic pension</span>")
    other_pension_block_for_rendering.expects(:render)
      .returns("<span class='content-block'>Other pension</span>")
  end

  it "fetches each unique block from the Publishing API as JSON" do
    publishing_api
      .expects(:get_content_items)
      .with(
        content_id_aliases: %w[basic-pension other-pension],
        fields: %w[title content_id_aliases details document_type],
      )
      .returns(api_response)

    ContentBlock::FindAndReplaceEmbedCodesService.call(markup)
  end

  it "returns HTML with embed codes replaced by blocks rendered by 'tools'" do
    publishing_api
      .expects(:get_content_items)
      .returns(api_response)

    input = <<~INPUT
      <p>Hello there</p>
      <p>{{embed:content_block_pension:basic-pension}}</p>
      <p>{{embed:content_block_pension:other-pension}}</p>
      <p>{{embed:content_block_pension:basic-pension}}</p>
    INPUT

    expected_output = <<~OUTPUT
      <p>Hello there</p>
      <p><span class='content-block'>Basic pension</span></p>
      <p><span class='content-block'>Other pension</span></p>
      <p><span class='content-block'>Basic pension</span></p>
    OUTPUT

    result = ContentBlock::FindAndReplaceEmbedCodesService.call(input)

    assert_equal expected_output, result
  end

  # it "ignores blocks that aren't present in the database" do
  #   edition = build(:content_block_edition, :pension)
  #
  #   html = edition.document.embed_code
  #
  #   result = ContentBlock::FindAndReplaceEmbedCodesService.call(html)
  #   assert_equal result, html
  # end
  #
  # it "ignores blocks that don't have a live version" do
  #   edition = create(:content_block_edition, :pension, state: "draft")
  #
  #   html = edition.document.embed_code
  #
  #   result = ContentBlock::FindAndReplaceEmbedCodesService.call(html)
  #   assert_equal result, html
  # end
end
