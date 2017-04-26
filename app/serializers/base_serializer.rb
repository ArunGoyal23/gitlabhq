class BaseSerializer  
  attr_reader :request

  def initialize(parameters = {})
    @request = EntityRequest.new(parameters)
  end

  def represent(resource, opts = {})
    self.class.entity_class
      .represent(resource, opts.merge(request: @request))
      .as_json
  end

  def self.entity(entity_class)
    @entity_class ||= entity_class
  end

  def self.entity_class
    @entity_class
  end
end
