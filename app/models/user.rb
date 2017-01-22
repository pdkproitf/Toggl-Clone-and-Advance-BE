class User < ActiveRecord::Base
    has_many :projects, dependent: :destroy
    has_many :project_user_roles, dependent: :destroy
    has_many :project_category_users, dependent: :destroy
    has_many :project_categories, through: :project_category_users
    has_many :projects, through: :project_user_roles
    has_many :roles, through: :project_user_roles

    # Include default devise modules.
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable,
           :confirmable, :omniauthable
    include DeviseTokenAuth::Concerns::User

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable

    validates :name,  presence: true, length: { minimum: 6 }
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
