class ImportController < ApplicationController
  before_action :set_project, only: [:preview, :import]

  def preview

  end

  def import
    @project.transactions.delete_all
    @project.scan_stored_transactions.each do |t|
      t.save
    end
    redirect_to project_transactions_path(@project)
  end

private
  def set_project
    @project = Project.find(params[:id])
  end
end