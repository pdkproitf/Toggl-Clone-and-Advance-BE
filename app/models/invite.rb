class Invite < ApplicationRecord
    attr_accessor :invite_token

    belongs_to :sender, class_name: 'Member'
    # belongs_to :recipient, class_name: 'User'

    validates :email, presence: true

    before_create :generate_token
    def generate_token

        self.token = digest(new_token)
        self.expiry = (Time.now + 1.week)
    end

    def new_token
        self.invite_token = SecureRandom.urlsafe_base64
    end

    def digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    def authenticated?(invite_token)
        BCrypt::Password.new(token).is_password?(invite_token)
    end

    def expiry?
        self.expiry < Time.now
    end
end
