require "test_helper"

class Admin::AuditTrailHelperTest < ActionView::TestCase
  setup do
    document = create(:document)
    first_edition = create(:published_edition, document: document)
    create(:editorial_remark, body: "First edition remark", edition: first_edition)
    second_edition = create(:published_edition, document: document)
    create(:editorial_remark, body: "Second edition remark", edition: second_edition)
    newest_edition = create(:published_edition, document: document)
    create(:editorial_remark, body: "Newest edition remark", edition: newest_edition)

    document_remarks = Document::PaginatedRemarks.new(newest_edition.document, 1)

    @render_newest = Nokogiri::HTML(render_editorial_remarks(document_remarks, newest_edition))
    @render_second = Nokogiri::HTML(render_editorial_remarks(document_remarks, second_edition))
    @render_first = Nokogiri::HTML(render_editorial_remarks(document_remarks, first_edition))
  end

  def groups_from_html(html_node)
    # HTML structure should be a <h2> followed by a <ul> of remarks
    html_node.css("h2").map do |h2|
      ul = h2.next
      {
        heading: h2.text,
        remarks: ul.css("li .body").map(&:text),
      }
    end
  end

  test "#render_editorial_remarks for the newest edition of a document" do
    expected_groups = [
      {
        heading: "On this edition",
        remarks: [
          "Newest edition remark",
        ],
      },
      {
        heading: "On previous editions",
        remarks: [
          "Second edition remark",
          "First edition remark",
        ],
      },
    ]

    assert_equal expected_groups, groups_from_html(@render_newest)
  end

  test "#render_editorial_remarks for an older edition of a document" do
    expected_groups = [
      {
        heading: "On newer editions",
        remarks: [
          "Newest edition remark",
        ],
      },
      {
        heading: "On this edition",
        remarks: [
          "Second edition remark",
        ],
      },
      {
        heading: "On previous editions",
        remarks: [
          "First edition remark",
        ],
      },
    ]

    assert_equal expected_groups, groups_from_html(@render_second)
  end

  test "#render_editorial_remarks for the oldest edition of a document" do
    expected_groups = [
      {
        heading: "On newer editions",
        remarks: [
          "Newest edition remark",
          "Second edition remark",
        ],
      },
      {
        heading: "On this edition",
        remarks: [
          "First edition remark",
        ],
      },
    ]

    assert_equal expected_groups, groups_from_html(@render_first)
  end
end
