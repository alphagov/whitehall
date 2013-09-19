class ImporterTestLogger < Logger

  def info(string, line_number)
    super(string)
  end
  alias_method :warn, :info
  alias_method :error, :info

end
