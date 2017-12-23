class SyncController < ApplicationController
  before_action :set_project, only: [:preview, :sync]

  def preview
    @statements = @project.scan
  end

  def sync
    @project.transactions.delete_all
    @statements = @project.scan
    @statements.each do |statement|
      statement.scan.each do |transaction|
        transaction.save
      end
    end

    redirect_to project_transactions_path(@project)
  end

private
  def set_project
    @project = Project.find(params[:id])
  end
end