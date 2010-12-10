class EcoToTax
    include DataMapper::Resource
    storage_names[:default] = 'bridge_eco'

    property :id, Serial
    property :id_eco, Integer
    property :id_tax, Integer

    belongs_to :eco, :model => 'Ecosystem', :child_key => [ :id_eco ]
    belongs_to :tax, :model => 'Organism', :child_key => [ :id_tax ]
end
