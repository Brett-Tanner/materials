# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification do
  it 'has a valid factory' do
    expect(build(:notification)).to be_valid
  end

  it 'is unread by default' do
    expect(described_class.new.read).to be false
  end

  it 'does not accept invalid URLs' do
    notification = build(:notification, link: 'in:vali//d')
    error = "Link #{notification.link} is not a valid URL"
    notification.valid?
    expect(notification.errors.full_messages).to include(error)
  end

  context 'when calling methods on User through Notifiable' do
    let(:user) { build(:user) }
    let(:notification) { build(:notification) }

    it 'can add a notification' do
      user.notify(notification)
      expect(user.notifications).to contain_exactly(notification)
    end

    it 'can add multiple notifications at once' do
      user.notify(notification, notification, notification)
      expect(user.notifications.size).to eq 3
    end

    it 'does not destroy existing notifications when new one added' do
      2.times { user.notify(notification) }
      expect(user.notifications.size).to eq 2
    end

    it 'prunes read if adding notification would make count > max' do
      user.notify(*(1..Notification::MAX_NOTIFICATIONS).map { notification })
      user.mark_all_notifications_read
      unread_notification = build(:notification, read: false)
      user.notify(unread_notification, unread_notification)
      expect(user.notifications.size).to eq 10
    end

    it 'can mark notifications read' do
      user.notify(notification)
      user.notifications[0].mark_read
      user.save
      expect(user.reload.notifications[0].read).to be true
    end

    it 'can mark all notifications read' do
      3.times { user.notify(notification) }
      user.mark_all_notifications_read
      user.save
      expect(user.reload.notifications.all?(&:read)).to be true
    end

    it 'can delete a notification' do
      extra = build(:notification, text: 'extra')
      delete_notif = build(:notification, text: 'delete target')
      user.notify(extra, extra, delete_notif, extra)
      user.save
      user.delete_notification(index: 2)
      expect(user.notifications.none?(delete_notif)).to be true
    end
  end
end