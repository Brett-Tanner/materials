# frozen_string_literal: true

class Student < ApplicationRecord
  include Levelable

  after_create :generate_student_id

  validates :level, :name, presence: true
  # We want them to be able to add their own student ids if they have them
  # So can't make it globally unique
  # Unique per school is a good compromise, by org would require extra queries
  validates :student_id, uniqueness: { allow_nil: true, scope: :school_id }
  encrypts :name

  belongs_to :parent, optional: true
  belongs_to :school, counter_cache: true
  delegate :organisation_id, to: :school
  has_many :teachers, through: :school

  has_many :student_classes, dependent: :destroy
  accepts_nested_attributes_for :student_classes
  has_many :classes, through: :student_classes,
                     source: :school_class

  has_many :test_results, dependent: :destroy
  has_many :tests, through: :test_results

  private

  def generate_student_id
    return unless student_id.nil?

    self.student_id = "#{id}-#{school_id}-#{SecureRandom.alphanumeric}"
    save
  end
end
