require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = route_params
    
    if req.query_string
      nested_hash = parse_www_encoded_form(req.query_string)
      @params.merge!(nested_hash)
    end

    if req.body
      post_body = parse_www_encoded_form(req.body)
      @params.merge!(post_body)
    end

      # @params.merge!(parse_www_encoded_form(req.body))
    # req.query_string.merge(req.body).merge(route_params)
    

      # @params.merge!(parse_www_encoded_form(req.body))

  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
  end

  def require(key)
  end

  def permitted?(key)
  end

  def to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # "user[address][street]=main&user[address][zip]=89436"
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    # decoded = URI::decode_www_form(www_encoded_form)
    # p www
    pair_strings = www_encoded_form.split('&')

    out = {}

    pair_strings.each do |pair_string|
      key, value = pair_string.split('=')
      key_array = parse_key(key)

      hash_we_are_at = out
      key_array[0...-1].each do |key_thing|
        unless hash_we_are_at.include? key_thing
          hash_we_are_at[key_thing] = {}
        end
        hash_we_are_at = hash_we_are_at[key_thing]
      end
      hash_we_are_at[key_array.last] = value
    end

    out

  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.to_s.split("[").map {|component|component.gsub(/]/,"")}
  end
end
