require 'csv'

module CsvSampleHelpers
  def consultation_csv_sample(first_row_overrides = {}, extra_row_overrides = [])
    overrides = [first_row_overrides] + extra_row_overrides
    csv_sample(overrides.map { |row| minimally_valid_consultation_row.merge(row) })
  end

  def publication_csv_sample(first_row_overrides = {})
    rows = [
      minimally_valid_publication_row.merge(first_row_overrides)
    ]
    csv_sample(rows)
  end

  def csv_sample(rows)
    encoding = "UTF-8"
    heading = CSV.generate_line(rows.first.keys, encoding: encoding)
    rows = rows.map { |row| CSV.generate_line(row.values, encoding: encoding) }

    heading + rows.join
  end

  def minimally_valid_edition_row
    {
      "old_url"           => "http://example.com",
      "title"             => "title",
      "summary"           => "summary",
      "body"              => "body",
      "organisation"      => sample_organisation.slug
    }
  end

  def minimally_valid_consultation_row
    minimally_valid_edition_row.merge(
      "opening_date"      => "16-Nov-2011",
      "closing_date"      => "16-Nov-2012",
      "consultation_ISBN" => "",
      "consultation_URN"  => "",
      "response_date"     => "20-Nov-2012",
      "response_summary"  => "summary required",
      "topic_1"           => sample_topic.slug
    )
  end

  def minimally_valid_publication_row
    minimally_valid_edition_row.merge(
      "publication_type" => "guidance",
      "publication_date" => "2011-01-01"
    )
  end

  def sample_organisation
    @sample_organisation ||= (Organisation.first || create(:organisation, :with_alternative_format_contact_email))
  end

  def sample_topic
    @sample_topic ||= (Topic.first || create(:topic))
  end
end
