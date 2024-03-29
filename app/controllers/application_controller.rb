# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :set_locale

  private

  def default_url_options
    { locale: I18n.locale }
  end

  def set_locale
    locale = params[:locale] || locale_from_accept_language || I18n.default_locale
    I18n.locale = locale
  end

  def locale_from_accept_language
    http_accept_language.compatible_language_from(I18n.available_locales)
  end

  def user_not_authorized
    redirect_to root_path,
                alert: t('not_authorized')
  end
end
