class Category < ApplicationRecord
  belongs_to :project
  has_many :category_members, dependent: :destroy
  has_many :members, through: :category_members
  validates :name, presence: true, length: { minimum: 1 }
  validates_uniqueness_of :name, scope: :project_id

  def get_tracked_time
    sum = 0
    if category_members
      category_members.each do |category_member|
        sum += category_member.get_tracked_time
      end
    end
    sum
  end

  def include_member?(member_id)

  end

  def add_member(member_id)
    member_id
  end

  def check_assigned?(member)
    category_members.where()
  end

  def check_archived?(member)
    category_members.
  end

  def unarchive_member(assigned_member)
    assigned_member = category_members.find_by(member_id: member_id)
    if !assigned_member.nil?

    end
  end

  def archive_members_not_in(member_ids)
    members = project_members
              .where.not(member_id: member_ids, is_archived: true)
    members.each(&:archived)
  end

  def archive
    update_attributes(is_archived: true)
  end

  def unarchive
    update_attributes(is_archived: false)
  end
end
