status :draft
satisfies_need "2969"

additional_countries = UkbaCountry.all

exclude_countries = %w(american-samoa british-antarctic-territory british-indian-ocean-territory french-guiana french-polynesia gibraltar guadeloupe holy-see martinique mayotte new-caledonia reunion st-pierre-and-miquelon wallis-and-futuna western-sahara)

country_group_ukot = %w(anguilla bermuda british-dependent-territories-citizen british-overseas-citizen british-protected-person british-virgin-islands falkland-islands montserrat pitcairn-island st-helena-ascension-and-tristan-da-cunha south-georgia-and-south-sandwich-islands turks-and-caicos-islands)

country_group_non_visa_national = %w(andorra antigua-and-barbuda argentina australia bahamas barbados belize botswana brazil british-national-overseas brunei canada chile costa-rica curacao dominica timor-leste el-salvador grenada guatemala honduras hong-kong hong-kong-(british-national-overseas) israel japan kiribati south-korea macao malaysia maldives marshall-islands mauritius mexico micronesia monaco namibia nauru new-zealand nicaragua palau panama papua-new-guinea paraguay st-kitts-and-nevis st-lucia st-maarten st-vincent-and-the-grenadines samoa san-marino seychelles singapore solomon-islands taiwan tonga trinidad-and-tobago tuvalu usa uruguay vanuatu)

country_group_visa_national = %w(armenia aruba azerbaijan bahrain benin bhutan bonaire-st-eustatius-saba bosnia-and-herzegovina burkina-faso cambodia cape-verde central-african-republic chad comoros cuba djibouti dominican-republic egypt equatorial-guinea fiji gabon georgia guyana haiti india indonesia israel-(Laisse-Passer) jordan kazakhstan korea kuwait kyrgyzstan laos libya madagascar mali mauritania morocco mozambique niger pakistan peru philippines qatar russia sao-tome-and-principe saudi-arabia suriname syria tajikistan thailand togo tunisia turkmenistan ukraine united-arab-emirates uzbekistan vatican-city vietnam yemen zambia)

country_group_datv = %w(afghanistan albania algeria angola bangladesh belarus bolivia burma burundi cameroon china colombia congo democratic-republic-of-congo ecuador eritrea ethiopia gambia ghana guinea guinea-bissau india iran iraq cote-d-ivoire cyprus-north jamaica kenya kosovo lebanon lesotho liberia macedonia malawi moldova mongolia montenegro nepal nigeria oman the-occupied-palestinian-territories refugee rwanda senegal serbia sierra-leone somalia south-africa south-sudan sri-lanka stateless-person sudan swaziland tanzania turkey uganda venezuela vietnam zimbabwe)

country_group_eea = %w(austria belgium bulgaria croatia cyprus czech-republic denmark estonia finland france germany greece hungary iceland ireland italy latvia liechtenstein lithuania luxembourg malta netherlands norway poland portugal romania slovakia slovenia spain sweden switzerland)

# Q1
country_select :what_passport_do_you_have?, :additional_countries => additional_countries, :exclude_countries => exclude_countries do
  save_input_as :passport_country


  next_node do |response|
    if country_group_eea.include?(response)
  	 :outcome_no_visa_needed
    else
      :purpose_of_visit?
    end
  end
end

# Q2
multiple_choice :purpose_of_visit? do
  option :tourism
  option :work
  option :study
  option :transit
  option :family
  option :marriage
  option :school
  option :medical
  save_input_as :purpose_of_visit_answer

    # when 'study'
    #   if country_group_visa_national.include?(passport_country) or country_group_datv.include?(passport_country)
    #     :outcome_study_y
    #   else
    #     :outcome_study_m
    #   end
    # when 'work'
    #   if country_group_visa_national.include?(passport_country) or country_group_datv.include?(passport_country)
    #     :outcome_work_y
    #   else
    #     :outcome_work_m
    #   end
  calculate :reason_of_staying do
    if responses.last == 'study'
      PhraseList.new(:study_reason)
      
    elsif responses.last == 'work'
      PhraseList.new(:work_reason)
    end
  end
  
  next_node do |response|
    case response
    when 'study'
      :staying_for_how_long?
    when 'work'
      :staying_for_how_long?
    when 'tourism'
      if %w(venezuela oman qatar united-arab-emirates).include?(passport_country)
        :outcome_visit_waiver
      elsif country_group_non_visa_national.include?(passport_country) or
         country_group_ukot.include?(passport_country)
        :outcome_school_n
      else
        :outcome_general_y
      end
    when 'school'
      if %w(venezuela oman qatar united-arab-emirates).include?(passport_country)
        :outcome_visit_waiver
      elsif country_group_non_visa_national.include?(passport_country) or
         country_group_ukot.include?(passport_country)
        :outcome_school_n
      else
        :outcome_school_y
      end
    when 'marriage'
      :outcome_marriage
    when 'medical'
      if %w(venezuela oman qatar united-arab-emirates).include?(passport_country)
        :outcome_visit_waiver
      elsif country_group_non_visa_national.include?(passport_country) or
         country_group_ukot.include?(passport_country)
        :outcome_medical_n
      else
        :outcome_medical_y
      end
    when 'transit'
      if passport_country == 'venezuela'
        :outcome_visit_waiver
      elsif country_group_datv.include?(passport_country) or
         country_group_visa_national.include?(passport_country)
        :planning_to_leave_airport?
      else
        :outcome_no_visa_needed
      end
    when 'family'
      if country_group_ukot.include?(passport_country)
        :outcome_joining_family_m
      else
        :outcome_joining_family_y
      end
    end
  end
