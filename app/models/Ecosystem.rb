class Ecosystem
    include DataMapper::Resource
    property :id, Serial
    property :description, Text
    property :name, String
end

