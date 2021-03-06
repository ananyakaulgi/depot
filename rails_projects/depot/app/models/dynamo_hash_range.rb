#
# Base class for hash & range key table
#

class DynamoHashRange < DynamoDB
    
    include ActiveModel::Conversion   # to_key, to_model, to_param
    
    def to_key
        @attributes[hash_key]
    end
    
    def self.query(opts)
    results = []
    items = table.items.query(opts)
    items.each do |item|
    results << new(item.attributes.to_h)
end
results
end

def self.find(hkey, rkey)
# either symbol or string works
# return item, which has attributes that include keys
item = table.items[hkey, rkey]
if item.exists?
    new(item.attributes.to_h)   # create object
    else
    nil
end
end

# only existing item can be updated
# return true or false
def update_attributes(attrs={})
    attrs.each do |k, v|
        k = k.to_s if k.kind_of? Symbol
        @attributes[k] = v
    end
    
    # return false if self.invalid?
    if exists?
        @item.attributes.update do |u|
            @attributes.each do |k, v|
                # DynamoDB does not allow nil or empty string!
                if v.nil? || v.blank?
                    u.delete(k)
                    elsif k != hash_key && k != range_key
                    u.set(k => v)
                end
            end
            @attributes.delete_if { |k, v| v.blank? }
        end
        true
        else
        false
    end
end

def exists?
    if !@attributes[hash_key].nil? && !@attributes[range_key].nil?
        @item = table.items[@attributes[hash_key], @attributes[range_key]]
        @item.exists?
        else
        false
    end
end

private 


end