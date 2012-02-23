require "csv"

class VanityRedirector
  extend Forwardable
  include Enumerable

  def_delegators :@redirections, :each, :[]

  def initialize(csv_path)
    data = CSV.read(csv_path, {headers: true, header_converters: :symbol})
    @redirections = Hash[data.map { |d| [d[:from], d[:to]] }]
  end
end
