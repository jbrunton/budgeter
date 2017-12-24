require 'fileutils'
require 'yaml'

class SyncController < ApplicationController
  include ApplicationHelper

  before_action :set_project, only: [:preview, :sync]

  def preview
    @statements = @project.scan_statements
  end

  def sync
    @project.transactions.delete_all
    @statements = @project.scan_statements
    @statements.each do |statement|
      statement.scan_transactions.each do |transaction|
        transaction.save
      end
    end

    Dir.glob(File.join(@project.directory, 'transactions/*.yaml')).each do |filename|
      FileUtils.rm(filename)
    end

    @project.transactions.group_by{ |t| t.date.strftime('%Y-%m-%b') }.each do |filename, transactions|
      content = {
        'transactions' => transactions.each_with_index.map do |transaction, index|
          transaction.store_name = "#{filename}.yaml"
          transaction.store_index = index
          transaction.save
          marshal_for_file(transaction)
        end
      }
      File.write(File.join(@project.directory, 'transactions', "#{filename}.yaml"), content.to_yaml)
    end

    redirect_to project_transactions_path(@project)
  end

private
  def set_project
    @project = Project.find(params[:id])
  end

  def marshal_for_file(transaction)
    attrs = transaction.data_attributes
    attrs['value'] = currency(attrs['value'])
    attrs['balance'] = currency(attrs['balance'])
    attrs
  end
end