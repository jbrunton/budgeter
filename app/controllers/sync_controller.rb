class SyncController < ApplicationController
  before_action :set_project, only: [:preview, :sync]

  def preview
    @statements = @project.scan
  end

private
  def set_project
    @project = Project.find(params[:id])
  end
end