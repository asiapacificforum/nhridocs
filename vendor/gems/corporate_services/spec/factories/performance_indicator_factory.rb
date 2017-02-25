FactoryGirl.define do
  factory :performance_indicator do
    description { Faker::Lorem.words(6).join(" ") }

    trait :well_populated do
      after(:create) do |pi|
        2.times do
          MediaAppearance.create(:title => "foo", :performance_indicators => [pi])
          #FactoryGirl.create(:project, :performance_indicators => [pi])
          pi.reminders << FactoryGirl.create(:reminder, :performance_indicator, :remindable_id => pi.id)
          pi.save
        end
      end
    end
  end
end
