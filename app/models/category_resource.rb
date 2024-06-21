# frozen_string_literal: true

class CategoryResource < ApplicationRecord
  before_destroy :check_not_used

  enum lesson_category: {
    phonics_class: 0,
    brush_up: 1,
    snack: 2,
    get_up_and_go: 3,
    daily_gathering: 4
  }

  enum resource_category: {
    phonics_set: 0,
    word_family: 1,
    sight_words: 2,
    worksheet: 3,
    slides: 4
  }

  validates :lesson_category, :resource_category, presence: true
  validate :valid_combo

  has_many :course_resources, dependent: :destroy
  accepts_nested_attributes_for :course_resources,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :courses, through: :course_resources
  has_many :phonics_resources, dependent: :destroy
  accepts_nested_attributes_for :phonics_resources,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :phonics_classes, through: :phonics_resources

  has_one_attached :resource

  private

  def check_not_used
    return true if course_resources.reload.empty?

    errors.add(:course_resources, :invalid,
               message: 'Cannot delete category resource if it is used in a course')
    throw :abort
  end

  def valid_combo
    send(:"#{lesson_category}_resource?")
  end

  def phonics_class_resource?
    return true if %w[phonics_set word_family sight_words].include?(resource_category)

    errors.add(:lesson_category,
               'Phonics Class requires a phonics set, word family, or sight words resource')
    false
  end

  def brush_up_resource?
    return true if resource_category == 'worksheet'

    errors.add(:lesson_category, 'Brush Up requires a worksheet resource')
    false
  end

  def snack_resource?
    return true if %w[worksheet slides].include?(resource_category)

    errors.add(:lesson_category, 'Snack requires a worksheet or slides resource')
    false
  end

  def get_up_and_go_resource? # rubocop:disable Naming/AccessorMethodName
    return true if %w[worksheet slides].include?(resource_category)

    errors.add(:lesson_category, 'Get Up & Go requires a worksheet or slides resource')
    false
  end

  def daily_gathering_resource?
    return true if %w[worksheet slides].include?(resource_category)

    errors.add(:lesson_category, 'Daily Gathering requires a worksheet or slides resource')
    false
  end
end
