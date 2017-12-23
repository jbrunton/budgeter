require 'fileutils'

class SyncController < ApplicationController
  FILE_ATTRIBUTES = ['date', 'transaction_type', 'description', 'value', 'balance']
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

    Dir.glob(File.join(@project.directory, 'transactions/*.yaml')).each do |filename|
      FileUtils.rm(filename)
    end

    @project.transactions.group_by{ |t| t.date.strftime('%Y-%m-%b') }.each do |key, transactions|
      byebug
      content = {
        transactions: transactions.map{ |t| t.attributes.slice(*FILE_ATTRIBUTES) }
      }
      File.write(File.join(@project.directory, 'transactions', "#{key}.yaml"), content.to_yaml)
    end

    redirect_to project_transactions_path(@project)
  end

private
  def set_project
    @project = Project.find(params[:id])
  end
end