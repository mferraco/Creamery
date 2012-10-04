class Store < ActiveRecord::Base
  # Callbacks
  before_save :reformat_phone
  
  # Relationships
  has_many :assignments, :dependent => :destroy
  has_many :employees, :through => :assignments
  has_many :shifts, :through => :assignments, :dependent => :destroy
  
  
  # Validations
  # make sure required fields are present
  validates_presence_of :name, :street, :city
  # if state is given, must be one of the choices given (no hacking this field)
  validates_inclusion_of :state, :in => %w[PA OH WV], :message => "is not an option"
  # if zip included, it must be 5 digits only
  validates_format_of :zip, :with => /^\d{5}$/, :message => "should be five digits long"
  # phone can have dashes, spaces, dots and parens, but must be 10 digits
  validates_format_of :phone, :with => /^\(?\d{3}\)?[-. ]?\d{3}[-.]?\d{4}$/, :message => "should be 10 digits (area code needed) and delimited with dashes only"
  # make sure stores have unique names
  validates_uniqueness_of :name
  
  # Scopes
  scope :alphabetical, order('name')
  scope :active, where('active = ?', true)
  scope :inactive, where('active = ?', false)
  
  
  # Misc Constants
  STATES_LIST = [['Ohio', 'OH'],['Pennsylvania', 'PA'],['West Virginia', 'WV']]

  
  # Callback code
  # -----------------------------
  before_create :find_store_coordinates
  
  # Create a map
  def create_map_link(zoom=15, width =800, height=450)
    marker = "&markers=color:red%7Ccolor:red%7Clabel:%7C#{self.latitude},#{self.longitude}"
    map = "http://maps.google.com/maps/api/staticmap?center=#{self.latitude},#{self.longitude}&zoom=#{zoom}&size=#{width}x#{height}&maptype=roadmap#{marker}&sensor=false"
  end
  
  private
  # We need to strip non-digits before saving to db
  def reformat_phone
    phone = self.phone.to_s  # change to string in case input as all numbers 
    phone.gsub!(/[^0-9]/,"") # strip all non-digits
    self.phone = phone       # reset self.phone to new string
  end
  
  def find_store_coordinates
    coord = Geokit::Geocoders::GoogleGeocoder.geocode "#{street}, #{zip}"
    if coord.success
      self.latitude, self.longitude = coord.ll.split(',')
    end
  end
  

end
