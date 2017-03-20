class User < ActiveRecord::Base
    before_save :downcase_email
    # after_create :send_confirmation_email
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    has_many :members, dependent: :destroy
    has_many :companies, through: :members

    has_many :invitations, class_name: 'Invite', foreign_key: 'recipient_id'

    # Include default devise modules.
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable,
           :confirmable, :omniauthable
    include DeviseTokenAuth::Concerns::User

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable

    validates :email, presence: true, length: { maximum: Settings.mail_max_length },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }
    validates :password, presence: true, length: { minimum: Settings.password_min_length },
                         allow_nil: true

    private

    # Converts email to all lower-case
    def downcase_email
        self.email = email.downcase
    end

    public

    def is_joined_project(project_id)
        project_user_roles.exists?(project_id: project_id)
    end

    protected

    def send_devise_notification(notification, *args)
        if new_record? || changed?
            pending_notifications << [notification, args]
        else
            devise_mailer.send(notification, self, *args).deliver_later(wait: Settings.send_later.seconds)
        end
    end
end
