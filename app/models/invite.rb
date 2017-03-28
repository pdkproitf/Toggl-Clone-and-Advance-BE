class Invite < ApplicationRecord
    before_create :generate_token, :generate_expry
    attr_accessor :invite_token

    belongs_to :sender, class_name: 'Member'
    belongs_to :recipient, class_name: 'User'

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                      length: { maximum: Settings.mail_max_length }
    validates_presence_of :sender_id

    def send_email link
        InviteMailer.send_invite(self, invite_token, link).deliver_later
    end

    def generate_token
        self.token = digest(new_token)
    end

    def generate_expry
        self.expiry = (Time.now + Settings.invite_expry.week)
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
