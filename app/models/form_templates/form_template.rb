# frozen_string_literal: true

class FormTemplate < ApplicationRecord
  include StoreModel::NestedAttributes

  FormTemplateField = StoreModel.one_of do |json|
    input_type = json[:input_type] || json['input_type']
    case input_type
    when 'text_field'
      FormTemplateTextField
    when 'check_box'
      FormTemplateCheckBox
    when 'text_area'
      FormTemplateTextArea
    end
  end

  attribute :fields, FormTemplateField.to_array_type
  accepts_nested_attributes_for :fields
  validates :fields, store_model: { merge_array_errors: true }

  belongs_to :organisation
  has_many :form_submissions, dependent: :restrict_with_error
end