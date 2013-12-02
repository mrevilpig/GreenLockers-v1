class Locker < ActiveRecord::Base
  belongs_to :branch
  has_many :boxes
  has_many :packages, :through => :boxes
  
  # Create associated boxes after creating the locker
  def init_locker
    box_params = {}
    box_params[:locker_id] = self.id
    16.times do |i|
      box_params[:name] = 'A'+(i+1).to_s
      box_params[:size] = 1;
      box_params[:status] = 0;
      b = Box.new(box_params)
      if b.save
        b.init_box
      end
    end
    8.times do |i|
      box_params[:name] = 'B'+(i+1).to_s
      box_params[:size] = 2;
      box_params[:status] = 0;
      b = Box.new(box_params)
      if b.save
        b.init_box
      end
    end
    4.times do |i|
      box_params[:name] = 'C'+(i+1).to_s
      box_params[:size] = 3;
      box_params[:status] = 0;
      b = Box.new(box_params)
      if b.save
        b.init_box
      end
    end
  end
  
end
