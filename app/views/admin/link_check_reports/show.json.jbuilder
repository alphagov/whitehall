json.html render partial: "link_check_report", locals: { report: @report, allow_new_report: @allow_new_report }, formats: [:html]
json.in_progress @report.in_progress?
