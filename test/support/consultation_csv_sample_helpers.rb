require 'csv'

module ConsultationCsvSampleHelpers
  def consultation_csv_sample(additional_fields = {}, extra_rows = [])
    data = minimally_valid_consultation_row.merge(additional_fields)
    lines = []
    lines << CSV.generate_line(data.keys, encoding: "UTF-8")
    lines << CSV.generate_line(data.values, encoding: "UTF-8")
    extra_rows.each do |row|
      lines << CSV.generate_line(minimally_valid_consultation_row.merge(row).values, encoding: "UTF-8")
    end
    lines.join
  end

  def minimally_valid_consultation_row
    {
      "old_url"          => "http://example.com",
      "title"            => "title",
      "summary"          => "summary",
      "body"             => "body",
      "opening_date" => "16-Nov-2011",
      "closing_date" => "16-Nov-2012",
      "organisation"     => sample_organisation.slug,
      "policy_1" => "",
      "policy_2" => "",
      "policy_3" => "",
      "policy_4" => "",
      "consultation_ISBN" => "",
      "consultation_URN" => "",
      "response_date" => "20-Nov-2012",
      "response_summary" => "summary required"
    }
  end

  def sample_organisation
    @sample_organisation ||= (Organisation.first || create(:organisation))
  end
end
