# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a DailyActivity lesson' do
  let!(:org) { create(:organisation, name: 'KidsUP') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create a daily activity lesson' do
    visit lessons_path
    find_by_id('create_lesson').click
    click_link 'create_daily_activity'
    within '#daily_activity_form' do
      fill_in 'daily_activity_title', with: 'Test Daily Activity'
      fill_in 'daily_activity_goal', with: 'Test Goal'
      select 'Kindy', from: 'daily_activity_level'
      select 'Games', from: 'daily_activity_subtype'
      fill_in 'daily_activity_intro', with: 'Test Intro'
      fill_in 'daily_activity_instructions', with: "Test Instruction 1\nTest Instruction 2"
      fill_in 'daily_activity_links', with: "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
      click_button I18n.t('helpers.submit.create')
    end
    expect(page).to have_content('Test Daily Activity')
    expect(page).to have_content('Test Goal')
    expect(page).to have_content('Games')
    expect(page).to have_content('Test Instruction 1')
    expect(page).to have_css('a.lesson_link', count: 2)
  end
end
