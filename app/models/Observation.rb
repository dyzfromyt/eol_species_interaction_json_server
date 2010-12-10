class Observation
    include DataMapper::Resource
    property :id, Serial
    property :sp1_id, Integer
    property :sp2_id, Integer
    property :inter_id, Integer

    belongs_to :sp1, :model => 'Organism', :child_key => [ :sp1_id ]
    belongs_to :sp2, :model => 'Organism', :child_key => [ :sp2_id ]
    belongs_to :interaction, :model => 'Interaction', :child_key => [ :inter_id ]
end
