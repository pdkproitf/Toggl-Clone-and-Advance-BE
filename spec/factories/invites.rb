FactoryGirl.define do
  factory :invite do
    email "MyString"
    company nil
    sender_id 1
    recipient_id 1
    token "MyString"
    expiry 1
    accepted false
  end
end
