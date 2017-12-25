class BackupController < ApplicationController
  before_action :set_project, only: [:index, :download, :import]

  def index

  end

  def download
    @content = ProjectSerializer.new(@project).serialize
    render plain: @content
  end

  def import
    ProjectSerializer.new(@project).deserialize(params[:project_data].read)
    redirect_to @project, notice: 'Project data imported'
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end
end