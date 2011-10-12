Feature: Viewing published policies
In order to obtain useful information about government
A member of the public
Should be able to view policies

Scenario: Publishing a policy that has a PDF attachment
  Given a published policy titled "Policy" with a PDF attachment
  When I visit the policy titled "Policy"
  Then I should see a link to the PDF attachment

Scenario: Viewing a policy that appears in multiple topics
  Given a published policy titled "Policy" that appears in the "Education" and "Work and pensions" topics
  When I visit the policy titled "Policy"
  Then I should see links to the "Education" and "Work and pensions" topics

Scenario: Viewing a policy that has supporting documents
  Given a published policy titled "Outlaw Moustaches" with supporting documents "Waxing Dangers" and "Hair Lip"
  Then I can visit the supporting document "Waxing Dangers" from the "Outlaw Moustaches" policy
  And I can visit the supporting document "Hair Lip" from the "Outlaw Moustaches" policy

Scenario: Viewing a policy that has multiple responsible ministers
  Given a published policy titled "Policy" that's the responsibility of:
    | Ministerial Role  | Person          |
    | Attorney General  | Colonel Mustard |
    | Solicitor General | Professor Plum  |
  When I visit the policy titled "Policy"
  Then I should see that those responsible for the policy are:
    | Ministerial Role  | Person          |
    | Attorney General  | Colonel Mustard |
    | Solicitor General | Professor Plum  |