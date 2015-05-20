Feature: Editing draft policies
In order to allow the public to view policies
A writer should be able to edit and save draft policies
A departmental editor should be able to publish policies
In order to obtain useful information about government
A member of the public Should be able to view policies

Background:
  Given I am a writer

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
  Then I should see that the policy only applies to:
    | England | Scotland |

Scenario: Viewing the activity around a policy
  Given a published policy "What Makes A Beard" exists
  And a published publication "Standard Beard Lengths" related to the policy "What Makes A Beard"
  And a published consultation "Measuring Beard Length" related to the policy "What Makes A Beard"
  And a published news article "Beards Give You Cancer" related to the policy "What Makes A Beard"
  And a published speech "My Kingdom For A Beard" related to the policy "What Makes A Beard"
  When I visit the activity of the published policy "What Makes A Beard"
  Then I can see links to the recently changed document "Standard Beard Lengths"
  And I can see links to the recently changed document "Measuring Beard Length"
  And I can see links to the recently changed document "Beards Give You Cancer"
  And I can see links to the recently changed document "My Kingdom For A Beard"
