# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating Teacher' do
  let!(:organisation) { create(:organisation) }
  let!(:school) { organisation.schools.create!(attributes_for(:school, ip: '*')) }

  before do
    sign_in create(:user, :school_manager, organisation:, schools: [school])
    course = create(:course)
    create(:plan, course:, organisation:)
  end

  it 'School Manager can create teacher at their schools' do
    visit organisation_teachers_path(organisation_id: organisation.id)
    find_by_id('create_user').click
    click_link 'create_teacher'
    within '#teacher_form' do
      fill_in 'teacher_name', with: 'John'
      fill_in 'teacher_email', with: 'xjpjv@example.com'
      select school.name, from: 'teacher_school_teachers_attributes_0_school_id'
      click_on 'submit_teacher'
    end
    expect(page).to have_content I18n.t('create_success')
  end
end
