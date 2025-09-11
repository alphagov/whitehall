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

  let(:results) do
    [
      {
        "title" => "Basic Pension",
        "content_id_aliases" => [
          { "name" => "basic-pension" },
        ],
        "content_id" => "abc123",
        "details" => {
          "rates" => {},
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
          "rates" => {},
          "description" => "The other Pension amount.",
        },
        "document_type" => "content_block_pension",
      },
    ]
  end

  let(:api_response) do
    stub("GdsApi::Response").tap do |response|
      response.stubs(:[]).with("results").returns(results)
    end
  end

  let(:publishing_api) { mock("publishing_api") }
  let(:basic_pension_block_for_rendering) { mock("ContentBlockTools::ContentBlock") }
  let(:other_pension_block_for_rendering) { mock("ContentBlockTools::ContentBlock") }

  before do
    Services.stubs(:publishing_api).returns(publishing_api)
  end

  context "when all blocks are available at the Publishing API" do
    before do
      basic_pension_block_for_rendering.stubs(:render)
        .returns("<span class='content-block'>Basic pension</span>")

      other_pension_block_for_rendering.stubs(:render)
        .returns("<span class='content-block'>Other pension</span>")
    end

    it "fetches each unique (published) block from the Publishing API as JSON" do
      ContentBlockTools::ContentBlock.stubs(:new)
        .with(has_entry(embed_code: "{{embed:content_block_pension:basic-pension}}"))
        .returns(basic_pension_block_for_rendering)

      ContentBlockTools::ContentBlock.stubs(:new)
        .with(has_entry(embed_code: "{{embed:content_block_pension:other-pension}}"))
        .returns(other_pension_block_for_rendering)

      publishing_api
        .expects(:get_content_items)
        .with(
          content_id_aliases: %w[basic-pension other-pension],
          fields: %w[title content_id content_id_aliases details document_type],
          states: %w[published],
        )
        .returns(api_response)

      ContentBlock::FindAndReplaceEmbedCodesService.call(markup)
    end

    it "builds renderable blocks from API item representations using 'Tools'" do
      publishing_api
        .stubs(:get_content_items)
        .returns(api_response)

      ContentBlockTools::ContentBlock.expects(:new)
        .with(
          document_type: "content_block_pension",
          content_id: "abc123",
          title: "Basic Pension",
          details: {
            "rates" => {},
            "description" => "The basic Pension amount.",
          },
          embed_code: "{{embed:content_block_pension:basic-pension}}",
        )
        .returns(basic_pension_block_for_rendering)

      ContentBlockTools::ContentBlock.expects(:new)
        .with(
          document_type: "content_block_pension",
          content_id: "xyz456",
          title: "Other Pension",
          details: {
            "rates" => {},
            "description" => "The other Pension amount.",
          },
          embed_code: "{{embed:content_block_pension:other-pension}}",
        )
        .returns(other_pension_block_for_rendering)

      ContentBlock::FindAndReplaceEmbedCodesService.call(markup)
    end

    it "returns HTML with embed codes replaced by blocks rendered by 'Tools'" do
      ContentBlockTools::ContentBlock.stubs(:new)
        .with(has_entry(embed_code: "{{embed:content_block_pension:basic-pension}}"))
        .returns(basic_pension_block_for_rendering)

      ContentBlockTools::ContentBlock.stubs(:new)
        .with(has_entry(embed_code: "{{embed:content_block_pension:other-pension}}"))
        .returns(other_pension_block_for_rendering)

      publishing_api
        .stubs(:get_content_items)
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
  end

  context "when a block is not available from the Publishing API" do
    let(:results) do
      [
        {
          "title" => "Basic Pension",
          "content_id_aliases" => [
            { "name" => "basic-pension" },
          ],
          "content_id" => "abc123",
          "details" => {
            "rates" => {},
            "description" => "The basic Pension amount.",
          },
          "document_type" => "content_block_pension",
        },
      ]
    end

    before do
      ContentBlockTools::ContentBlock.stubs(:new)
        .with(has_entry(embed_code: "{{embed:content_block_pension:basic-pension}}"))
        .returns(basic_pension_block_for_rendering)

      basic_pension_block_for_rendering.stubs(:render)
        .returns("<span class='content-block'>Basic pension</span>")
    end

    it "ignores that missing block but inserts any which are available" do
      publishing_api
        .stubs(:get_content_items)
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
        <p>{{embed:content_block_pension:other-pension}}</p>
        <p><span class='content-block'>Basic pension</span></p>
      OUTPUT

      result = ContentBlock::FindAndReplaceEmbedCodesService.call(input)

      assert_equal expected_output, result
    end
  end
end
