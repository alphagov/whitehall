require "test_helper"

module PublishingApi
  module PayloadBuilder
    class PayloadBuilderHeaderTest < ActiveSupport::TestCase
      test "benchmark testing" do
        require "benchmark"

        # /government/organisations/department-of-health-and-social-care/about/personal-information-charter
        corp_info_markdown = <<~MARKDOWN
          The charter covers correspondence, involvement in public policy consultations or any other dealings that lead to us holding personal information about you.\n\n## What you can expect from us, and what we ask from you\n\nWe need to handle personal information about you so that we can provide better services.\n\nHigh standards in handling personal information are very important to us, because they help us maintain the confidence of everyone who deals with us. So when we ask you for personal information, we will process your personal data in line with our [privacy notice](/government/admin/publications/1132627).\n\nIn return, we ask you to:\n\n* give us accurate information\n* tell us as soon as possible if there are any changes, such as a new address\n* let us know, at the time of writing, if you would like your correspondence or enclosed documents returned to you\n\nThis helps us to keep your information reliable and up to date, and ensures your correspondence is returned if requested.\n\n## Agencies and arm<E2><80>
          <99>s length bodies\n\nMost of [our agencies and arm<E2><80><99>s length bodies](https://www.gov.uk/government/organisations#department-of-health-and-social-care) hold personal data for specific purposes that are set out in their own information charters. For example, NHS Blood and Transplant holds information on patients requiring transplants so that a match can be arranged efficiently once an organ becomes available.\n\n## How we protect your personal data at DHSC \n\nWhen we process your information we will keep to the law, including the General Data Protection Regulation and the Data Protection Act 2018. Through appropriate management and strict controls, we will follow the [7 principles of data protection](https://ico.org.uk/for-organisations/guide-to-the-general-data-protection-regulation-gdpr/principles/) described in the act.\n\nWe will also ensure that:\n\n* there is someone with specific responsibility for data protection in the organisation (the nominated person is called the Data Protection Officer)\n* everyone managing and handling personal information understands that they are contractually responsible for following good data protection practice, is appropriately trained to do so and is appropriately supervised\n* we deal with enquiries about how we handle personal information promptly and courteously\n* we describe how we handle personal information clearly, regularly review and audit how we manage personal information, and regularly assess and evaluate methods of handling personal information\n\n##How to contact DHSC's Data Protection Officer \n\nThe contact details for our Data Protection Officer are:\n\n$A\nData Protection Officer\nDepartment of Health and Social Care\n39 Victoria Street\nLondon\nSW1H 0EU\n$A\n\nEmail: <data_protection@dhsc.gov.uk>\n\n\n## How to make a 'right of access' request to DHSC\n\nThe Data Protection Act allows you to find out what information we hold about you. This is known as the <E2><80><98>right of access<E2><80><99>. We do not charge a fee for this service.\n\nTo request access to personal data DHSC holds about you, please email us at <data_protection@dhsc.gov.uk>, or write to us at the address given above. \n\nWe are required to supply you with your personal data within one calendar month of receiving a valid request. If we cannot meet this deadline, we'll keep you informed of progress towards fulfilling your request.\n\n## Find out more about how we deal with personal information\n\nTo find out more about how we deal with personal information, see: \n\n* the [DHSC privacy notice](https://www.gov.uk/government/publications/dhsc-privacy-notice)\n* [How DHSC processes special category data](/government/admin/publications/1493563)\n\nContact us at <data_protection@dhsc.gov.uk> (or write to us at the address given above) if you'd like a hard copy of our personal information charter or want to find out about:\n\n* agreements we have with other organisations for sharing information\n* circumstances where we can pass on your personal information without telling you - for example, to prevent and detect crime or to produce anonymised statistics\n* our instructions to staff on how to collect, use and delete your personal information\n* how we check the information we hold is accurate and up to date\n\n\n## Independent advice on data protection and privacy\n\nYou can get independent advice about data protection, privacy and data-sharing issues from the [Information Commissioner's Office (ICO)](https://ico.org.uk/). \n\nYou can contact them at:\n\n$A\nThe Information Commissioner's Office\nWycliffe House\nWater Lane\nWilmslow\nCheshire\nSK9 5AF\n$A\n\nTelephone: 0303 123 1113  \n\n*[ICO]: Information Commissioner's Office \n*[NHS]: National Health Service\n*[DHSC]: Department of Health and Social Care\n\n
        MARKDOWN

        corp_item = stub(body: corp_info_markdown)

        # /guidance/imports-and-exports-of-animals-and-animal-products-topical-issues
        long_markdown = <<~MARKDOWN
          This page provides details on particular issues or changes that importers and exporters may need to be aware of.#{' '}

          You can view all of the Department for Environment, Food and Rural Affairs' (Defra's) guidance and forms for:

          - [importing live animals or animal products](https://www.gov.uk/government/collections/guidance-on-importing-live-animals-or-animal-products)
          - [exporting live animals or animal products](https://www.gov.uk/government/collections/guidance-on-exporting-live-animals-or-animal-products)
          #{' '}
          Defra’s [animal disease monitoring collection](/government/admin/collections/584800) covers major, notifiable or new and emerging animal disease outbreaks internationally and in the UK.

          ## Foot and mouth disease (FMD)

          ###Commercial trade

          Outbreaks of foot and mouth disease (FMD) have been reported in:

          * Germany on 10 January 2025
          * Hungary on 7 March 2025 (with an additional outbreak reported near the Austrian border on 26 March 2025)
          * Slovakia on 21 March 2025

          This means that there are restrictions in place on the import of the following commodities from Austria, Hungary, Slovakia and parts of Germany:#{' '}

          * live (including non-domestic) ruminant and porcine animals, including wild game, and their germplasm
          * fresh meat from ruminant and porcine animals (including chilled and frozen)
          * meat products from ruminant and porcine animals that have not been subject to specific treatment D1, D, C or B (including wild game)
          * milk, colostrum and their products, unless subjected to treatment as defined in Article 4 of Regulation 2010/605
          * certain animal by-products
          * hay and straw

          The restrictions on the import of these commodities apply to the entire territories of Austria, Hungary and Slovakia.

          Following an assessment, Great Britain has now recognised regionalisation for FMD in Germany at the level of the containment zone. The containment zone extends to 6 kilometres (km) around the outbreak and is defined in the relevant third country lists and safeguard declarations. This means that the export of affected commodities can resume from the areas outside of the containment zone in Germany to Great Britain provided all other import conditions are met, including that certificates can be signed. These restrictions will apply until further notice.#{' '}

          Restrictions are set out in the relevant lists of [EU and EFTA countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/4698a65d-1a3b-42d1-981e-df869e04185b/export-of-animals-and-animal-products-to-the-uk) and in the following safeguard declarations.

          ### Declaration of special measures: hay and straw and certain animal by-products

          For hay and straw and certain animal by-products, the following safeguard measures give effect to this decision. These are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Deputy First Minister and Cabinet Secretary for Climate Change and Rural Affairs (Wales) and the Cabinet Secretary for Rural Affairs and Islands (Scotland).

          Read the:

          * [AttachmentLink: FMD_Declaration_-_ABP_-_England__27_March_2025_.pdf]
          * [AttachmentLink: Draft_Germany_-_FMD_-_Safeguard_-_Updated_24.03.25.pdf]
          * [AttachmentLink: FMD_Declaration_-_Certain_Products_-_Wales__27_March_2025_.pdf]
          * [AttachmentLink: FMD_-_Special_Measures_Certain_Products__Wales__-_24_March_2025_-_FINAL_SIGNED_DCVO.pdf]
          * [AttachmentLink: FMD_Declaration_-_Certain_Products_-_Scotland__27_March_2025_.pdf]
          * [AttachmentLink: Signed_SG_Return_-_Draft_Declaration_-_Special_Measures_-_ABP_-_Germany_-_Containment_Zone_Revision__002_.pdf]

          The special measures for Austria, Hungary and Slovakia apply from 28 March 2025, until revoked or amended. The special measures for Germany apply from 25 March 2025, until revoked or amended.

          ### Declaration of special measures: importation of untreated wool and hair of susceptible animals for certain third countries and territories

          Imports of untreated wool and hair of species susceptible to FMD (except porcines) are only permitted from countries or zones that are recognised as free of FMD by the [World Organisation for Animal Health (WOAH)](https://www.woah.org/en/disease/foot-and-mouth-disease/#ui-id-2). Imports must also be accompanied by:

          * a commercial document, or importer declaration (if applicable)
          * the health certificate provided in the safeguard declaration (only applicable to countries with FMD that are exporting from FMD-free zones)

          Safeguard declarations give effect to this decision. These are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Cabinet Secretary for Rural Affairs and Islands (Scotland) and Deputy First Minister and Cabinet Secretary for Climate Change and Rural Affairs (Wales).

          * [AttachmentLink: England_Safeguard_Declaration_Untreated_hair_and_GBHC590.pdf]
          * [AttachmentLink: FMD_Declaration_-_Untreated_Wool_and_Hair_-_England__27_March_2025_.pdf]
          * [AttachmentLink: Wales_Safeguard_Declaration_Untreated_hair_and_GBHC590.pdf]
          * [AttachmentLink: FMD_Declaration_-_Hair_and_Wool_-_Wales__27_March_2025_.pdf]
          * [AttachmentLink: FMD_Declaration_-_Wool_and_Hair_-_Scotland__27_March_2025_.pdf]
          #{' '}
          For England and Wales, these special measures apply from 17 January 2025. They continue to apply as amended from 28 March 2025 until they are revoked.

          For Scotland, this measure applies from 28 March 2025 until it is revoked or amended. This measure replaces the measure published on 25 March 2025.

          ### Declaration of special measures: importation of animal casings of susceptible animals for certain third countries and territories

          Imports of animal casings of species susceptible to FMD, classical swine fever (CSF) and African swine fever (ASF) without specific risk mitigating treatment are only permitted from [EU and EFTA countries](https://www.data.gov.uk/dataset/4698a65d-1a3b-42d1-981e-df869e04185b/export-of-animals-and-animal-products-to-the-uk) and [non-EU countries](https://www.data.gov.uk/dataset/b92627b0-dd7b-4e1d-ba36-e25424f55eeb/non-eu-countries-approved-to-export-animals-and-animal-products-to-great-britain) or zones that are both:

          * approved to export fresh meat of the relevant species
          * recognised by the [World Organisation for Animal Health (WOAH)](https://www.woah.org/en/disease/foot-and-mouth-disease/#ui-id-2) as free of FMD

          For countries or zones that are not recognised as free of FMD and/or not approved to export fresh meat of the relevant species, the casings must:

          * come from holdings that are not under restrictions due to notifiable diseases in Annex 4 of the following special measure
          * have been subjected to a risk mitigating treatment as set out in the relevant [model export health certificate](https://www.gov.uk/government/publications/other-meat-health-certificates)

          These declarations of special measures are necessary to prevent the incursion of FMD, CSF and ASF into the United Kingdom. Susceptible species mean bovine, ovine, caprine and porcine animals. Safeguard declarations give effect to this decision. These are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Cabinet Secretary for Rural Affairs and Islands (Scotland) and Deputy First Minister and Cabinet Secretary for Climate Change and Rural Affairs (Wales).

          * [AttachmentLink: England_Safeguard_Declaration_Casings_and_GBHC370.pdf]
          * [AttachmentLink: FMD_Declaration_-_Animal_Casings_-_England__27_March_2025_.pdf]
          * [AttachmentLink: Wales_Safeguard_Declaration_Casings_and_GBHC370.pdf]
          * [AttachmentLink: FMD_Declaration_-_Casings_-_Wales__27_March_2025_.pdf]
          * [AttachmentLink: FMD_Declaration_-_Casings_-_Scotland__27_March_2025_.pdf]

          For England and Wales, these special measures apply from 17 January 2025. They continue to apply as amended from 28 March 2025 until they are revoked.

          For Scotland, this measure applies from 28 March 2025 until it is revoked or amended. This measure replaces the measure published on 25 March 2025.

          ### Non-harmonised animal by-products

          Importers of non-harmonised animal by-products or display items originating from Austria, Hungary, Slovakia or the containment zone in Germany, which were obtained from FMD-susceptible animals, must apply to the Centre for International Trade, Carlisle, using the [IV58 application form](https://www.gov.uk/government/publications/animal-products-and-pathogens-application-for-import-licence). Approval to import will be subject to a satisfactory assessment of the application. These products must not be imported without an accompanying specific import authorisation.

          ### Personal imports

          Following the recent outbreaks of FMD in Europe, individuals cannot bring certain products of ruminant and porcine origin from the EU, EFTA states, the Faroe Islands and Greenland into Great Britain (England, Scotland and Wales) for personal consumption.

          This applies to the fresh meat, meat products, milk, dairy products, colostrum, colostrum products and certain composite products and animal by-products of ruminant and porcine origin.\u00A0\u00A0

          Exemptions from these rules include:

          - infant milk
          - medical foods
          - certain low-risk composite products (including chocolate, confectionery, bread, cakes, biscuits, pasta and food supplements containing less than 20% animal products) \u00A0

          The following safeguard measures give effect to this decision. These are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England) and the Deputy First Minister and Cabinet Secretary for Climate Change and Rural Affairs (Wales).#{' '}

          Read:

          * [AttachmentLink: FMD_EU_Personal_Import_Safeguard__England__-_April_2025.pdf]
          * [AttachmentLink: FMD_EU_Personal_Imports_Safeguard__Wales__-_April_2025.pdf]

          These special measures apply from 12 April 2025 until they are revoked or amended. The declaration covering Scotland will be published in due course. The following measures still apply for personal imports to Scotland:#{' '}

          * [AttachmentLink: FMD_Declaration_-_Personal_Imports_-_Scotland__27_March_2025_.pdf]

          ##Highly pathogenic avian influenza (HPAI) import restrictions: Bosnia and Herzegovina\u202F\u00A0

          Great Britain (England, Scotland and Wales) has applied the following restrictions for consignments produced on or after 10 February 2025:\u00A0

          - imports of fresh poultry meat are suspended\u202F\u202F\u00A0
          - meat products of poultry must be subject to heat treatment ‘D' (including being treated to 70°C throughout) or higher\u00A0

          On 10 February 2025, an outbreak of HPAI was confirmed in a commercial poultry flock in Kozarde, Republika Srpska, Bosnia and Herzegovina. The restrictions will remain in place until Bosnia and Herzegovina is recognised by the UK as disease free for HPAI.\u00A0

          Read the ‘poultry and poultry products’ and ‘meat products’ list of [non-EU countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/b92627b0-dd7b-4e1d-ba36-e25424f55eeb/non-eu-countries-approved-to-export-animals-and-animal-products-to-great-britain) for more information.

          ##Peste des petits ruminants import restrictions: Hungary

          Great Britain (England, Scotland and Wales) has suspended the import of the following sheep and goat commodities from Hungary:

          - live animals
          - germplasm
          - raw milk and raw milk products
          - untreated wool and hair
          - fresh or chilled (untreated) skins and hides

          This is due to an outbreak of peste des petits ruminants (PPR) that was confirmed on 24 January 2025.

          For more information, read the lists of [EU and EFTA countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/4698a65d-1a3b-42d1-981e-df869e04185b/eu-and-efta-countries-approved-to-export-animals-and-animal-products-to-great-britain) for:

          - live ungulates
          - ovine and caprine ova and embryos
          - ovine and caprine semen
          - milk and milk products

          These measures came into force on 29 January 2025.

          For restrictions on untreated wool and hair and on fresh or chilled (untreated) skins and hides, the following safeguard declarations give effect to this decision. They are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Deputy First Minister and Cabinet Secretary for Climate Change and Rural Affairs (Wales) and the Cabinet Secretary for Rural Affairs and Islands (Scotland).

          Read the:

          * [AttachmentLink: Hungary_-_PRR_-_Safeguard.pdf]
          * [AttachmentLink: Declaration_of_special_measures_-_Hungary-_Peste_des_petits_ruminants_-_UKO_Return.pdf]
          * [AttachmentLink: Hungary_-_PPR_-_Safeguard__Wales__-_January_2025.pdf]

          These safeguard declarations apply from 31 January 2025 and will continue to apply until they are revoked or amended.



          ##Peste des petits ruminants import restrictions: Bulgaria

          Great Britain (England, Scotland and Wales) has suspended the import of the following sheep and goat commodities from Bulgaria following an outbreak of peste des petits ruminants (PPR) that was confirmed on 25 November 2024:

          - raw milk and raw milk products (including raw colostrum)
          - untreated wool and hair
          - fresh or chilled (untreated) skins and hides

          Imports of live sheep and goats, their germplasm and fresh or chilled (untreated) skins and hides are already suspended from Bulgaria as a result of the [sheep pox and goat pox outbreak](https://www.gov.uk/guidance/imports-and-exports-of-animals-and-animal-products-topical-issues#sheep-pox-and-goat-pox-outbreak-in-bulgaria) confirmed on 4 September 2024. These commodities are also now restricted due to PPR.

          For more information, read the lists of [EU and EFTA countries approved to export animals and animal products](https://www.data.gov.uk/dataset/4698a65d-1a3b-42d1-981e-df869e04185b/eu-and-efta-countries-approved-to-export-animals-and-animal-products-to-great-britain) to Great Britain for:

          - live ungulates
          - ovine and caprine ova and embryos
          - ovine and caprine semen
          - milk and milk products

          Untreated wool and hair of sheep and goats and fresh or chilled (untreated) skins and hides of sheep and goats are restricted by the following safeguard declarations, which are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Deputy First Minister and Cabinet Secretary for Climate Change and Rural Affairs (Wales) and the Cabinet Secretary for Rural Affairs and Islands (Scotland).\u00A0

          Read the:

          - [AttachmentLink: PRR_Bulgaria_declaration__England_.pdf]
          - [AttachmentLink: PPR_Bulgaria_declaration__Wales_.pdf]
          - [AttachmentLink: PPR_Bulgaria_declaration__Scotland_.pdf]

          These special measures apply from 18 December 2024 and will continue to apply until they are revoked or amended.

          ## Lumpy skin disease in Japan

          Great Britain (England, Scotland and Wales) has suspended the import of the following bovine products from Japan:

          * raw milk and raw dairy products, including raw colostrum
          * hides and skins, unless they have been treated in line with point 2 b, c, or d of article 11.9.13 of the [WOAH terrestrial code](https://www.woah.org/en/what-we-do/standards/codes-and-manuals/terrestrial-code-online-access/)
          * all animal by-products (except casings, gelatine, collagen, tallow, hooves and horns), unless the products were processed using heat treatment to a minimum internal temperature of 65°C for at least 30 minutes

          This is due to an outbreak of lumpy skin disease in Japan that was confirmed on 6 November 2024.

          For restrictions on raw milk and raw dairy products, read the ‘milk and milk products’ list of [non-EU countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/b92627b0-dd7b-4e1d-ba36-e25424f55eeb/non-eu-countries-approved-to-export-animals-and-animal-products-to-great-britain).

          For restrictions on hides and skins and affected animal by-products of bovine origin, the safeguard declarations below give effect to this decision. These are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Cabinet Secretary for Rural Affairs and Islands (Scotland) and Deputy First Minister and Cabinet Secretary for Climate Change and Rural Affairs (Wales).

          * [AttachmentLink: Japan_-_Lumpy_Skin_Disease_-_Safeguard_v5_JMA_SIGNED_England.pdf]#{' '}
          * [AttachmentLink: Japan_-_Lumpy_Skin_Disease_-_Safeguard__Scotland_.pdf]
          * [AttachmentLink: Japan_-_Lumpy_Skin_Disease_-_Safeguard__Wales_.pdf]

          These special measures apply from 4 December 2024 until they are revoked or amended.

          ## African swine fever (ASF) in the EU and EFTA states

          Individuals can only bring pork and pork products from the EU, EFTA states (Iceland, Liechtenstein, Norway and Switzerland), Faroe Islands and Greenland into Great Britain (England, Scotland and Wales) for personal consumption where the products:\u00A0

          - have been produced and packaged to commercial standards
          - bear an identification or health mark – or commercial labelling if they are animal by-products
          - weigh less than 2kg per person

          This is because some pork and pork products that originate from or have been dispatched from these countries pose an unacceptable risk to animal health in Great Britain. This is due to the spread of African swine fever in Europe.

          The following safeguard measures give effect to this decision. These are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Deputy First Minister and Cabinet Secretary for Climate Change and Rural Affairs (Wales) and the Cabinet Secretary for Rural Affairs and Islands (Scotland).

          - [AttachmentLink: Personal_imports_of_porcine_products_from_certain_third_countries_Declaration_of_special_measures__England_.pdf]
          - [AttachmentLink: Personal_imports_of_porcine_products_from_certain_third_countries_Declaration_of_special_measures__Wales_.pdf]\u00A0
          - [AttachmentLink: Personal_imports_of_porcine_products_from_certain_third_countries_Declaration_of_special_measures__Scotland_.pdf]

          These special measures apply from 27 September 2024 until they are revoked or amended.

          ### Special measures from 1 September 2022

          The measures applying from 27 September 2024 replace the special measures from 1 September 2022. These prohibit the personal import of pork and pork products over 2kg from entering Great Britain unless they have been produced to EU commercial standards.

          The following safeguard measures apply from 1 September 2022. These are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), Minister for Rural Affairs and North Wales, and Trefnydd (Wales), and the Cabinet Secretary for Rural Affairs and Islands (Scotland).#{'  '}

          Read the:#{' '}

          * [The African Swine Fever Import Controls (England and Scotland)](https://www.legislation.gov.uk/uksi/2022/926/introduction/made)
          * [AttachmentLink: Declaration_of_special_measures_-_Importation_of_Porcine_products_from_third_countries__Wales_.pdf]

          ### Preventing the spread of ASF

          Defra’s [African swine fever guide](https://www.gov.uk/guidance/african-swine-fever) covers how to spot ASF, what to do if you suspect it and measures to prevent its spread.

          For more information see:#{' '}

          * [ASF virus in Europe outbreak assessments](https://www.gov.uk/government/publications/african-swine-fever-in-pigs-and-boars-in-europe)
          * the [map of restriction zones in place across Europe](https://santegis.maps.arcgis.com/apps/webappviewer/index.html?id=45cdd657542a437c84bfc9cf1846ae8c)#{' '}
          * [Bringing food into Great Britain: Meat, dairy, fish and animal products](https://www.gov.uk/bringing-food-into-great-britain/meat-dairy-fish-animal-products)

          ## Sheep pox and goat pox outbreak in Bulgaria
          {:#sheep-pox-and-goat-pox-outbreak-in-bulgaria}

          Great Britain (England, Scotland and Wales) has temporarily suspended the imports of the following ovine and caprine commodities from Bulgaria:

          - live animals
          - germplasm
          - fresh or chilled skins and hides

          This follows an outbreak of sheep pox and goat pox that was confirmed on 4 September 2024. Bulgaria has now lost its status as free from sheep pox and goat pox as a result of this outbreak.

          Read the ‘live ungulates’, ‘ovine and caprine ova and embryos’ and ‘ovine and caprine semen’ lists of [EU and EFTA countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/4698a65d-1a3b-42d1-981e-df869e04185b/eu-and-efta-countries-approved-to-export-animals-and-animal-products-to-great-britain).

          For restrictions on fresh or chilled skins and hides, the safeguard declarations below give effect to this decision. These are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Cabinet Secretary for Rural Affairs and Islands (Scotland) and Deputy First Minister and Cabinet Secretary for Climate Change and Rural Affairs (Wales).


          * [AttachmentLink: Declaration_of_Special_Measures_sheep_pox_and_goat_pox_in_Bulgaria__England_.pdf]#{'  '}
          * [AttachmentLink: Declaration_of_special_measures_sheep_pox_and_goat_pox_in_Bulgaria__Scotland_.pdf]
          * [AttachmentLink: Declaration_of_Special_Measures_sheep_pox_and_goat_pox_in_Bulgaria__Wales_.pdf]#{'  '}

          These special measures apply from 12 September 2024 until they are revoked or amended.#{' '}

          ## Peste des petits ruminants import restrictions: European Union

          Individuals can only bring certain sheep and goat products from the EU, EFTA states, the Faroe Islands and Greenland into Great Britain (England, Scotland and Wales) for personal consumption. The products must: \u00A0

          - have been produced and packaged to commercial standards#{'  '}
          - bear an identification or health mark – or commercial labelling if they are animal by-products (ABP)#{'  '}

          This applies to sheep and goat:

          - milk and milk products#{'  '}
          - meat and meat products#{'  '}

          Individuals cannot bring any sheep or goat milk and milk products from Bulgaria, Greece, Hungary or Romania into Great Britain for personal consumption.

          These products pose a risk to animal health in Great Britain due to the spread of peste des petits ruminants in Europe.

          The following safeguard measures give effect to this decision. These are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Deputy First Minister and Cabinet Secretary for Climate Change and Rural Affairs (Wales) and the Cabinet Secretary for Rural Affairs and Islands (Scotland).

          Read the:#{' '}

          * [AttachmentLink: Peste_des_petits_ruminants_in_European_Union_declaration_of_special_measures__England_.pdf]
          * [AttachmentLink: PPR_EU_wide_-_amendment__England_.pdf]
          * [AttachmentLink: EU_Wide_-_PPR_-_Amendment_-_Hungary.pdf]
          * [AttachmentLink: Peste_des_petits_ruminants_in_European_Union_declaration_of_special_measures__Wales_.pdf]
          * [AttachmentLink: PPR_EU_wide_-_amendment__Wales_.pdf]
          * [AttachmentLink: EU_Wide_-_PPR_-_Amendment__Wales__-_Hungary_-_January_2025.pdf]
          * [AttachmentLink: Special_Measures_-_PPR_EEA_States_-_UKO_Return.pdf]

          These special measures apply until they are revoked or amended.

          ## Peste des petits ruminants import restrictions: Romania#{' '}

          Great Britain (England, Scotland and Wales) has temporarily suspended the import of the following sheep and goat commodities from Romania:

          - live animals
          - germplasm
          - raw milk and milk products
          - untreated wool and hair
          - fresh or chilled (untreated) skins and hides\u00A0

          This is due to an outbreak of peste des petits ruminants that was confirmed on 19 July 2024.

          For more information, read the following lists of [EU and EFTA countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/4698a65d-1a3b-42d1-981e-df869e04185b/eu-and-efta-countries-approved-to-export-animals-and-animal-products-to-great-britain):

          - live ungulates
          - ovine and caprine ova and embryos
          - ovine and caprine semen
          - milk and milk products

          For restrictions on untreated wool and hair and on fresh or chilled (untreated) skins and hides, the following safeguard declarations give effect to this decision. They are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Deputy First Minister and Cabinet Secretary for Climate Change and Rural Affairs (Wales) and the Cabinet Secretary for Rural Affairs and Islands (Scotland).\u00A0

          Read the:

          - [AttachmentLink: PPR-in-Romania-declaration-of-special-measures-England.pdf]
          - [AttachmentLink: PPR-in-Romania-declaration-of-special-measures-Scotland.pdf]
          - [AttachmentLink: PPR-in-Romania-declaration-of-special-measures-Wales.pdf]

          These special measures apply from 26 July 2024 and will continue to apply until they are revoked or amended.

          ## Peste des petits ruminants import restrictions: Greece

          Great Britain (England, Scotland and Wales) has suspended the import of the following sheep and goat commodities from Greece following an outbreak of peste des petits ruminants that was confirmed on 11 July 2024:

          - raw milk and raw milk products (including raw colostrum)
          - untreated wool and hair
          - fresh or chilled (untreated) skins and hides

          Imports of live sheep and goats and their germplasm are already suspended from Greece as a result of the [sheep pox and goat pox outbreak](https://www.gov.uk/guidance/imports-and-exports-of-animals-and-animal-products-topical-issues#sheep-pox-and-goat-pox-in-greece) confirmed on 24 October 2023. These commodities are also now restricted due to PPR.

          For more information, read the lists of [EU and EFTA countries approved to export animals and animal products](https://www.data.gov.uk/dataset/4698a65d-1a3b-42d1-981e-df869e04185b/eu-and-efta-countries-approved-to-export-animals-and-animal-products-to-great-britain) to Great Britain for:

          - live ungulates
          - ovine and caprine ova and embryos
          - ovine and caprine semen
          - milk and milk products

          Untreated wool and hair of sheep and goats and fresh or chilled (untreated) skins and hides of sheep and goats are restricted by the following safeguard declarations, which are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Deputy First Minister and Cabinet Secretary for Climate Change and Rural Affairs (Wales) and the Cabinet Secretary for Rural Affairs and Islands (Scotland).

          Read the:

          - [AttachmentLink: PPR_Greece_-_Safeguard_v1.0__England_.pdf]
          - [AttachmentLink: PPR_Greece_-_safeguard__Scotland_.pdf]
          - [AttachmentLink: PPR_Greece__-_Safeguard__Wales_.pdf]

          ## Highly Pathogenic Avian Influenza (HPAI) import restrictions: Australia\u202F\u00A0\u00A0

          The import of the following ratite products is suspended from Australia to Great Britain (England, Scotland and Wales) for consignments produced on or after 22 May 2024:\u00A0

          - fresh ratite meat\u00A0\u00A0
          - breeding and productive ratites
          - day-old ratites\u00A0
          - hatching eggs of ratites\u00A0

          An outbreak of HPAI was confirmed in a commercial layer poultry farm in Victoria, Australia, on 22 May 2024. The suspension of affected commodities will remain in place until the UK recognises Australia as disease free for HPAI.

          Read the ‘Poultry and poultry products’ list of [non-EU countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/b92627b0-dd7b-4e1d-ba36-e25424f55eeb/non-eu-countries-approved-to-export-animals-and-animal-products-to-great-britain) for more information about affected commodities.

          ## African swine fever (ASF) import restrictions: Montenegro

          From 23 January 2024, the heat treatment applied to the import of domestic and wild pig meat products from Montenegro into Great Britain (England, Scotland and Wales) has changed.#{' '}

          The heat treatment category for domestic porcine, farmed cloven-hoofed game (swine) and wild swine has changed from ‘D’ (minimum temperature of 70ºC) to ‘C’ (minimum temperature 80ºC).

          An outbreak of African swine fever (ASF) was confirmed in wild boar in Montenegro on 14 January 2024. These measures will remain in place until Montenegro is recognised by the UK as disease free for ASF.

          Read the ‘meat products’ list of [non-EU countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/b92627b0-dd7b-4e1d-ba36-e25424f55eeb/non-eu-countries-approved-to-export-animals-and-animal-products-to-great-britain) for more information about affected commodities.

          ## Bluetongue virus (BTV) in the EU and EFTA states

          The [bluetongue guidance](https://www.gov.uk/government/collections/bluetongue-information-and-guidance-for-livestock-keepers) covers the latest situation and advice on measures to protect against the disease.#{' '}

          There are mandatory requirements for imports from all EU and European Free Trade Association (EFTA) countries to Great Britain of:\u00A0

          * BTV susceptible animals – that is, ruminants such as cattle, sheep, goats and cervids (deer), and camelids such as alpacas and llamas
          * germinal products (semen, ova and embryos) of susceptible animals

          ### Importing animals

          When importing susceptible animals from countries with BTV to Great Britain:

          * the country you import from must be listed for the relevant species on the ‘live ungulates’ list of [EU and EFTA countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/4698a65d-1a3b-42d1-981e-df869e04185b/eu-and-efta-countries-approved-to-export-animals-and-animal-products-to-great-britain)#{' '}
          * you must comply with the vaccination requirements outlined in supplementary guarantee ‘A’ of the relevant [health certificates](https://www.gov.uk/government/collections/health-certificates-for-animal-and-animal-product-imports-to-great-britain)
          * you must not move susceptible animals from countries with the BTV-3 serotype of bluetongue to Great Britain – this is because there is no fully approved vaccine for BTV-3 with a guaranteed period of immunity, so it’s not possible to comply with the health certificate requirements

          In addition:

          * you should only source animals that have a reliable health status
          * you should test animals to ensure they are clear of infection before they travel to Great Britain
          * you should speak to your private veterinarian about putting in place controls to help prevent the introduction of BTV

          ### Movement restrictions and testing after import\u00A0

          If you import susceptible animals from an affected country or a country within 150km of an affected country, APHA will contact you after import to arrange for the animals to be tested to confirm they are free of BTV. APHA will also place the animals under movement restrictions until it has confirmed they are disease free. You must not move the animals from the destination premises until you receive this confirmation. The process can take up to 2 weeks.\u00A0

          Imported animals that test positive for BTV may be culled or returned to the country of origin. Any animals that travelled in the same vehicle that are at risk of becoming infected may also be culled or returned. No compensation will be paid for the culled or returned animals.\u00A0\u00A0

          If the animals you’ve imported test positive for BTV, you’ll be restricted from moving any susceptible animals on or off the destination premises until APHA has confirmed that the disease has not spread.

          ### Importing germinal products

          When importing the germinal products of susceptible animals from countries with BTV to Great Britain:

          * you must make sure the country you import from is on the ‘bovine semen’, ‘bovine embryos’, ‘ovine and caprine semen’ and ‘ovine and caprine ova and embryos’ lists of [EU and EFTA countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/4698a65d-1a3b-42d1-981e-df869e04185b/eu-and-efta-countries-approved-to-export-animals-and-animal-products-to-great-britain)
          * you must comply with the testing requirements outlined in the relevant [health certificates](https://www.gov.uk/government/collections/health-certificates-for-animal-and-animal-product-imports-to-great-britain)

          ### More information

          For more information on import requirements:

          * read APHA’s [imports of live animals and genetic material importer information notes](http://apha.defra.gov.uk/official-vets/Guidance/bip/iin/live-animals-gene-mat.htm)
          * [contact the Animal and Plant Health Agency (APHA)](https://www.gov.uk/guidance/contact-apha)

          ##Lifting of reinforced controls for beef, poultry meat and meat products from Brazil#{'  '}

          The UK has lifted reinforced controls for consignments of beef, poultry meat and meat products and preparations exported from Brazil to Great Britain (England, Scotland and Wales). This follows an audit of Brazil’s sanitary and phytosanitary controls.

          For consignments of beef, poultry meat, and products and preparations from Brazil, exports to Great Britain do not need:#{'  '}
          #{' '}
          - enhanced pre-export and post-import testing for salmonella
          - the additional attestation attached to health certificates confirming salmonella sampling, methods of analysis used, and results

          The default level of import checks now applies in accordance with [retained Commission Implementing Regulation 2019/2129.](https://www.legislation.gov.uk/eur/2019/2129)#{'  '}

          Brazil can re-list certain poultry and beef establishments for export to Great Britain, as set out in the list of [establishments approved to export animals and animal products](https://www.gov.uk/guidance/exporting-to-the-uk-countries-and-establishments-approved-to-export-animals-and-animal-products).

          Find out the [countries, territories and regions approved to export animals and animal products to Great Britain](https://www.gov.uk/guidance/exporting-to-great-britain-approved-countries-for-animals-and-animal-products).

          ## Chronic wasting disease (CWD) outside the UK#{' '}

          From 23 June 2023, Great Britain (England, Scotland and Wales) and the Crown Dependencies (Channel Islands and the Isle of Man) have suspended the import of live cervids and high risk cervid products, including urine hunting lures, from countries where CWD has been reported.#{' '}

          In addition, fresh cervid meat cannot be imported into Great Britain from countries affected with CWD unless it complies with the supplementary guarantee in the relevant [health certificate](https://www.gov.uk/government/collections/health-certificates-for-animal-and-animal-product-imports-to-great-britain).#{' '}

          CWD has been reported in Norway, Finland, Sweden, Canada, USA and the Republic of Korea.

          The following safeguard measures give effect to these decisions. They are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Minister for Rural Affairs and North Wales, and Trefnydd (Wales), and the Cabinet Secretary for Rural Affairs and Islands (Scotland).#{'  '}

          Read the:

          * [AttachmentLink: Declaration_of_special_measures_chronic_wasting_disease__England_.pdf]
          * [AttachmentLink: Chronic_Wasting_Disease_Declaration_of_Special_Measures__Scotland_.pdf]
          * [AttachmentLink: Chronic_Wasting_Disease_-_Declaration_of_Special_Measures__Wales_.pdf]

          These special measures apply from 23 June 2023 until they are revoked or amended.

          For more information about the risk of CWD being introduced into Great Britain, read the [qualitative risk assessments](https://www.gov.uk/government/publications/chronic-wasting-disease-risk-assessments).#{' '}

          Find out the [countries, territories and regions approved to export animals and animal products to Great Britain](https://www.gov.uk/guidance/exporting-to-great-britain-approved-countries-for-animals-and-animal-products).

          ##Epizootic haemorrhagic disease (EHD) in Europe#{' '}

          Epizootic haemorrhagic disease (EHD) was recently reported for the first time in Europe and is now spreading. Outbreaks of EHD have been confirmed in:\u00A0

          - Italy on 8 November 2022\u00A0
          - Spain on 18 November 2022\u00A0
          - Portugal on 19 July 2023\u00A0
          - France on 19 September 2023

          ### Importing animals and germinal products#{' '}

          These outbreaks affect animal health certification for imports into Great Britain of:\u00A0

          - live cattle, sheep, goats, deer and other ruminants\u00A0
          - germinal products (semen, ova and embryos) of cattle, sheep, goats, deer and other ruminants\u00A0

          Imports of these animals or products from EHD-affected countries must meet the requirements of the relevant [health certificate](https://www.gov.uk/government/collections/health-certificates-for-animal-and-animal-product-imports-to-great-britain).\u00A0

          Read [how to prevent, spot and report epizootic haemorrhagic disease](https://www.gov.uk/guidance/epizootic-haemorrhagic-disease) for information on the latest situation, outbreak assessments, and advice on measures to protect against the disease.

          ### Movement restrictions and testing after import\u00A0

          If you import susceptible animals from an affected country or a country within 150km of an affected country, APHA will contact you after import to arrange for the animals to be tested to confirm they are free of EHD. APHA will also place the animals under movement restrictions until it has confirmed they are disease free. You must not move the animals from the destination premises until you receive this confirmation. The process can take up to 2 weeks.\u00A0

          Imported animals that test positive for EHD may be culled or returned to the country of origin. Any animals that travelled in the same vehicle that are at risk of becoming infected may also be culled or returned. No compensation will be paid for the culled or returned animals.\u00A0\u00A0

          If the animals you’ve imported test positive for EHD, you’ll be restricted from moving any susceptible animals on or off the destination premises until APHA has confirmed that the disease has not spread.


          ## Small hive beetle in Réunion, an overseas territory of France#{'  '}

          Great Britain (England, Scotland and Wales) has suspended the import of bees, apiculture products and used beekeeping equipment from Réunion, an overseas territory of France. This is due to an outbreak of small hive beetle. These measures are necessary to protect bee health in the UK.#{'   '}

          These special measures apply from 26 May 2023 until they are revoked or amended.#{' '}

          The following safeguard measures give effect to this decision. These are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Minister for Rural Affairs and North Wales, and Trefnydd (Wales), and the Cabinet Secretary for Rural Affairs and Islands (Scotland).#{'  '}

          Read the:

          * [AttachmentLink: Small_hive_beetle_in_Réunion_declaration_of_special_measures__England_.pdf]#{' '}
          * [AttachmentLink: Small_hive_beetle_in_Réunion_declaration_of_special_measures__Scotland_.pdf]
          * [AttachmentLink: Small_hive_beetle_in_Réunion_declaration_of_special_measures__Wales_.pdf]

          ## Small hive beetle in the region of Calabria, Italy#{'  '}

          The UK has suspended the import of bees, apiculture products and used beekeeping equipment into Great Britain (England, Scotland and Wales) from the region of Calabria in Italy. This is due to an ongoing outbreak of small hive beetle. These measures are necessary to protect bee health in the UK.#{'   '}

          The following safeguard measures give effect to this decision. These are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Minister for Rural Affairs and North Wales, and Trefnydd (Wales), and the Cabinet Secretary for Rural Affairs and Islands (Scotland).#{' '}

          Read the:#{' '}

          * [AttachmentLink: Small_hive_beetle_in_Calabria__Italy_-_declaration_of_special_measures__England_.pdf]
          * [AttachmentLink: Small_hive_beetle_in_Calabria__Italy_-_declaration_of_special_measures__Scotland_.pdf]
          * [AttachmentLink: Small_hive_beetle_in_Calabria__Italy_-_declaration_of_special_measures__Wales_.pdf]

          These special measures apply from 17 January 2023 and will continue to apply until they are revoked or amended.

          ## Small hive beetle in the region of Sicily, Italy

          The UK has suspended the import of bees, apiculture products and used beekeeping equipment into Great Britain (England, Scotland and Wales) from the region of Sicily in Italy. This is due to an outbreak of small hive beetle. These measures are necessary to protect bee health in Great Britain and are in addition to restrictions already in place for imports of these products from the region of Calabria in Italy.

          The following safeguard measures give effect to this decision. These are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Deputy First Minister and Cabinet Secretary for Climate Change and Rural Affairs (Wales), and the Cabinet Secretary for Rural Affairs and Islands (Scotland).

          Read the:

          - [AttachmentLink: Small_hive_beetle_in_Sicily_Italy__declaration_of_special_measures__England.pdf]
          - [AttachmentLink: Small_hive_beetle_in_Sicily_Italy__declaration_of_special_measures__Scotland.pdf]
          - [AttachmentLink: Small_hive_beetle_in_Sicily_Italy__declaration_of_special_measures__Wales.pdf]


          These special measures apply from 1 November 2024 and will continue to apply until they are revoked or amended.

          ## Sheep pox and goat pox in Greece

          Imports of the following ovine and caprine commodities from Greece have been temporarily suspended following an outbreak of sheep pox and goat pox that was confirmed on 24 October 2023:\u00A0

          - live animals
          - germplasm
          - fresh or chilled skins and hides

          Read the ‘live ungulates’, ‘ovine and caprine ova and embryos’, and ‘ovine and caprine semen’ lists of [EU and EFTA countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/4698a65d-1a3b-42d1-981e-df869e04185b/eu-and-efta-countries-approved-to-export-animals-and-animal-products-to-great-britain).

          For restrictions on fresh or chilled skins and hides, the safeguard declarations below give effect to this decision. These are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), Minister for Rural Affairs and North Wales, and Trefnydd (Wales), and the Cabinet Secretary for Rural Affairs and Islands (Scotland).\u00A0

          Read the:

          * [AttachmentLink: Declaration_of_special_measures_for_sheep_pox_and_goat_pox_in_Greece__England_.pdf]#{'  '}
          * [AttachmentLink: Declaration_of_special_measures_for_sheep_pox_and_goat_pox_in_Greece__Scotland_.pdf]#{'  '}
          * [AttachmentLink: Declaration_of_special_measures_for_sheep_pox_and_goat_pox_in_Greece__Wales_.pdf]#{'  '}

          These special measures apply from 10 November 2023 and will continue to apply until they are revoked or amended.

          ## Sheep pox and goat pox disease free status: Spain#{' '}

          Great Britain has recognised whole country freedom from sheep pox and goat pox in Spain. The restrictions on the import of ovine and caprine live animals and germplasm from Spain have now been lifted.

          Bulgaria was recognised as free from sheep pox and goat pox at the same time was Spain, but it has now lost this status following an outbreak that was confirmed on 4 September 2024. [New restrictions now apply to imports from Bulgaria](#sheep-pox-and-goat-pox-outbreak-in-bulgaria).#{' '}

          Read the ‘live ungulates’, ‘ovine and caprine ova and embryos’ and ‘ovine and caprine semen’ lists of [EU and EFTA countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/4698a65d-1a3b-42d1-981e-df869e04185b/eu-and-efta-countries-approved-to-export-animals-and-animal-products-to-great-britain) for more information.

          For fresh or chilled skins and hides, the safeguard declarations published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Deputy First Minister and Cabinet Secretary for Climate Change and Rural Affairs (Wales), and the Cabinet Secretary for Rural Affairs and Islands (Scotland) are revoked with effect from 17 April 2024.#{' '}

          Read the:

          - [AttachmentLink: Declaration_revoking_special_measures_for_sheep_pox_and_goat_pox_in_Spain_and_Bulgaria_Wales.pdf]
          - [AttachmentLink: Declaration_revoking_special_measures_for_sheep_pox_and_goat_pox_in_Spain_and_Bulgaria_England.pdf]
          - [AttachmentLink: Declaration_revoking_special_measures_for_sheep_pox_and_goat_pox_in_Spain_and_Bulgaria_Scotland.pdf]

          ## Foot and mouth disease (FMD) in Botswana#{' '}

          You can export fresh meat and by-products of ungulates from FMD-free areas of Botswana to Great Britain (England, Scotland and Wales). You cannot export from restricted areas in Botswana.#{'  '}

          Great Britain has assessed the disease control and regionalisation measures the Botswanan authorities have put in place to contain the FMD outbreak. As a result, Great Britain has resumed exports from FMD-free areas.

          Find out the [countries, territories and regions approved to export animals and animal products to Great Britain](https://www.gov.uk/guidance/exporting-to-great-britain-approved-countries-for-animals-and-animal-products).

          ## Commercial import of dogs, cats and ferrets to Great Britain (England, Scotland and Wales) from Belarus, Poland, Romania or Ukraine\u00A0

          If you commercially import dogs, cats and ferrets into Great Britain that originate from or have been dispatched from Belarus, Poland, Romania or Ukraine, you must have Approved Importer status.

          Commercial imports are the sale of or the transfer of ownership of a pet animal. This includes rescue animals and if you are travelling with more than 5 dogs, cats or ferrets if these animals are not attending training for a competition, show or sporting event.

          This special measure does not apply to non-commercial pet animals from these countries.

          Find out how to [apply for Approved Importer status](https://www.gov.uk/government/publications/apply-for-approved-importer-status).

          This special measure replaces the temporary suspension of commercial imports of dogs, cats and ferrets from Belarus, Poland, Romania or Ukraine. It will apply until it is revoked or amended.

          These countries present a high risk of rabies transmission.

          Read the:

          * [AttachmentLink: Declaration_of_special_measures_for_the_commercial_import_of_animals_from_Ukraine__Belarus__Poland_and_Romania_from_29_October__England_.pdf]
          * [AttachmentLink: Declaration_of_special_measures_for_the_commercial_import_of_animals_from_Ukraine__Belarus__Poland_and_Romania_from_29_October__England__-_amendment_11_November.pdf]
          * [AttachmentLink: Declaration_of_special_measures_for_the_commercial_import_of_animals_from_Ukraine__Belarus__Poland_and_Romania_from_29_October__Scotland_.pdf]
          * [AttachmentLink: Amendment_to_declaration_of_special_measures_for_the_commercial_import_of_animals_from_Ukraine__Belarus__Poland_and_Romania__Scotland_.pdf]
          * [AttachmentLink: Declaration_of_special_measures_for_the_commercial_import_of_animals_from_Ukraine__Belarus__Poland_and_Romania_from_29_October__Wales_.pdf]
          * [AttachmentLink: Amendment_to_declaration_of_special_measures_for_the_commercial_import_of_animals_from_Ukraine__Belarus__Poland_and_Romania__Wales_.pdf]

          ##Rodents imported from Lithuania

          An ongoing outbreak of Salmonella enteritidis among the UK public has been linked to mice imported from Lithuania for use as animal feed, particularly for reptiles. The risk posed to public health has led to a decision to prohibit imports of feeder rodents (mice and rats for use as animal feed) from Lithuania into the UK, coming into force from 17 February 2022.#{' '}

          The following safeguard measures give effect to this decision. These are published on behalf of the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), the Minister for Rural Affairs and North Wales, and Trefnydd (Wales), the Minister of Agriculture, Environment and Rural Affairs (Northern Ireland) and Food Standards Scotland:

          * [AttachmentLink: lithuania-safeguarding-england.pdf]
          * [AttachmentLink: lithuania-safeguarding-wales-english.pdf], [AttachmentLink: lithuania-safeguarding-wales-welsh.pdf]
          * [AttachmentLink: lithuania-safeguarding-northern-ireland.pdf]
          * [feeder rodents imported from Lithuania: declaration of special measures (Scotland)](https://www.foodstandards.gov.scot/publications-and-research/publications/prohibition-on-feeder-rodents-imported-from-lithuania)

          The special measures shall continue to apply until revoked or amended. The measures will be reviewed over the coming months to take into account any actions taken by the Lithuanian authorities to control the risk from imports of feeder rodents in the long term.

          ##Lifting of highly pathogenic avian influenza (HPAI) measures: Chile#{'  '}

          Following an outbreak of HPAI in Chile in March 2023, Great Britain has assessed the disease control and regionalisation measures implemented by the Chilean authorities to contain the outbreak. As a result, Great Britain has resumed imports from HPAI-free areas of Chile.#{' '}

          You can import the following products into Great Britain (England, Scotland and Wales) from HPAI-free areas of Chile:#{' '}

          - live poultry and ratites#{' '}
          - hatching eggs of poultry and ratites#{' '}
          - fresh poultry, ratite and wild game bird meat#{' '}

          You cannot import these products from restricted areas of Chile.#{'  '}

          Imports must meet the requirements of the relevant [health certificate](https://www.gov.uk/government/collections/health-certificates-for-animal-and-animal-product-imports-to-great-britain).#{' '}

          Read ‘Poultry and poultry products’ on the [Non-EU countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/b92627b0-dd7b-4e1d-ba36-e25424f55eeb/non-eu-countries-approved-to-export-animals-and-animal-products-to-great-britain) page to find the restricted areas of Chile.

          ##Highly pathogenic avian influenza (HPAI) import restrictions: Argentina\u00A0\u00A0

          Great Britain (England, Scotland and Wales) has recognised Argentina’s self-declared HPAI disease-free status.\u00A0\u00A0

          The restrictions on the import of poultry, ratite and wild game bird meat into Great Britain from Argentina have been lifted.\u00A0\u00A0

          The heat treatment required for meat products of poultry and farmed feathered game has been amended from heat treatment ‘D’ to heat treatment ‘A’.\u00A0

          Read the ‘Poultry and poultry products’ and ‘Meat Products’ lists of [Non-EU countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/b92627b0-dd7b-4e1d-ba36-e25424f55eeb/non-eu-countries-approved-to-export-animals-and-animal-products-to-great-britain).

          ##Highly pathogenic avian influenza (HPAI) import restrictions: Japan#{' '}

          From 28 October 2022, the import of fresh poultry meat is suspended from Japan into Great Britain (England, Scotland and Wales). Additionally, the heat treatment category for poultry meat products has changed from ‘A’ (no specific treatment) to ‘D’ (minimum temperature of 70̊ C).

          On 28 October 2022, 2 outbreaks of HPAI were confirmed in commercial poultry establishments in Japan. Restrictions will remain in place until Japan is recognised by the UK as disease free for HPAI.#{' '}

          Read ‘Poultry and poultry products’ and ‘Meat Products’ on the [Non-EU countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/b92627b0-dd7b-4e1d-ba36-e25424f55eeb/non-eu-countries-approved-to-export-animals-and-animal-products-to-great-britain) page for more information about affected commodities.

          ## Avian influenza (bird flu) outside the UK

          This section was updated on 2 March 2023.#{' '}

          Our [research reports](https://www.gov.uk/government/publications/avian-influenza-bird-flu-in-europe) provide preliminary and updated outbreak assessments for avian influenza (bird flu) in Europe, Russia and in the UK.

          You cannot import poultry and poultry products into the UK from disease restricted zones around confirmed cases of avian flu in other countries.

          You must continue to comply with [specific requirements in Commission Regulation (EC) 798/2008](https://eur-lex.europa.eu/legal-content/EN/TXT/HTML/?uri=CELEX:32008R0798&from=EN#d1e1176-1-1) when importing poultry and poultry products.#{' '}

          ### Changes to the minimum surveillance period for imports of poultry and poultry products (including ratites) from bird flu affected countries

          The surveillance period for imports of live poultry (including ratites) and certain poultry and ratite products from highly pathogenic avian influenza control zones has reduced from 90 days to 30 days. This follows an assessment of risk by Defra, Scottish Government and Welsh Government. Import requirements for Great Britain are now in line with the Terrestrial Animal Health code set by the World Organisation of Animal Health (WOAH).

          This is only available for [countries approved to export to Great Britain](https://www.gov.uk/guidance/exporting-to-great-britain-approved-countries-for-animals-and-animal-products) and can demonstrate:

          - adequate cleansing and disinfection has been carried out
          - the required surveillance activity has been completed
          - the zone has been lifted (minimum of 30 days after effective cleansing and disinfection)

          The requirements are set out in the model health certificates for:

          - [poultry (live animals including hatching eggs)](https://www.gov.uk/government/publications/poultry-live-health-certificates)
          - [ratites (live animals including hatching eggs)](https://www.gov.uk/government/publications/ratites-health-certificates)
          - [poultry meat](https://www.gov.uk/government/publications/poultry-meat-health-certificates)
          - [ratite meat](https://www.gov.uk/government/publications/ratite-meat-health-certificates)
          - [meat products and meat preparations](https://www.gov.uk/government/publications/meat-products-health-certificates)

          ###Highly pathogenic avian influenza (HPAI) in Canada and the United States of America

          Defra has received notification of multiple outbreaks of highly pathogenic avian influenza (HPAI) by authorities in Canada and the United States.

          The import of certain animals and products originating in, or dispatched from, the affected regions in both countries pose an unacceptable level of risk to animal health in Great Britain.

          Imports to Great Britain of relevant poultry and poultry products (including hatching eggs and day old chicks) from affected regions of Canada and the United States are no longer authorised.#{' '}

          Read ‘Poultry and poultry products [EUR 2008/ 798]’ on the [Non-EU countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/b92627b0-dd7b-4e1d-ba36-e25424f55eeb/non-eu-countries-approved-to-export-animals-and-animal-products-to-great-britain) page for more information about the affected commodities and regions.

          This document supersedes the safeguard declarations published by the Parliamentary Under Secretary of State at the Department for Environment, Food and Rural Affairs (England), Minister for Rural Affairs and North Wales, and Trefnydd (Wales), and the Cabinet Secretary for Rural Affairs and Islands (Scotland) which have now been revoked:

          * [AttachmentLink: Declaration_revoking_Special_Measures_-_Canada_-_Scotland_signed_25_July_2022.pdf]
          * [AttachmentLink: Declaration_revoking_Special_Measures_-_US_-_Scotland_Signed_-_25_July_2022.pdf]
          * [AttachmentLink: Avian_influenza_-_Canada_and_US_revocation_directions_-_England.pdf]
          * [AttachmentLink: Welsh_Government_-_Avian_influenza_-_Canada_and_US_revocation_directions_25_07_22.pdf]

          Restrictions to trade first came into force on 25 March 2022 and will remain in place until the necessary conditions have been met to resume trade from the affected regions.#{'  '}

          ###Lifting of highly pathogenic avian influenza (HPAI) import restrictions: Ukraine#{' '}

          Since December 2020, imports of poultry products from Ukraine to Great Britain have been suspended due to outbreaks of highly pathogenic avian influenza (HPAI).#{' '}

          The Ukrainian authorities have supplied information to Defra about the epidemiological situation and the measures taken to control the outbreaks.#{' '}

          An assessment of risk led by Defra and the Animal and Plant Health Agency (in consultation with the Food Standards Agency) concluded that allowing imports of poultry products from Ukraine to resume poses an acceptable level of risk to public and animal health in Great Britain. This is provided the consignments originate from outside the areas affected by HPAI.

          Based on that assessment, Defra, Scottish and Welsh governments have agreed to allow trade to resume.#{' '}

          A [Statutory Instrument (The Approved Country Lists (Animals and Animal Products) (Amendment) (No. 2) Regulations 2021)](https://www.legislation.gov.uk/uksi/2021/1454/regulation/2/made) came into force on 17 December 2021 to implement this decision.

          ###Lifting of highly pathogenic avian influenza (HPAI) import restrictions: Australia#{' '}

          Since July 2020, imports of poultry and poultry products from Australia to Great Britain have been suspended due to outbreaks of highly pathogenic avian influenza (HPAI).#{' '}

          The Australian authorities have supplied information to Defra about the epidemiological situation and the measures taken to control the outbreaks.#{' '}

          An assessment of risk led by Defra and the Animal and Plant Health Agency (in consultation with the Food Standards Agency) concluded that allowing imports of poultry and poultry products from Australia to resume poses an acceptable level of risk to public and animal health in Great Britain.

          Based on that assessment, Defra, Scottish and Welsh governments have agreed to allow trade to resume.#{' '}

          A [Statutory Instrument (The Approved Country Lists (Animals and Animal Products) (Amendment) (No. 2) Regulations 2021)](https://www.legislation.gov.uk/uksi/2021/1454/regulation/2/made) came into force on 17 December 2021 to implement this decision.

          ### Highly pathogenic avian influenza (HPAI) in Botswana
          #{' '}
          On 6 September 2021, the World Organisation for Animal Health (OIE) was notified of an outbreak of highly pathogenic avian influenza (HPAI) of subtype H5N1 by authorities in Botswana. The outbreak was confirmed on a poultry farm outside of Gaborone.#{' '}
          #{' '}
          In order to prevent the introduction of HPAI into Great Britain, Botswana is no longer authorised to certify and export poultry of live breeding or productive ratites, day old chicks of ratites, hatching eggs of ratites and meat of farmed ratites to Great Britain for human consumption. Full details on the commodities affected and new restrictions are available in the declarations below.#{' '}

          * [AttachmentLink: bird-flu-botswana-declaration-england.pdf]
          * [AttachmentLink: bird-flu-botswana-declaration-scotland.pdf]
          * [AttachmentLink: bird-flu-botswana-declaration-wales-english.pdf], [AttachmentLink: bird-flu-botswana-declaration-wales-welsh.pdf]
          #{' '}
          These safeguarding measures prohibiting imports of susceptible commodities from Botswana are published on behalf of the Secretary of State for Environment, Food and Rural Affairs (England), Scottish Ministers and the Minister for Rural Affairs and North Wales and the Trefnydd, (one of the Welsh Ministers).#{' '}
          #{' '}
          These restrictions will be put in place until all the necessary criteria of assurances to resume certification of trade to Great Britain are met.

          ## Avian influenza (bird flu) in the UK

          This section was updated on 13 April 2022.

          A [collection of guidance and forms for importing and exporting live animals or animal products](https://www.gov.uk/government/collections/guidance-on-importing-and-exporting-live-animals-or-animal-products) is available.

          ### World Animal Health Organisation (WOAH) disease freedom

          The UK is no longer free from avian influenza under the World Organisation for Animal Health (WOAH) rules. There are some restrictions on exports of affected commodities to third countries. Trade in poultry and poultry related products with third countries that do not require whole UK avian influenza country freedom may continue on the basis of the conditions included in the export health certificates, unless otherwise notified by the importing country.

          Agreed export health certificates between the UK and importing countries are considered and issued on a case-by-case basis and can be certified by an Official Veterinarian only if the consignment meets the requirements set out in the export health certificates in full.

          ### Exports to the EU

          Exports from Great Britain to the EU of live poultry or poultry products are not permitted from disease control zones.

          There are no restrictions on exports to the EU from outside the disease control zones.

          The European Commission is currently considering amending the regionalisation of the UK in Regulation (EU) 2021/404 in relation to these new HPAI outbreaks.

          To avoid disruption to trade, the European Commission has requested that EU countries consider continuing to accept certified poultry and poultry products from the UK, if they originate outside the restricted areas.

          ### Imports from the EU

          You cannot import poultry and poultry products into the UK from within avian influenza disease control zones in EU countries.

          EU trade relies on strict certification for movement of live poultry, day old chicks and hatching eggs. Products such as poultry meat, table eggs and poultry products are not subject to certification within the EU.

          Our [avian influenza (bird flu) page](https://www.gov.uk/government/news/bird-flu-avian-influenza-latest-situation-in-england) covers the latest situation.

          Go to [bird flu cases and disease zones in England](https://www.gov.uk/animal-disease-cases-england) for information about cases and the measures that apply in disease zones.

          ## Bovine spongiform encephalopathy (BSE) risk status of trading partners

          The World Organisation for Animal Health (WOAH, formerly OIE) has established a procedure for categorising the BSE risk status of countries or parts of countries as either ‘undetermined’, ‘controlled’, or ‘negligible’.\u00A0

          When WOAH changes the BSE risk status of a trading partner, Defra carries out an assessment. Based on that assessment Defra, with Scottish Government and Welsh Government, may agree to recognise and adopt the change in BSE risk status.

          Importers and official veterinarians must be aware of the BSE risk status of trading partners when importing certain commodities to Great Britain (England, Scotland and Wales).\u00A0\u00A0

          Find out the:\u00A0

          - [animal health status of countries approved to export animals and animal products to Great Britain](https://www.data.gov.uk/dataset/b7712d2e-debb-4996-8e79-d27ca7492a00/animal-health-status-of-countries-approved-to-export-animals-and-animal-products-to-great-britain)\u00A0
          - [countries approved to export animals and animal products to Great Britain](https://www.gov.uk/guidance/exporting-to-great-britain-approved-countries-for-animals-and-animal-products)


          ## Crabs to Hong Kong: residue testing

          This section was updated on 27 March 2019.

          The import restrictions on live brown crab exported from Anglesey, Wales introduced by the Hong Kong authorities remain in place. Brown crabs from Anglesey, should not be exported to Hong Kong until the situation is resolved.
          #{' '}
          ## Restrictions on trade of agricultural commodities to the Russian Federation

          This section was updated on 27 March 2019.

          The Russian Federation has banned the import of a number of agricultural commodities from the whole of the EU including the UK and also the USA, Canada, Australia and Norway until December 2019.
          The ban was imposed on 7 August 2014.

          ### Banned products

          The ban covers many agricultural products, raw materials, plants and foodstuffs including most meat, dairy and fish.

          If you need to check whether a particular product is affected, please [contact APHA or Northern Ireland’s Department of Agriculture, Environment and Rural Affairs (DAERA)](#contacts).

          ### Withdrawal of Export Health Certificates for the Russian Federation

          In the light of this, APHA and DAERA have withdrawn all Export Health Certificates for the animals and animal products affected, for the duration of this ban. This also applies to consignments of these commodities transiting through the Russian Federation to another destination. But there may be exceptions so you should check.

          Any exporter planning to send any consignment (including live animals) to the Russian Federation should get assurances from importers in the Russian Federation that the consignment will be accepted. If consignments of live animals are blocked at the border of the Russian Federation, re-entry into the UK or any other member state is not permitted under EU law. Exceptions may be considered in specific cases.

          Read further guidance on [exporting to Russia](https://www.gov.uk/government/publications/exporting-to-russia).

          ## Contacts

          [Contact APHA](https://www.gov.uk/guidance/contact-apha) for advice about imports and exports to and from Great Britain.

          Exporters in Northern Ireland should contact:

          * [Department of Agriculture, Environment and Rural Affairs (DAERA)](https://www.daera-ni.gov.uk/contact)
          * Telephone: 0300 200 7840
          * email: <daera.helpline@daera-ni.gov.uk>


          *[HPAI]: highly pathogenic avian influenza
          *[AI]: avian influenza
          *[APHA]: Animal and Plant Health Agency
          *[DAERA]: Department of Agriculture, Environment and Rural Affairs
          *[MLC]: Maximum Level of Contaminants
          *[OIE]: World Organisation for Animal Health
          *[CWD]: Chronic Wasting Disease
          *[BTV]: bluetongue virus
          *[Defra]: Department for Environment, Food and Rural Affairs
          *[ASF]: African swine fever
          *[WOAH]: World Organisation of Animal Health
          *[BSE]: bovine spongiform encephalopathy
          *[EU]: European Union
          *[EFTA]: European Free Trade Association
          *[FMD]: foot and mouth disease
          *[EHD]: epizootic haemorrhagic disease
          *[BTV]: bluetongue virus
          *[BTV-3]: bluetongue virus serotype 3
          *[EFTA]: European Free Trade Association
          *[PPR]: peste des petits ruminants
          *[ASF]: African swine fever#{' '}
          *[CSF]: classical swine fever

          *[BTV]: bluetongue virus
        MARKDOWN

        item = stub(body: long_markdown)

        Benchmark.bmbm do |x|
          puts "\nRunning with Benchmark.bmbm:"
          x.report("corp info page document once:") { Govspeak::Document.new(corp_item.body).structured_headers }
          x.report("long document once:") { Govspeak::Document.new(item.body).structured_headers }
          x.report("long document 100 times:") { 100.times { ; Govspeak::Document.new(item.body).structured_headers; } }
          x.report("long document 400 times:") { 400.times { ; Govspeak::Document.new(item.body).structured_headers; } }
        end
      end

      test "returns an array of level 2 headers if they are found in the body" do
        item = stub(body: "## Heading 2 \n\nSome stuff\n\n")

        expected_headers = {
          headers: [{
            text: "Heading 2",
            level: 2,
            id: "heading-2",
          }],
        }

        assert_equal Headers.for(item), expected_headers
      end

      test "returns an array including level 3 headers if they are found in the body" do
        item = stub(body: "## Heading 2 \n\nSome stuff\n\n### Heading 3\n\nSome stuff\n\n")

        expected_headers = {
          headers: [{
            text: "Heading 2",
            level: 2,
            id: "heading-2",
            headers: [{
              text: "Heading 3",
              level: 3,
              id: "heading-3",
            }],
          }],
        }

        assert_equal Headers.for(item), expected_headers
      end

      test "returns an empty array of headers if none are found in the body" do
        item = stub(body: "Some stuff")

        assert_equal 0, Headers.for(item)[:headers].count
      end
    end
  end
end
