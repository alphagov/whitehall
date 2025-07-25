class ParamsPreprocessors::TelephonePreprocessor
  def initialize(params)
    @params = params
  end

  def processed_params
    process!
    params
  end

  def process!
    if params.dig("content_block/edition", "details", "telephones", "opening_hours")
      params["hours_available"] ? format_opening_hours : strip_opening_hours
    end

    params["content_block/edition"]["details"]["telephones"]["call_charges"] = format_call_charges
    params["content_block/edition"]["details"]["telephones"]["bsl_guidance"] = format_bsl_guidance
    params["content_block/edition"]["details"]["telephones"]["video_relay_service"] = video_relay_service
  end

private

  attr_accessor :params

  def format_call_charges
    call_charges = params["content_block/edition"]["details"]["telephones"]["call_charges"]
    if call_charges
      call_charges["show_call_charges_info_url"] = ActiveRecord::Type::Boolean.new.cast(call_charges["show_call_charges_info_url"]) || false

      if call_charges["show_call_charges_info_url"] == false
        call_charges = {}
      end

      call_charges
    end
  end

  def format_bsl_guidance
    bsl_guidance = params["content_block/edition"]["details"]["telephones"]["bsl_guidance"]
    if bsl_guidance
      bsl_guidance["show"] = ActiveRecord::Type::Boolean.new.cast(bsl_guidance["show"]) || false

      if bsl_guidance["show"] == false
        bsl_guidance = {}
      end

      bsl_guidance
    end
  end

  def video_relay_service
    obj = params["content_block/edition"]["details"]["telephones"]["video_relay_service"]
    if obj
      obj["show"] = ActiveRecord::Type::Boolean.new
        .cast(obj["show"]) || false

      if obj["show"] == false
        obj = {}
      end

      obj
    end
  end

  def format_opening_hours
    params["content_block/edition"]["details"]["telephones"]["opening_hours"].map! do |hours|
      {
        "day_from" => hours["day_from"],
        "day_to" => hours["day_to"],
        "time_from" => format_time(hours, "time_from"),
        "time_to" => format_time(hours, "time_to"),
        "_destroy" => hours["_destroy"],
      }
    end
  end

  def strip_opening_hours
    params["content_block/edition"]["details"]["telephones"]["opening_hours"] = []
  end

  def format_time(hours, prefix)
    h = hours["#{prefix}(h)"]
    m = hours["#{prefix}(m)"]
    meridian = hours["#{prefix}(meridian)"]
    "#{h}:#{m}#{meridian}"
  end
end
