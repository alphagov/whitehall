require "csv"

class VanityRedirector
  include Enumerable

  delegate :each, :[], to: :@redirections

  def initialize(csv_path)
    data = CSV.read(csv_path, {headers: true, header_converters: :symbol})
    @redirections = Hash[data.map { |d| [d[:from], d[:to]] }]
  end
end
