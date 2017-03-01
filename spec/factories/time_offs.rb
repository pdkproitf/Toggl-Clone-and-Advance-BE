FactoryGirl.define do
  factory :time_off do
    sender_id 1
    start_date "2017-02-27 09:36:17"
    end_date "2017-02-27 09:36:17"
    is_start_half_day false
    is_end_half_day false
    description "MyText"
    approver_id false
    status 1
  end
end
