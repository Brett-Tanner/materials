# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a Phonics lesson' do
  let!(:org) { create(:organisation, name: 'KidsUP') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create a phonics lesson' do
    visit lessons_path
    find_by_id('create_lesson').click
    click_link 'create_phonics_class'
    within '#phonics_class_form' do
      fill_in 'phonics_class_title', with: 'Test Phonics Lesson'
      fill_in 'phonics_class_goal', with: 'Test Goal'
      select 'Kindy', from: 'phonics_class_level'
      fill_in 'phonics_class_add_difficulty', with: "Difficult idea 1\nDifficult idea 2"
      fill_in 'phonics_class_extra_fun', with: "Extra 1\nExtra 2"
      fill_in 'phonics_class_instructions', with: "Test Instructions 1\nTest Instructions 2"
      fill_in 'phonics_class_links', with: "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
      fill_in 'phonics_class_materials', with: "Material 1\nMaterial 2"
      fill_in 'phonics_class_notes', with: "Note 1\nNote 2"
      click_button 'Create Phonics class'
    end
    expect(page).to have_content('Test Phonics Lesson')
    expect(page).to have_content('Test Goal')
    expect(page).to have_content('Difficult idea 1')
    expect(page).to have_content('Extra 1')
    expect(page).to have_content('Note 2')
    expect(page).to have_css('a.lesson_link', count: 2)
  end
end
