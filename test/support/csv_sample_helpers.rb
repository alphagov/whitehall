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
    heading = CSV.generate_line(rows.first.keys, encoding: "UTF-8")
    heading + rows.map do |row|
      CSV.generate_line(row.values, encoding: "UTF-8")
    end.join
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
      "policy_1"          => "",
      "policy_2"          => "",
      "policy_3"          => "",
      "policy_4"          => "",
      "consultation_ISBN" => "",
      "consultation_URN"  => "",
      "response_date"     => "20-Nov-2012",
      "response_summary"  => "summary required"
    )
  end

  def minimally_valid_publication_row
    minimally_valid_edition_row.merge(
      "publication_type" => "guidance",
      "publication_date" => "2011-01-01"
    )
  end

  def sample_organisation
    @sample_organisation ||= (Organisation.first || create(:organisation))
  end
end
