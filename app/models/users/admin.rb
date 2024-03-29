# frozen_string_literal: true

class Admin < User
  VISIBLE_TYPES = %w[OrgAdmin Parent Sales SchoolManager Teacher Writer].freeze

  validate :only_at_ku

  has_many :assigned_lessons,
           class_name: 'Lesson',
           dependent: :restrict_with_error,
           foreign_key: :assigned_editor_id,
           inverse_of: :assigned_editor
  has_many :created_lessons,
           class_name: 'Lesson',
           dependent: :restrict_with_error,
           foreign_key: :creator_id,
           inverse_of: :creator
  has_many :proposed_changes,
           foreign_key: :proponent_id,
           dependent: :restrict_with_error,
           inverse_of: :proponent

  private

  def only_at_ku
    errors.add(:organisation, 'must be "KidsUP"') unless ku?
  end
end
