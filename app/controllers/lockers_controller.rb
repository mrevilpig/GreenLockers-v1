class LockersController < ApplicationController
  before_action :set_locker, only: [:show, :edit, :update, :destroy, :init_locker]
  # GET /lockers
  # GET /lockers.json
  def index
    @lockers = Locker.all
  end

  # GET /lockers/1
  # GET /lockers/1.json
  def show 
      u_packages = Package.where("box_id is NULL and (status = 0 OR status = 5) ").order('updated_at ASC')
      @unassigned_packages = u_packages.select{ |p| 
        if p.preferred_branch_id
          p.preferred_branch_id == @locker.branch_id
        elsif p.user.preferred_branch_id
          p.user.preferred_branch_id == @locker.branch_id
        else
          true == false
        end 
      }
  end

  # GET /lockers/new
  def new
    @locker = Locker.new
  end

  # GET /lockers/1/edit
  def edit
  end

  # POST /lockers
  # POST /lockers.json
  def create
    @locker = Locker.new(locker_params)

    respond_to do |format|
      if @locker.save
        @locker.init_locker
        format.html { redirect_to @locker, notice: 'Locker was successfully created.' }
        format.json { render action: 'show', status: :created, location: @locker }
      else
        format.html { render action: 'new' }
        format.json { render json: @locker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lockers/1
  # PATCH/PUT /lockers/1.json
  def update
    respond_to do |format|
      if @locker.update(locker_params)
        format.html { redirect_to @locker, notice: 'Locker was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @locker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lockers/1
  # DELETE /lockers/1.json
  def destroy
    @locker.boxes.each do |b|
      b.destroy
      b.access.destroy
    end
    @locker.destroy
    respond_to do |format|
      format.html { redirect_to lockers_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_locker
      @locker = Locker.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def locker_params
      params.require(:locker).permit(:branch_id, :name)
    end

end
