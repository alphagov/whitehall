module DatetimeFieldHelper
	def fill_in_date_and_time_field(date)
		date = Time.zone.parse(date)

		select date.year, from: "Year"
		select date.strftime("%B"), from: "Month"
		select date.day, from: "Day"
		select date.strftime("%H"), from: "Hour"
		select date.strftime("%M"), from: "Minute"
	end

	def fill_in_date_fields(date)
		date = Time.zone.parse(date)

		select date.year, from: "Year"
		select date.strftime("%B"), from: "Month"
		select date.day, from: "Day"
	end

end
World(DatetimeFieldHelper)
