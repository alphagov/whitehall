Feature: Viewing published policies
In order to obtain useful information about government
A member of the public
Should be able to view policies

Scenario: Viewing a policy that appears in multiple topics
  Given a published policy "Policy" that appears in the "Education" and "Work and pensions" topics
  When I visit the policy "Policy"
  Then I should see links to the "Education" and "Work and pensions" topics

Scenario: Viewing a policy that has supporting documents
  Given a published policy "Outlaw Moustaches" with supporting documents "Waxing Dangers" and "Hair Lip"
  Then I can visit the supporting document "Waxing Dangers" from the "Outlaw Moustaches" policy
  And I can visit the supporting document "Hair Lip" from the "Outlaw Moustaches" policy

Scenario: Viewing a policy that has multiple responsible ministers
  Given a published policy "Policy" that's the responsibility of:
    | Ministerial Role  | Person          |
    | Attorney General  | Colonel Mustard |
    | Solicitor General | Professor Plum  |
  When I visit the policy "Policy"
  Then I should see that those responsible for the policy are:
    | Ministerial Role  | Person          |
    | Attorney General  | Colonel Mustard |
    | Solicitor General | Professor Plum  |

Scenario: Viewing a policy that is applicable to certain nations
  Given a published policy "Haggis for every meal" that does not apply to the nations:
    | Northern Ireland | Wales |
  When I visit the policy "Haggis for every meal"
  Then I should see that the policy does not apply to:
    | Northern Ireland | Wales |

Scenario: Viewing a policy that has multiple publications associated
  Given a published policy "What Makes A Beard" with related published publications "Standard Beard Lengths" and "Exotic Beard Lengths"
  When I visit the published policy "What Makes A Beard"
  Then I can see links to the related published publications "Standard Beard Lengths" and "Exotic Beard Lengths"

Scenario: Viewing a policy that has multiple consultations associated
  Given a published policy "What Makes A Beard" with related published consultations "Standard Beard Lengths" and "Exotic Beard Lengths"
  When I visit the published policy "What Makes A Beard"
  Then I can see links to the related published consultations "Standard Beard Lengths" and "Exotic Beard Lengths"

Scenario: Viewing a policy that has multiple news articles associated
  Given a published policy "What Makes A Beard" with related published news articles "Standard Beard Lengths" and "Exotic Beard Lengths"
  When I visit the published policy "What Makes A Beard"
  Then I can see links to the related published news articles "Standard Beard Lengths" and "Exotic Beard Lengths"

Scenario: Viewing a policy that has draft publication associated
  Given a published policy "What Makes A Beard" with related draft publication "Proposed Beard Lengths"
  Then I should not see "Proposed Beard Lengths" from the "What Makes A Beard" policy