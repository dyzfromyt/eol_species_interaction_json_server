class Organism
    include DataMapper::Resource
    property :id, Serial
    property :com_name, String
    property :sci_name, String
    property :eol_id, Integer
    property :rank, String
    property :group, String
    property :media_url, Text
    property :tax_class, String
    property :tax_order, String
    property :tax_super_family, String
    property :tax_family, String
    property :tax_sub_family, String
    property :tax_tribe, String
    property :tax_genus, String
    property :tax_species, String
    property :tax_sub_species, String
    property :state,  Enum[
        :confirmed,        # 1
        :added,            # 2
        :under_review,     # 3
        :rejected,         # 4
    ], :default => :added, :index => true
end
