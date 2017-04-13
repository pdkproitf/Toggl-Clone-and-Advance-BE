FactoryGirl.define do
  factory :scheduler do
    name "MyString"
    frequency 1
    at "MyString"
    clock_job nil
    clock_job_arguments ""
    company nil
  end
end
