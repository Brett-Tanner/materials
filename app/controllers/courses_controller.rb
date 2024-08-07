# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :set_course, only: %i[show edit update]
  before_action :set_form_data, only: %i[new edit]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @courses = policy_scope(Course)
  end

  def show
    @lessons = @course.lessons
                      .released
                      .select(:id, :subtype, :title, :type)
                      .includes(:course_lessons)
                      .order('course_lessons.week ASC, course_lessons.day ASC')
  end

  def new
    @course = authorize Course.new
  end

  def edit; end

  def create
    @course = authorize Course.new(course_params)

    if @course.save
      redirect_to @course
    else
      set_form_data
      render :new, status: :unprocessable_entity,
                   alert: 'Course could not be created'
    end
  end

  def update
    if @course.update(course_params)
      redirect_to @course
    else
      set_form_data
      render :edit, status: :unprocessable_entity,
                    alert: 'Course could not be updated'
    end
  end

  private

  def course_params
    params.require(:course).permit(:title, :description, :released)
  end

  def set_course
    @course = authorize Course.find(params[:id])
  end

  def set_form_data
    @lessons = Lesson.pluck(:title, :id)
  end
end
