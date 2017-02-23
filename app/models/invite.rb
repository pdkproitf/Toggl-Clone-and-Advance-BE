class Invite < ApplicationRecord
    belongs_to :company
    belongs_to :sender, class_name: 'User'
    # belongs_to :recipient, class_name: 'User'


    before_create :generate_token
    def generate_token
        self.token = Digest::SHA1.hexdigest([self.sender_id, Time.now, rand].join)
        self.expiry = (Time.now + 1.week)
    end

    def expiry?
        self.expiry < Time.now
    end
end
