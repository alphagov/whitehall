Date::DATE_FORMATS[:long_ordinal] = ->(date) { date.strftime("%e %B %Y").strip }
Date::DATE_FORMATS[:short_ordinal] = "%B %Y"
Date::DATE_FORMATS[:uk_short] = ->(date) { date.strftime("%d/%m/%Y").strip }
Time::DATE_FORMATS[:long_ordinal] = ->(time) { time.strftime("%e %B %Y %H:%M").strip }
Time::DATE_FORMATS[:date_with_time] = ->(time) { [time.strftime("%e %B %Y").strip, time.strftime("%l:%M%P").strip].join(" ") }
Time::DATE_FORMATS[:one_month_precision] = "%B %Y"
Time::DATE_FORMATS[:two_month_precision] = lambda do |time|
  opening_month = time.strftime("%B")
  (time + 1.month).strftime("#{opening_month} to %B %Y").strip
end
