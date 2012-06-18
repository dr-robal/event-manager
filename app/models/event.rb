class Event < ActiveRecord::Base  
  attr_accessible :description, :end_time, :facebookID, :location, :name, :participants_declared, :participants_maybe, :participants_present, :picture, :privacy_type, :start_time, :status

  validates :name, :presence => true
  
  validates :start_time, :presence => true
  
  validates :status, :inclusion => { :in => [true, false] }
    
  validates :participants_declared, :numericality => true, :allow_blank => true
  validates :participants_maybe, :numericality => true, :allow_blank => true
  validates :participants_present, :numericality => true, :allow_blank => true
  
  #enum type simulation
  def self.privacy_type_list
    { 'Open'=> 'OPEN','Closed'=>'CLOSED', 'Secret' => 'SECRET' }
  end
  
  validate :date_present, :on => :create
  validate :valid_dates

  def valid_dates
    self.errors.add :end_time, ' cannot be before start time' if self.end_time && self.start_time >= self.end_time
  end
  def date_present
    self.errors.add :end_time, ' cannot be in the past' if self.end_time && self.end_time <= Time.now
  end
  

end
