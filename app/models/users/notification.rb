# frozen_string_literal: true

class Notification
  include StoreModel::Model

  MAX_NOTIFICATIONS = 10

  attribute :created_at, :datetime, default: -> { Time.zone.now }
  attribute :link, :string
  attribute :read, :boolean, default: false
  attribute :text, :string

  validates :text, presence: true
  validate :valid_uri

  def mark_read
    self.read = true
  end

  private

  def valid_uri
    return if link.nil? || URI.parse(link).instance_of?(URI::HTTPS)

    errors.add(:link, "#{link} is not a valid URL")
  end
end