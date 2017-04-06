class Projects::TriggersController < Projects::ApplicationController
  before_action :authorize_admin_build!
  before_action :authorize_manage_trigger!, except: [:index, :create]
  before_action :authorize_admin_trigger!, only: [:edit, :update]
  before_action :trigger, only: [:take_ownership, :edit, :update, :destroy]

  layout 'project_settings'

  def index
    redirect_to namespace_project_settings_ci_cd_path(@project.namespace, @project)
  end

  def create
    @trigger = project.triggers.create(create_params.merge(owner: current_user))

    if @trigger.valid?
      flash[:notice] = 'Trigger was created successfully.'
    else
      flash[:alert] = 'You could not create a new trigger.'
    end

    redirect_to namespace_project_settings_ci_cd_path(@project.namespace, @project)
  end

  def take_ownership
    if trigger.update(owner: current_user)
      flash[:notice] = 'Trigger was re-assigned.'
    else
      flash[:alert] = 'You could not take ownership of trigger.'
    end

    redirect_to namespace_project_settings_ci_cd_path(@project.namespace, @project)
  end

  def edit
  end

  def update
    if trigger.update(update_params)
      redirect_to namespace_project_settings_ci_cd_path(@project.namespace, @project), notice: 'Trigger was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    if trigger.destroy
      flash[:notice] = "Trigger removed."
    else
      flash[:alert] = "Could not remove the trigger."
    end

    redirect_to namespace_project_settings_ci_cd_path(@project.namespace, @project)
  end

  private

  def authorize_manage_trigger!
    access_denied! unless can?(current_user, :manage_trigger, trigger)
  end

  def authorize_admin_trigger!
    access_denied! unless can?(current_user, :admin_trigger, trigger)
  end

  def trigger
    @trigger ||= project.triggers.find(params[:id]) || render_404
  end

  def create_params
    params.require(:trigger).permit(
      :description, :ref, :trigger_schedule_on,
      trigger_schedule_attributes: [ :cron, :cron_timezone ]
    )
  end

  def update_params
    params.require(:trigger).permit(
      :description, :ref, :trigger_schedule_on,
      trigger_schedule_attributes: [ :cron, :cron_timezone ]
    )
  end
end
