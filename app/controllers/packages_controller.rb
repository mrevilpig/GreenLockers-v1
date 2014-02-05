class PackagesController < ApplicationController
  before_action :set_package, only: [:get_available_boxes, :show, :edit, :update, :destroy]
  # GET /packages
  # GET /packages.json
  def index
    @packages = Package.all
    @package = Package.new
  end

  # GET /packages/1
  # GET /packages/1.json
  def show
  end

  # GET /packages/new
  def new
    @package = Package.new
  end

  # GET /packages/1/edit
  def edit
  end

  # POST /packages
  # POST /packages.json
  def create
    @package = Package.new(package_params)
    
    respond_to do |format|
      if @package.user.nil?
        format.html { redirect_to :back, alert: 'Package create failed. No user selected' }
      elsif @package.save
        @package.generate_barcode
        format.html { redirect_to :back, notice: 'Package was successfully created.' }
        format.json { render action: 'show', status: :created, location: @package }
      else
        format.html { render action: 'new' }
        format.json { render json: @package.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /packages/1
  # PATCH/PUT /packages/1.json
  def update
    respond_to do |format|
      logger.info package_params
      if package_params[:user_id] == ""
        format.html { redirect_to :back, alert: 'Package save failed. No user selected' }
      elsif @package.update(package_params)
        format.html { redirect_to packages_path, notice: 'Package was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @package.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /packages/1
  # DELETE /packages/1.json
  def destroy
    @package.destroy
    respond_to do |format|
      format.html { redirect_to packages_url }
      format.json { head :no_content }
    end
  end
  
  def get_available_boxes
    respond_to do |format|
      if @package.preferred_branch_id 
        locker_ids = @package.preferred_branch.lockers.collect{|l| l.id.to_s}
      elsif @package.user.preferred_branch_id 
        locker_ids = @package.user.preferred_branch.lockers.collect{|l| l.id.to_s}
      else
        locker_ids = []
      end 
      if ( @package.status == @constant['PACKAGE_WAITING_FOR_DELIVERY'] or @package.status == @constant['PACKAGE_WAITING_FOR_DROP_OFF'] )
        if @package.status == @constant['PACKAGE_WAITING_FOR_DELIVERY']
          boxes = Box.where(:locker_id => locker_ids).select{ 
            |b| b.status == @constant['BOX_IDLE'] or ( b.status == @constant['BOX_RETURNED'] and b.backup_package.nil? ) 
          }
        else ( @package.status == @constant['PACKAGE_WAITING_FOR_DROP_OFF'] )
          boxes = Box.where(:locker_id => locker_ids).select{ |b| b.status == @constant['BOX_IDLE'] }
        end
        @boxes_array = []
        logger.info boxes.size
        boxes.each{ |b|
          @box_hash = {}
          @box_hash['id'] = b.id
          @box_hash['name'] = b.name 
          @box_hash['locker_id'] = b.locker_id
          @box_hash['locker_name'] = b.locker.name
          @box_hash['branch_name'] = b.branch.full_name
          if b.status == @constant['BOX_RETURNED']
            @box_hash['backup'] = true
          elsif b.status == @constant['BOX_IDLE']
            @box_hash['backup'] = false
          end
          @box_hash['print_size'] = b.print_size
          @boxes_array.push @box_hash
        }
        format.json { render json: { :status => 'success', :result => @boxes_array} } 
      else
        format.json{ render json: { :status => 'error'} }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_package
      @package = Package.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def package_params
      params.require(:package).permit(:user_id, :locker_id, :status, :size, :preferred_branch_id)
    end
end
