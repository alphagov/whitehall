# We want to resend these documents to rummager so that the content_id is added to stored record

statistics_announcement_slugs = %w(
  /government/statistics/announcements/care-information-choices-england-december-2015
  /government/statistics/announcements/statistical-release-for-reported-treasure-finds-2012-and-2013
  /government/statistics/announcements/uk-trade-statistics-with-countries-outside-the-european-union-june-2014
  /government/statistics/announcements/uk-trade-statistics-with-countries-in-the-european-union-june-2014
  /government/statistics/announcements/service-settings-and-places-regulated-by-care-and-social-services-inspectorate-wales-30-june-2014
  /government/statistics/announcements/revenue-outturn-ro-2013-14-supplementary-tables-on-local-council-tax-support
  /government/statistics/announcements/affordable-housing-starts-and-completions--2
  /government/statistics/announcements/production-and-services-industries-turnover-and-order-uk-october-2015
  /government/statistics/announcements/accident-and-emergency-weekly-data-week-ending-24-august-2014
  /government/statistics/announcements/insolvency-statistics-january-to-march-2015
  /government/statistics/announcements/hes-mhmds-data-linkage-report-experimental-summary-statistics-november-2014
  /government/statistics/announcements/school-games-indicator-2013-2014
  /government/statistics/announcements/second-estimate-of-the-vat-gap-tax-year-2013-to-2014
  /government/statistics/announcements/nhs-maternity-statistics-england-2014-15
  /government/statistics/announcements/hes-mhld-data-linkage-report-summary-statistics-june-2015
  /government/statistics/announcements/monthly-asylum-statistics-may-2014
  /government/statistics/announcements/weekly-data-on-births-and-deaths-registered-in-scotland-september-2015
  /government/statistics/announcements/general-and-personal-medical-services-england-2005-to-2015-as-at-30-sep
  /government/statistics/announcements/broadband-performance-indicator-july-to-september-2014
  /government/statistics/announcements/fly-tipping-statistics-for-england-2014-to-2015
  /government/statistics/announcements/insolvency-statistics-july-to-september-2015
  /government/statistics/announcements/museums-and-galleries-monthly-visits-september-results
  /government/statistics/announcements/council-tax-reduction-in-scotland-april-2015-to-september-2015
  /government/statistics/announcements/forest-resources-assessment-2015-report--2
  /government/statistics/announcements/mental-health-and-learning-disabilities-statistics-monthly-report-final-june-2015-and-provisional-july-2015--2
  /government/statistics/announcements/northern-ireland-health-and-social-care-inequalities-monitoring-system-sub-regional-2014
  /government/statistics/announcements/uk-trade-statistics-with-countries-in-the-european-union-july-2014--2
  /government/statistics/announcements/national-diet-and-nutrition-survey-rolling-programme-2008-to-2012-results
  /government/statistics/announcements/monitor-of-engagement-with-the-natural-environment-quarterly-results
  /government/statistics/announcements/insolvency-statistics-april-to-june-2015
  /government/statistics/announcements/strategic-export-controls-licensing-statistics-1-april-to-30-june-2015
  /government/statistics/announcements/access-to-work-individuals-helped-to-june-2015
  /government/statistics/announcements/deaths-registered-in-england-and-wales-provisional-week-ending-20-october-2015
  /government/statistics/announcements/patient-reported-outcome-measures-proms-in-england-provisional-april-2013-to-march-2014-april-2015-release--2
  /government/statistics/announcements/womens-smoking-status-at-time-of-delivery-in-england-october-2014-to-december-2014
  /government/statistics/announcements/improving-access-to-psychological-therapies-iapt-in-england-final-data-quality-reports-december-2014-and-provisional-january-2015
  /government/statistics/announcements/northern-ireland-housing-bulletin-april-to-june-2015
  /government/statistics/announcements/insolvency-statistics-october-to-december-2015
  /government/statistics/announcements/june-agricultural-and-horticultural-survey-final-results-ni-2014
  /government/statistics/announcements/monthly-property-transactions-completed-in-the-uk-with-value-of-40000-or-above--11
  /government/statistics/announcements/monthly-data-on-deaths-registered-in-scotland-september-2015
  /government/statistics/announcements/northern-ireland-local-authority-collected-municipal-waste-management-statistics-report-october-to-december-2015--2
  /government/statistics/announcements/drug-treatment-statistics-in-england-october-2014
  /government/statistics/announcements/butterflies-in-the-wider-countryside-england-1990-to-2014
  /government/statistics/announcements/cold-weather-payments-1-nov-2015-to-25-mar-2016
  /government/statistics/announcements/football-related-arrests-and-banning-orders-season-2014-to-2015
  /government/statistics/announcements/impact-on-gdp-cp-and-cvm-quarterly-and-annual-estimates-1997-2014
  /government/statistics/announcements/delayed-transfers-of-care-for-october-2015
  /government/statistics/announcements/poverty-calculator-what-are-your-chances-of-experiencing-poverty-in-adulthood
  /government/statistics/announcements/capital-payments-and-receipts-live-table-cpr1-4-update-to-q2-2015-to-2016-april-to-september
  /government/statistics/announcements/capital-payments-and-receipts-live-table-cpr1-4-update-to-q4-2014-15
  /government/statistics/announcements/ated-annual-tax-on-enveloped-dwellings-return-statistics-november-2014
  /government/statistics/announcements/individual-voluntary-arrangements-ivas-outcome-statistics-1990-to-2014
  /government/statistics/announcements/accident-and-emergency-weekly-data-week-ending-10-august-2014
  /government/statistics/announcements/nhs-gp-referrals-for-first-out-patient-appointments-september-2015
  /government/statistics/announcements/winter-mortality-in-scotland-201415
  /government/statistics/announcements/measuring-tax-gaps-october-2015
  /government/statistics/announcements/uk-milk-prices-and-composition-of-milk-january-2016
  /government/statistics/announcements/butterflies-in-the-wider-countryside-uk-1976-to-2014
  /government/statistics/announcements/nhs-111-minimum-dataset-for-october-2015
  /government/statistics/announcements/gross-domestic-product-preliminary-estimate-april-to-june-2016
  /government/statistics/announcements/civil-partnership-statistics-in-the-uk-2014
  /government/statistics/announcements/vat-factsheet-2014-15
  /government/statistics/announcements/farming-statistics-provisional-2015-cereal-and-oilseed-rape-production-estimates-united-kingdom
  /government/statistics/announcements/accommodation-bedstock-in-wales-2014
  /government/statistics/announcements/direct-access-audiology-waiting-times-september-2014
  /government/statistics/announcements/forestry-facts-and-figures-2014-edition
  /government/statistics/announcements/cold-weather-payments-1-nov-2015-to-1-apr-2016
  /government/statistics/announcements/hospital-patient-care-in-accident-and-emergency-provisional-april-2014-to-november-2014
  /government/statistics/announcements/youth-work-financial-year-ending-31-march-2015
  /government/statistics/announcements/fe-choices-learner-satisfaction-data-2014-to-2015
  /government/statistics/announcements/uk-armed-forces-recovery-capability-wounded-injured-and-sick-201516
  /government/statistics/announcements/capital-payments-and-receipts-live-table-cpr1-4-update-to-q1-2015-16-april-to-june
  /government/statistics/announcements/local-authority-municipal-waste-management-january-to-march-2014
  /government/statistics/announcements/quality-and-outcomes-framework-statistics-for-northern-ireland-201415
  /government/statistics/announcements/uk-stamp-tax-statistics
  /government/statistics/announcements/regional-insolvency-statistics-2014--2
  /government/statistics/announcements/road-safety-in-wales-2013
  /government/statistics/announcements/excess-winter-mortality-northern-ireland-201415
  /government/statistics/announcements/insolvency-statistics-october-to-december-2015--2
  /government/statistics/announcements/help-to-buy-equity-loan-scheme-monthly-statistics-april-2013-to-october-2014
  /government/statistics/announcements/drug-treatment-statistics-in-england-september-2014
  /government/statistics/announcements/key-welsh-economic-statistics-august-2014
  /government/statistics/announcements/widening-higher-education-participation-measures-2014-update
  /government/statistics/announcements/hospital-patient-care-in-accident-and-emergency-provisional-april-2014-to-october-2014
  /government/statistics/announcements/council-tax-reduction-in-scotland-october-2015-to-december-2015
  /government/statistics/announcements/nhs-staff-earnings-estimates-estimates-to-june-2015-provisional-statistics
  /government/statistics/announcements/monthly-statistics-of-building-materials-and-components-no-488-october-2015
  /government/statistics/announcements/hes-mhmds-data-linkage-report-experimental-summary-statistics-december-2014
  /government/statistics/announcements/mental-health-and-learning-disabilities-statistics-monthly-report-final-july-2015-and-provisional-august-2015
  /government/statistics/announcements/personal-tax-credits-statistics-july-2014
  /government/statistics/announcements/nhs-expenditure-programme-budgets-financial-year-ending-march-2015--2
  /government/statistics/announcements/size-and-performance-of-the-northern-ireland-food-and-drinks-processing-sector-subsector-statistics-201314
  /government/statistics/announcements/ambulance-quality-indicators-system-indicators-july-2014
  /government/statistics/announcements/monthly-property-transactions-completed-in-the-uk-with-value-of-40000-or-above--10
  /government/statistics/announcements/monitor-of-engagement-with-the-natural-environment-thematic-report-march-2014-to-february-2015
  /government/statistics/announcements/renewable-heat-incentive-rhi-quarterly-report-march-2016
  /government/statistics/announcements/dental-earnings-and-expenses-in-england-and-wales-2012-to-2013
  /government/statistics/announcements/help-to-buy-equity-loan-scheme-and-help-to-buy-newbuy-statistics-april-2013-to-june-2014
  /government/statistics/announcements/cold-weather-payments-1-nov-to-18-dec-2015
  /government/statistics/announcements/general-and-personal-medical-services-england-2005-to-2015-as-at-30-sep--2
  /government/statistics/announcements/revenue-account-ra-budget-2014-15-supplementary-tables-on-local-council-tax-support
  /government/statistics/announcements/individual-voluntary-arrangements-ivas-outcome-statistics-1990-to-2013
  /government/statistics/announcements/help-to-buy-equity-loan-scheme-and-help-to-buy-newbuy-statistics-april-2013-to-september-2014
  /government/statistics/announcements/measuring-national-well-being-health-2015
  /government/statistics/announcements/small-area-model-based-income-estimates-2011-to-2012
  /government/statistics/announcements/council-tax-reduction-in-scotland-july-2015-to-september-2015
  /government/statistics/announcements/community-mental-health-survey
  /government/statistics/announcements/insolvency-service-enforcement-outcomes-experimental-statistics-july-to-september-2016
  /government/statistics/announcements/provisional-monthly-patient-reported-outcome-measures-proms-in-england-april-2015
  /government/statistics/announcements/northern-ireland-annual-survey-of-hours-and-earnings-2015
  /government/statistics/announcements/cold-weather-payments-1-nov-2015-to-18-mar-2016
  /government/statistics/announcements/personal-tax-credits-finalised-award-statistics-small-area-data-lsoa-and-data-zone-201314
  /government/statistics/announcements/northern-ireland-local-authority-collected-municipal-waste-management-statistics-report-april-to-june-2014
  /government/statistics/announcements/ni-tourism-statistics-oct-13-to-sep-14
  /government/statistics/announcements/hospital-patient-care-in-accident-and-emergency-provisional-april-2014-to-december-2014
  /government/statistics/announcements/water-usage-on-farms-results-from-the-farm-business-survey-england-201314
  /government/statistics/announcements/capital-payments-and-receipts-live-table-cpr1-4-update-to-q3-2014-15
  /government/statistics/announcements/quarterly-supplement-to-the-labour-market-report-oct-dec-2015
  /government/statistics/announcements/marriages-in-england-and-wales-provisional-for-same-sex-couples-2014
  /government/statistics/announcements/diagnostic-imaging-dataset-for-september-2015
  /government/statistics/announcements/welsh-health-survey-local-authority-and-health-board-results-2012-and-2013
  /government/statistics/announcements/weekly-road-fuel-prices-19-october-2015
  /government/statistics/announcements/social-care-negligence-cases-in-northern-ireland-2013-to-2014
  /government/statistics/announcements/mental-health-and-learning-disabilities-statistics-monthly-report-final-june-2015-and-provisional-july-2015
  /government/statistics/announcements/children-and-young-peoples-well-being-in-the-uk-october-2015
  /government/statistics/announcements/labour-productivity-1998-2014
)

outcomes = { updated: 0, missing: 0, removed: 0 }
statistics_announcement_slugs.each do |path|
  slug = path.split('/').last
  sa = StatisticsAnnouncement.find_by(slug: slug)
  if sa
    if sa.can_index_in_search?
      sa.update_in_search_index
      outcomes[:updated] += 1
    else
      # This means a publication exists for the announcement and the search entry should be
      # deleted as per `app/services/service_listeners/announcement_clearer.rb`
      sa.remove_from_search_index
      outcomes[:removed] += 1
    end
  else
    puts "Missing #{path}"
    outcomes[:missing] += 1
  end
end

pp outcomes
