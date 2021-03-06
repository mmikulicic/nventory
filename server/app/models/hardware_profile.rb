class HardwareProfile < ActiveRecord::Base
  
  acts_as_paranoid
  acts_as_commentable
  
  has_many :nodes
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  validates_numericality_of :rack_size,               :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :processor_socket_count,  :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :processor_count,         :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :outlet_count,            :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :estimated_cost,          :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :power_supply_slot_count, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :power_supply_count,      :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :power_consumption,       :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :nics,                    :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true

  OUTLET_TYPES = ['','Power','Network','Console']
  def self.allowed_outlet_types
    return OUTLET_TYPES
  end
  
  # If an outlet type has been specified make sure it is one of the
  # allowed types
  validates_inclusion_of :outlet_type,
                         :in => OUTLET_TYPES,
                         :allow_nil => true,
                         :message => "not one of the allowed outlet " +
                            "types: #{OUTLET_TYPES.join(',')}"

  def self.default_search_attribute
    'name'
  end
 
end
