# frozen_string_literal: true

class LessonsController < ApplicationController
  before_action :set_lesson, only: %i[destroy edit show update]
  before_action :set_form_info, only: %i[new edit]
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]
  after_action :generate_guide, only: %i[create update]

  def index
    @lessons = policy_scope(Lesson).accepted.order(title: :asc)
    @writers = policy_scope(User).where(type: %w[Admin Writer]).pluck(:name, :id)
  end

  def show
    @courses = @lesson.courses
    @proposals = @lesson.proposals
                        .order(created_at: :desc)
                        .includes(:creator)
    @resources = @lesson.resources.includes(:blob)
    @writers = User.where(type: %w[Admin Writer]).pluck(:name, :id) if current_user.is?('Admin')
  end

  def new
    type = params[:type] if Lesson::TYPES.include?(params[:type])
    @lesson = authorize type.constantize.new
  end

  def edit; end

  def create
    @lesson.creator_id = current_user.id
    @lesson.assigned_editor_id = current_user.id
    @lesson.status = current_user.is?('Admin') ? :accepted : :proposed
  end

  def update
    if current_user.is?('Writer') && !@lesson.accepted?
      type_params.merge(status: :proposed)
    else
      type_params
    end
  end

  def destroy
    if @lesson.destroy
      redirect_to lessons_path,
                  notice: 'Lesson was successfully destroyed.'
    else
      redirect_to lessons_path,
                  alert: "Lesson could not be destroyed. Check it's not still in use"
    end
  end

  private

  def lesson_params
    default_params = [
      :goal, :level, :title, :type, :curriculum_approval_id, :curriculum_approval_name,
      :internal_notes, { resources: [] }
    ]
    return default_params unless current_user.is?('Admin')

    default_params + [:assigned_editor_id, :admin_approval_id, :admin_approval_name, :released, :status,
                      { course_lessons_attributes: %i[id _destroy course_id day lesson_id week] }]
  end

  def after_update_url
    case params[:commit]
    when 'Change Date'
      course_id = type_params[:course_lessons_attributes]['0'][:course_id]
      course_url(course_id)
    when 'Awaiting Approval', 'Unreleased', 'Released'
      lessons_url
    else
      lesson_url(@lesson)
    end
  end

  def propose_changes(strong_params)
    @proposal = @lesson.proposals.new(
      strong_params.merge(
        status: :proposed,
        creator_id: current_user.id,
        assigned_editor_id: current_user.id
      )
    )

    if @proposal.save
      redirect_to lesson_path(@lesson),
                  notice: 'Changes successfully proposed.'
    else
      render :edit, status: :unprocessable_entity,
                    alert: 'Changes could not be proposed.'
    end
  end

  def set_form_info
    @courses = Course.pluck(:title, :id)
    @resource_ids = @lesson.resources.includes(:blob).map(&:signed_id)
  end

  def set_lesson
    @lesson = authorize Lesson.find(params[:id])
  end

  def generate_guide
    return unless @lesson.persisted?

    @proposal ? @proposal.attach_guide : @lesson.attach_guide
  end

  def proposing_changes?
    return false unless current_user.is?('Writer') && @lesson.accepted?

    status_attrs = [
      I18n.t('approve'), I18n.t('awaiting_approval'), I18n.t('not_approved'), I18n.t('update_notes')
    ]
    status_attrs.none?(params[:commit])
  end
end
