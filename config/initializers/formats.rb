Date::DATE_FORMATS[:long_ordinal] = lambda { |date| date.strftime("%e %B %Y").strip }
Date::DATE_FORMATS[:short_ordinal] = lambda { |date| date.strftime("%B %Y").strip }
Date::DATE_FORMATS[:uk_short] = lambda { |date| date.strftime("%d/%m/%Y").strip }
Time::DATE_FORMATS[:long_ordinal] = lambda { |time| time.strftime("%e %B %Y %H:%M").strip }

