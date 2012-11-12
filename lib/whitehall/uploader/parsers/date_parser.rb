require "whitehall/uploader/parsers"

class Whitehall::Uploader::Parsers::DateParser
  def self.parse(date, logger, line_number)
    return nil if date.blank?
    begin
      if date =~ /^\d{1,2}\-[A-Za-z]{3}\-\d{4}/
        Date.strptime(date, '%d-%b-%Y')
      elsif date =~ /^\d{1,2}\-[A-Za-z]{3}\-\d{2}/
        Date.strptime(date, '%d-%b-%y')
      elsif date =~ /\d{4}\-\d{2}\-\d{2}/
        Date.strptime(date, '%Y-%m-%d')
      else
        Date.strptime(date, '%m/%d/%Y')
      end
    rescue
      logger.warn "Row #{line_number}: Unable to parse the date '#{date}'"
      nil
    end
  end
end