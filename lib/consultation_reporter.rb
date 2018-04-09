require 'csv'

class ConsultationReporter
  HEADERS = ['Organisation', 'Title', 'URL', 'Opening at', 'Closing at', 'Response published on', 'Days response published after close', 'Status'].freeze

  def initialize(opts = {})
    @data_path = opts.fetch(:data_path, Rails.root)
    @start_date = opts.fetch(:start_date, '2015-05-07')
  end

  def all_consultations
    scope = Consultation
      .distinct('editions.id')
      .joins('LEFT JOIN responses ON responses.edition_id = editions.id')
      .where(state: %w{published withdrawn})
      .where('opening_at >= ?', @start_date)
      .order(:opening_at)

    write_csv_from_scope(:all_consultations, scope)
  end

private

  def write_csv_from_scope(name, scope)
    csv_file(name) do |csv|
      csv << HEADERS
      scope.each do |consultation|
        csv << format_consulation(consultation)
      end
    end
  end

  def format_consulation(consultation)
    delay = consultation.outcome ? (consultation.outcome.published_on - consultation.closing_at.to_date).to_i : nil
    status = if consultation.state == 'withdrawn'
               'Withdrawn'
             elsif delay.nil? && consultation.closing_at < 12.weeks.ago
               'Overdue'
             elsif delay.nil? && consultation.closing_at >= 12.weeks.ago
               'Not due yet'
             elsif delay > 12 * 7
               'Published late'
             elsif delay <= 12 * 7
               'Published on time'
             end
    [
      consultation.organisations.first.name,
      consultation.title,
      "https://www.gov.uk/government/consultations/#{consultation.document.slug}",
      consultation.opening_at.iso8601,
      consultation.closing_at.iso8601,
      consultation.outcome.try(:published_on),
      delay,
      status,
    ]
  end

  def csv_file(name, &block)
    CSV.open(File.join(@data_path, "#{name}.csv"), "w", &block)
  end
end
