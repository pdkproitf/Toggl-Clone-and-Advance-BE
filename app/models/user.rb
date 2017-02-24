class User < ActiveRecord::Base
    has_many :members, dependent: :destroy
    has_many :companies, through: :members

    has_many :invitations, class_name: 'Invite', foreign_key: 'recipient_id'
    has_many :sent_invites, class_name: 'Invite', foreign_key: 'sender_id'

    # Include default devise modules.
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable,
           :confirmable, :omniauthable
    include DeviseTokenAuth::Concerns::User

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable

    validates :email, presence: true, length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }
    validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

    before_save :downcase_email
    # after_create :send_confirmation_email

    private

    # Converts email to all lower-case
    def downcase_email
        self.email = email.downcase
    end
end