end

#Q3
multiple_choice :planning_to_leave_airport? do
  option :yes
  option :no

  next_node do |response|
    case response
    when 'yes'
      if country_group_datv.include?(passport_country) or
         country_group_visa_national.include?(passport_country)
        :outcome_transit_leaving_airport
      end
    when 'no'
      if country_group_datv.include?(passport_country)
        :outcome_transit_not_leaving_airport
      elsif country_group_visa_national.include?(passport_country)
        :outcome_no_visa_needed
      end
    end
  end
end

#Q4
multiple_choice :staying_for_how_long? do
  option :six_months_or_less
  option :longer_than_six_months
  
  next_node do |response|
    case response
    when 'longer_than_six_months'
      if purpose_of_visit_answer == 'study'
        :outcome_study_y #outcome 2 study y 
      elsif purpose_of_visit_answer == 'work'
        :outcome_work_y #outcome 4 work y 
      end
    when 'six_months_or_less'
      
      if purpose_of_visit_answer == 'study'
        ##if country= venezuela || oman || qatar || UAE 
        if %w(venezuela oman qatar united-arab-emirates).include?(passport_country)
          :outcome_visit_waiver #outcome 12 visit outcome_visit_waiver
        ##elsif country= visa || datv 
        elsif country_group_datv.include?(passport_country) || country_group_visa_national.include?(passport_country) 
          :outcome_study_m #outcome 3 study m visa needed short courses 
        # elsif country= non visa || UKOT 
        elsif country_group_ukot.include?(passport_country) || country_group_non_visa_national.include?(passport_country)
          :outcome_no_visa_needed #outcome 1 no visa needed
        end
        
      elsif purpose_of_visit_answer == 'work' 
        # elsif country= venezuela || oman || qatar || UAE 
        if %w(venezuela oman qatar united-arab-emirates).include?(passport_country)
          :outcome_visit_waiver #outcome 12 visit outcome_visit_waiver
        # if country= visa || datv
        elsif country_group_datv.include?(passport_country) || country_group_visa_national.include?(passport_country)
          :outcome_work_m #outcome 5 work m visa needed short courses
        # elsif country= non visa || UKOT 
        elsif country_group_ukot.include?(passport_country) || country_group_non_visa_national.include?(passport_country)
          :outcome_work_n #outcome 5.5 work N no visa needed
        end
      end
    end
  end                    
end


outcome :outcome_no_visa_needed do
  precalculate :if_croatia do
    if passport_country == 'croatia'
      PhraseList.new(:croatia_work_permit)
    end
  end
end
outcome :outcome_study_y
outcome :outcome_study_m
outcome :outcome_work_y do
  precalculate :if_turkey do
    if passport_country == 'turkey'
      PhraseList.new(:turkey_business_person_visa)
    end
  end
end
outcome :outcome_work_m
outcome :outcome_work_n
outcome :outcome_transit_leaving_airport
outcome :outcome_transit_not_leaving_airport
outcome :outcome_joining_family_y
outcome :outcome_joining_family_m
outcome :outcome_visit_business_n
outcome :outcome_general_y do
  precalculate :if_china do
    if passport_country == 'china'
      PhraseList.new(:china_tour_group)
    end
  end
end
outcome :outcome_business_y
outcome :outcome_marriage
outcome :outcome_school_n
outcome :outcome_school_y
outcome :outcome_medical_y
outcome :outcome_medical_n
outcome :outcome_visit_waiver do
  precalculate :if_venezuela do
    if passport_country == 'venezuela'
      PhraseList.new(:extra_documents)
    end
  end
  precalculate :if_oman_qatar_uae do
    if %w(oman qatar united-arab-emirates).include?(passport_country)
      PhraseList.new(:electronic_visa_waiver)
    end
  end
end


  

