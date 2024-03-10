# frozen_string_literal: true

class ExercisesController < LessonsController
  def index
    @lessons = Exercise.order(title: :desc)
  end

  def create
    @lesson = authorize Lesson.new(exercise_params)
    super

    if @lesson.save
      redirect_to lesson_url(@lesson),
                  notice: 'Exercise successfully created.'
    else
      set_courses
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: 'Exercise could not be created'
    end
  end

  def update
    return propose_changes(exercise_params) if proposing_changes?

    if @lesson.update(exercise_params)
      redirect_to after_update_url,
                  notice: 'Exercise was successfully updated.'
    else
      set_courses
      render 'lessons/edit',
             status: :unprocessable_entity,
             alert: 'Exercise could not be updated'
    end
  end

  private

  def exercise_params
    e_params = %i[
      add_difficulty extra_fun instructions intro large_groups
      links materials notes outro guide_image
    ]
    params.require(:exercise).permit(lesson_params + e_params)
  end

  def after_update_url
    if params[:commit] == 'Change Date'
      course = exercise_params[:course_lessons_attributes]['0'][:course_id]
      course_url(course)
    else
      lesson_url(@lesson)
    end
  end
end
