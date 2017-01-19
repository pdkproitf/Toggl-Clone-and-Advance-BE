require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {FactoryGirl.build :user}  # => Using for case test success
  subject {FactoryGirl.build :user} # => Using because is_expected ~ expect(subject), use tet false

  describe  "test should be valid" do
    it  {expect(user).to be_valid}
  end

  describe  "test name" do
    it "success with name not nill or false" do
      expect(user).to be_valid(:name)
    end

    it "success name have appropriate lengh (>=6)" do
      expect(user.name).to have_at_least(6).items
    end

    it "error name nil" do
      subject.name = nil
      is_expected.to have_at_least(1).errors_on(:name)
    end

    it "error name have lengt< 6" do
      subject.name = "abc"
      is_expected.to have_at_least(1).errors_on(:name)
    end
  end

  describe  "Test email"  do
    it "success with email valid" do
      expect(user).to be_valid(:email)
    end

    it "email should not be too long" do
      subject.email = "a" * 254 + "@pdk.com"
      is_expected.to  have_at_least(1).errors_on(:email)
    end

    it "email validation should acept valid address" do
      valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
       first.last@foo.jp alice+bob@baz.cn]
       valid_addresses.each do |valid_address|
        user.email = valid_address
        expect(user).to  be_valid(:email)
      end
    end

    it "email validation should reject invalid addresses" do
      invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
       foo@bar_baz.com foo@bar+baz.com]
       invalid_addresses.each do |invalid_address|
        subject.email = invalid_address
        is_expected.to have_at_least(1)
          .errors_on( :email,
                       context: "{invalid_address.inspect} should be invalid")
      end
    end

    it "email validate uniquess" do
      subject.email = user.email
      user.save
      is_expected.to have_at_least(1).error_on(:email)
    end

    it "email address should be saved as lower-case" do
      subject.email = user.email.upcase
      user.email.downcase
      user.save
      is_expected.to have_at_least(1).errors_on(:email)
    end
  end

  describe  "test password" do
    it "password should be present (not blak)" do
      subject.password = subject.password_confirmation = " " * 6
      is_expected.to  have_at_least(1).error_on(:password)
    end

    it "password should have a minimum length" do
      subject.password = subject.password_confirmation = "a" * 5
      is_expected.to  have_at_least(1).errors_on(:password)
    end
  end
end
