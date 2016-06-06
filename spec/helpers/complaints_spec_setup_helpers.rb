require 'rspec/core/shared_context'

module ComplaintsSpecSetupHelpers
  extend RSpec::Core::SharedContext

  def populate_database
    create_categories
    create_mandates
    create_agencies
    FactoryGirl.create(:complaint, :case_reference => "c12/34",
                       :village => Faker::Address.city,
                       :phone => Faker::PhoneNumber.phone_number,
                       :human_rights_complaint_bases => hr_complaint_bases,
                       :good_governance_complaint_bases => gg_complaint_bases,
                       :special_investigations_unit_complaint_bases => siu_complaint_bases,
                       :assigns => assigns,
                       :complaint_documents => complaint_docs,
                       :complaint_categories => complaint_cats,
                       :status_changes => _status_changes,
                       :mandates => _mandates,
                       :agencies => _agencies)
  end

  private
  def create_mandates
    [:good_governance, :human_rights, :special_investigations_unit].each do |key|
      FactoryGirl.create(:mandate, :key => key)
    end
  end

  def _mandates
    [ Mandate.find_by(:key => 'human_rights' ) ]
  end

  def _agencies
    [ Agency.find_by(:name => 'SAA') ]
  end

  def _status_changes
    # open 100 days ago, closed 50 days ago
    [FactoryGirl.build(:status_change, :created_at => DateTime.now.advance(:days => -100), :new_value => 1, :user_id => User.pluck(:id).first),
     FactoryGirl.build(:status_change, :created_at => DateTime.now.advance(:days => -50), :new_value => 0, :user_id => User.pluck(:id).second )]
  end

  def create_categories
    ["Formal", "Informal", "Out of Jurisdication"].each do |category|
      FactoryGirl.create(:complaint_category, :name => category) 
    end
  end

  def complaint_cats
    [ ComplaintCategory.find_by(:name => "Formal") ]
  end

  def complaint_docs
    Array.new(2) { FactoryGirl.create(:complaint_document) }
  end

  def hr_complaint_bases
    names = ["CAT", "ICESCR"]
    names.collect{|name| FactoryGirl.create(:convention, :name => name)}
  end

  def gg_complaint_bases
    names = ["Delayed action", "Failure to act"]
    names.collect{|name| FactoryGirl.create(:good_governance_complaint_basis, :name => name) }
  end

  def siu_complaint_bases
    names = ["Unreasonable delay", "Not properly investigated"]
    names.collect{|name| FactoryGirl.create(:siu_complaint_basis, :name => name) }
  end

  def assigns
    Array.new(2) do
      assignee = FactoryGirl.create(:assignee, :with_password)
      date = DateTime.now.advance(:days => -rand(365))
      Assign.new(:created_at => date, :assignee => assignee)
    end
  end

  def create_agencies
    AGENCIES.each do |name,full_name|
      Agency.create(:name => name, :full_name => full_name)
    end
  end
end