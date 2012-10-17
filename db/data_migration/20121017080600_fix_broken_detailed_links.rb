SLUG_MAPS = {
  'expenses-and-benefits-payments-in-kind-that-can-be-cashed-in' => 'expenses-benefits-payments-in-kind',
  'fixed-penalties-and-vehicle-immobilisation-for-commercial-drivers' => 'fixed-penalties-immobilisations-commercial-drivers',
  'transfer-your-driving-instructor-registration-to-great-britain' => 'transfer-driving-instructor-registration-gb',
  'expenses-and-benefits-scholarship-for-employees-family-member' => 'expenses-benefits-scholarship-family-employee',
  'feed-in-tariffs-get-money-for-generating-your-own-electricity' => 'feed-in-tarriffs-money-for-generating-electricity',
  'shared-ownership-for-council-and-housing-association-tenants' => 'shared-ownership-tenants',
  'change-name-address-on-vehicle-registration-certificate-v5c' => 'change-name-address-vehicle-reg-certificate-v5c',
  'expenses-and-benefits-assets-made-available-to-an-employee' => 'expenses-benefits-assets-available-to-employee',
  'identity-documents-needed-for-driving-licence-applications' => 'driving-licence-application-identity-documents',
  'transferring-your-vehicle-registration-number-form-v317' => 'transferring-vehicle-registration-number-form-v317',
  'your-rights-if-your-travel-company-or-airline-goes-bust' => 'your-rights-travel-company-or-airline-goes-bust',
  'renew-your-approved-driving-instructor-adi-registration' => 'renew-approved-driving-instructor-adi-registration',
  'book-a-national-driver-offender-retraining-scheme-course' => 'book-national-driver-offender-retraining-course',
  'manage-your-approved-driving-instructor-adi-registration' => 'manage-approved-driving-instructor-registration',
  'driver-certificate-of-professional-competence-driver-cpc' => 'driver-certificate-of-professional-competence-cpc',
  'arranging-child-maintenance-through-child-support-agency' => 'arranging-child-maintenance-child-support-agency',
  'update-your-approved-driving-instructor-adi-registration' => 'update-approved-driving-instructor-registration',
  'approved-driving-instructor-adi-professional-development' => 'approved-driving-instructor-adi-development',
  'employer-reporting-introduction-to-expenses-and-benefits' => 'employer-reporting-expenses-benefits',
  'apply-for-your-first-approved-driving-instructor-adi-badge' => 'apply-first-approved-driving-instructor-adi-badge',
  'expenses-and-benefits-school-fees-for-employees-child' => 'expenses-benefits-school-fees-for-employees-child',
  'remove-expired-endorsements-from-your-driving-licence' => 'remove-expired-endorsements-from-driving-licence',
  'prepare-and-file-annual-accounts-for-a-limited-company' => 'prepare-file-annual-accounts-for-limited-company',
  'expenses-and-benefits-offshore-oil-and-gas-transfers' => 'expenses-benefits-offshore-oil-gas-transfers',
  'definition-of-disability-under-the-equality-act-2010' => 'definition-of-disability-under-equality-act-2010',
  'practice-large-goods-vehicle-lgv-driving-theory-test' => 'practice-large-goods-vehicle-driving-theory-test',
  'criminal-record-check-to-become-a-driving-instructor' => 'criminal-record-check-become-driving-instructor',
  'late-commercial-payments-interest-debt-recovery-costs' => 'late-commercial-payments-interest-debt-recovery',
  'get-birthday-or-anniversary-message-from-the-queen' => 'get-birthday-anniversary-message-from-queen',
  'find-your-lost-theory-test-pass-certificate-number' => 'find-lost-theory-test-pass-certificate-number',
  'uk-online-centre-internet-access-computer-training' => 'ukonline-centre-internet-access-computer-training',
  'dsa-practical-test-booking-service-data-protection' => 'dsa-practical-test-booking-data-protection',
  'energy-performance-certificate-commercial-property' => 'energy-performance-certificate-commercial-property',
  'who-can-sign-passport-driving-licence-applications' => 'who-can-sign-passport-driving-licence-applications',
  'student-finance-evidence-given-by-parents-partners' => 'student-finance-evidence-from-parents-partners',
  'pass-plus-approved-driving-instructor-adi-services' => 'pass-plus-approved-driving-instructor-services',
  'expenses-and-benefits-incidental-overnight-expenses' => 'expenses-benefits-incidental-overnight-expenses',
  'when-a-mental-health-condition-becomes-a-disability' => 'when-mental-health-condition-becomes-disability',
  'expenses-and-benefits-maternity-suspension-payments' => 'expenses-benefits-maternity-suspension-payments',
  'expenses-and-benefits-credit-debit-and-charge-cards' => 'expenses-benefits-credit-debit-charge-cards',
  'tax-credits-if-you-are-moving-country-or-travelling' => 'tax-credits-if-moving-country-or-travelling',
  'expenses-and-benefits-compensation-injuries-at-work' => 'expenses-benefits-compensation-injuries-at-work',
  'getting-your-vehicle-back-if-its-been-wheel-clamped' => 'getting-vehicle-back-if-its-been-wheel-clamped',
  'support-available-for-families-friends-of-prisoners' => 'support-for-families-friends-of-prisoners',
  'mobility-scooters-and-powered-wheelchairs-the-rules' => 'mobility-scooters-and-powered-wheelchairs-rules',
  'national-insurance-contributions-nics-for-employers' => 'national-insurance-contributions-for-employers',
  'contact-your-local-council-about-your-business-rates' => 'contact-your-local-council-about-business-rates',
  'look-up-adoption-records' => 'adoption-records',
  'holiday-entitlement-your-rights' => 'holiday-entitlement-rights',
  'starting-a-business' => 'legal-structures-new-business',
  'ownerless-property-bona-vacantia' => 'unclaimed-estates-bona-vacantia',
  'vehicle-type-approval' => 'vehicle-approval',
  'school-uniform-law' => 'school-uniform',
  'apply-help-school-clothing-costs' => 'help-school-clothing-costs',
  'your-rights-as-a-trade-union-rep' => 'rights-of-trade-union-reps',
  'monitored-at-work-your-rights' => 'monitoring-work-workers-rights',
  'business-transfers-and-takeovers-your-rights' => 'business-transfers-takeovers-workers-rights'
}

creator = User.find_by_name!("Automatic Data Importer")
PaperTrail.whodunnit = creator

SLUG_MAPS.each do |old_slug, new_slug|
  relevant_guides = DetailedGuide.where("body LIKE ?", "%/#{old_slug})%").all
  puts "Found #{relevant_guides.length} guides that contain #{old_slug}"
  relevant_guides.each do |guide|
    begin
      guide.body = guide.body.gsub(old_slug, new_slug)
      guide.save!
      puts "Updated #{guide.id}"
    rescue => e
      $stderr.puts "Unable to save '#{guide.id}' because #{e}"
    end
  end
end
