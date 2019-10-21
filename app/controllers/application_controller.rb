class ApplicationController < ActionController::Base
  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from Contentful::EntryNotFound, with: :render_404

  private

  def render_404
    render(
      file: Rails.root.join('public', '404.html'),
      status: :not_found,
      layout: false
    )
  end
end
