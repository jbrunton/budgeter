class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :categories, :verification_state]

  include FormatHelper

  def categories
    respond_to do |format|
      format.json { render json: @project.categories, status: :ok }
    end
  end

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @verification_state = @project.verification_state

    unless @project.transactions.empty?
      charts_to_date = @project.transactions.order('date').last.date
      charts_from_date = (charts_to_date - 90.days).beginning_of_month
      chart_params = 'from_date=' + date_value(charts_from_date) +
        '&to_date=' + date_value(charts_to_date) +
        '&show_total=true';
    end
    chart_account_ids = @project.accounts.map{ |a| "account_ids[]=#{a.id}" }.join('&')

    @balance_chart_url = "#{project_path(@project)}/reports/balance_data/?#{chart_params}"
    @spend_chart_url = "#{project_path(@project)}/reports/spend_data/?#{chart_params}&#{chart_account_ids}"
    @income_outgoings_chart_url = "#{project_path(@project)}/reports/income_outgoings_data/?#{chart_params}&#{chart_account_ids}"
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :directory)
    end
end
