require 'fileutils'
require 'yaml'

class SyncController < ApplicationController
  include ApplicationHelper

  before_action :set_project, only: [:preview, :sync]

  def preview
    stored_transactions = @project.transactions.to_a
    statement_transactions = @project.scan_statement_transactions

    @new_transactions = []
    @orphaned_transactions = stored_transactions.clone
    @synced_transactions = []

    statement_transactions.each do |candidate|
      store_index = stored_transactions.index{ |t| t.data_attributes == candidate.data_attributes }
      orphan_index = @orphaned_transactions.index{ |t| t.data_attributes == candidate.data_attributes }
      if store_index.nil?
        @new_transactions << candidate
      else
        @orphaned_transactions.delete_at(orphan_index)
        @synced_transactions << candidate
      end
    end
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
        'transactions' => transactions.map { |transaction| marshal_for_file(transaction) }
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