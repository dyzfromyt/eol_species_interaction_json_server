class Interaction
    include DataMapper::Resource
    property :id, Serial
    property :category, String
    property :title, String
end
