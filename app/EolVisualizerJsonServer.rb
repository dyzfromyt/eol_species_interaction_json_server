#!/usr/bin/env ruby
require "set"

class EolVisualizerJsonServer < Sinatra::Application
    def initialize
        @rank_to_colname = {}
        @rank_to_colname["class"]="tax_class"
        @rank_to_colname["order"]="tax_order"
        @rank_to_colname["superfamily"]="tax_super_family"
        @rank_to_colname["family"]="tax_family"
        @rank_to_colname["subfamily"]="tax_sub_family"
        @rank_to_colname["tribe"]="tax_tribe"
        @rank_to_colname["genus"]="tax_genus"
        @rank_to_colname["species"]="tax_species"
        @rank_to_colname["subspecies"]="tax_sub_species"

        super
    end
    get '/add_species/' do
        result = {}
        result["status"] = "success"
        sci_name = request["sci_name"]
        com_name = request["com_name"]
        rank = request["rank"]
        group = request["group"]

        if sci_name.nil? || sci_name.length == 0
            result["status"] = "failed"
            result["reason"] = "Scientific name must not be empty"
            return  handle_xd(result)
        end
        if rank.nil? || rank.length == 0
            result["status"] = "failed"
            result["reason"] = "rank must not be empty"
            return  handle_xd(result)
        end
        if group.nil? || rank.length == 0
            group = 6
        end


        existing_org = Organism.first(:sci_name => sci_name)
        if existing_org
            result["status"] = "failed"
            result["reason"] = "Scientific name #{sci_name} already exists in database"
            return  handle_xd(result)
        end

        com_name ||= ""
        new_org = Organism.create({
            :sci_name => sci_name,
            :com_name => com_name,
            :rank => rank,
            :state => :added,
            :group => group.to_i,
        })
        unless new_org.save
            result["status"] = "failed"
            result["reason"] = "database access error"
            return  handle_xd(result)
        end
        return handle_xd(result)
    end

    get '/add_ecosystem/' do
        result = {}
        result["status"] = "success"
        eco_name = request["eco_name"]
        eco_desc = request["eco_desc"]

        entity_type = "Ecosystem"
        if eco_name.nil? || eco_name.length == 0
            result["status"] = "failed"
            result["reason"] = "#{entity_type} name must not be empty"
            return  handle_xd(result)
        end

        eco_desc ||= ""

        existing_entry = Ecosystem.first(:name => eco_name)
        if existing_entry
            result["status"] = "failed"
            result["reason"] = "#{entity_type} name #{eco_name} already exists in database"
            return  handle_xd(result)
        end

        new_entry = Ecosystem.create({
            :name => eco_name,
            :description => eco_desc,
        })
        unless new_entry.save
            result["status"] = "failed"
            result["reason"] = "database access error"
            return  handle_xd(result)
        end
        return handle_xd(result)
    end

    get '/add_interaction/' do
        result = {}
        result["status"] = "success"
        title = request["title"]
        category = request["category"]

        entity_type = "Interaction"
        if title.nil? || title.length == 0
            result["status"] = "failed"
            result["reason"] = "#{entity_type} title must not be empty"
            return  handle_xd(result)
        end

        category ||= ""

        existing_entry = Interaction.first(:title => title)
        if existing_entry
            result["status"] = "failed"
            result["reason"] = "#{entity_type} title #{title} already exists in database"
            return  handle_xd(result)
        end

        new_entry = Interaction.create({
            :title => title,
            :category => category,
        })
        unless new_entry.save
            result["status"] = "failed"
            result["reason"] = "database access error"
            return  handle_xd(result)
        end
        return handle_xd(result)
    end

    get '/add_species_in_ecosystem/' do
        result = {}
        result["status"] = "failed"
        species = request["species"]
        ecosystem = request["ecosystem"]

        if species.nil? || species.length == 0
            result["reason"] = "Species name must not be empty"
            return  handle_xd(result)
        end
        sp = find_organism_exact(species)
        unless sp
            result["reason"] = "Species #{species} does not exists"
            return  handle_xd(result)
        end

        if ecosystem.nil? || ecosystem.length == 0
            result["reason"] = "Ecosystem must not be empty"
            return  handle_xd(result)
        end

        eco = Ecosystem.first(:name => ecosystem)
        unless eco
            result["reason"] = "Ecosystem #{ecosystem} does not exists"
            return  handle_xd(result)
        end

        existing_entry = EcoToTax.first({:id_eco => eco.id, :id_tax => sp.id})
        if existing_entry
            result["reason"] = "#{species} is already in #{ecosystem}"
            return  handle_xd(result)
        end

        new_entry = EcoToTax.create({
            :id_eco => eco.id,
            :id_tax => sp.id,
        })
        unless new_entry.save
            result["reason"] = "database access error"
            return  handle_xd(result)
        end

        result["status"] = "success"
        return handle_xd(result)
    end

    get '/add_species_interaction/' do
        result = {}
        result["status"] = "failed"
        species1 = request["species1"]
        species2 = request["species2"]
        interaction = request["interaction"]

        if species1.nil? || species1.length == 0
            result["reason"] = "Species name must not be empty"
            return  handle_xd(result)
        end
        if species2.nil? || species2.length == 0
            result["reason"] = "Species name must not be empty"
            return  handle_xd(result)
        end
        sp1 = find_organism_exact(species1)
        unless sp1
            result["reason"] = "Species #{species1} does not exists"
            return  handle_xd(result)
        end

        sp2 = find_organism_exact(species2)
        unless sp2
            result["reason"] = "Species #{species2} does not exists"
            return  handle_xd(result)
        end

        if interaction.nil? || interaction.length == 0
            result["reason"] = "Interaction must not be empty"
            return  handle_xd(result)
        end

        inter = Interaction.first(:title => interaction)
        unless inter
            result["reason"] = "Interaction #{interaction} does not exists"
            return  handle_xd(result)
        end

        existing_entry = Observation.first({:sp1_id => sp1.id, :sp2_id => sp2.id, :inter_id => inter.id})
        if existing_entry
            result["reason"] = "Interaction already exists"
            return  handle_xd(result)
        end

        new_entry = Observation.create({
            :sp1_id => sp1.id,
            :sp2_id => sp2.id,
            :inter_id => inter.id,
        })
        unless new_entry.save
            result["reason"] = "database access error"
            return  handle_xd(result)
        end

        result["status"] = "success"
        return handle_xd(result)
    end

    get '/search_by_id/observation/:id' do |id|
        return handle_xd(Observation.get(id))
    end
    get '/search_by_id/interaction/:id' do |id|
        return handle_xd(Interaction.get(id))
    end
    get '/search_by_id/organism/:id' do |id|
        return handle_xd(Organism.get(id))
    end

    get '/observation/' do
        return handle_xd(Observation.all())
    end
    get '/interaction/' do
        return handle_xd(Interaction.all())
    end
    get '/interaction_title_list/' do
        result = []
        Interaction.all().each do | inter |
            result << inter.title
        end
        response = handle_xd(result)
        return response
    end

    get '/organism/' do
        return handle_xd(Organism.all())
    end

    get '/ecosystem_list/' do
        result = []
        Ecosystem.all().each do | eco |
            result << eco.name
        end
        response = handle_xd(result)
        return response
    end

    get '/organism_list/' do
        result = Set.new
        Organism.all().each do | eco |
            result << eco.sci_name
            result << eco.com_name
        end
        response = handle_xd(result.to_a)
        return response
    end

    get '/interaction_category_list/' do
        result = Set.new
        Interaction.all().each do | entry |
            result << entry.category
        end
        response = handle_xd(result.to_a)
        return response
    end

    def find_organism_exact(name)
        result = Organism.first(:sci_name => name)
        unless result
            result = Organism.first(:com_name => name)
        end
        return result
    end

    get '/search_by_name/organism/:name' do |name|
        puts "#{name}"
        puts  "%#{name}%"
        results = Organism.all(:com_name.like => "%#{name}%")
        if results.length == 0
            puts "try sci name"
            results = Organism.all(:sci_name.like => "%#{name}%")
        end
        return handle_xd(results)
    end

    get '/search_by_name/organism_name_only/:name' do |name|
        puts "#{name}"
        puts  "%#{name}%"
        results = Organism.all(:com_name.like => "%#{name}%")
        if results.length == 0
            puts "try sci name"
            results = Organism.all(:sci_name.like => "%#{name}%")
        end
        species_names = []
        results.each do | entry |
            species_names << entry.sci_name
        end
        return handle_xd(species_names)
    end


    def self.sanitize_jsonp_param(s)
        return nil unless s
        #return nil if ( !StringUtils.startsWithIgnoreCase(s,"jsonp"))
        return nil if s.length > 128
        return s;
    end

    def handle_xd(result)
        #jsonString = JSON.pretty_generate(result)
        jsonString = result.to_json.to_s

        jsonCallbackParam = request["callback"]
        if jsonCallbackParam
            puts "jsonCallbackParam #{jsonCallbackParam}"
            response = jsonCallbackParam + "(" + jsonString + ");";
            content_type 'application/x-javascript', :charset => 'utf-8'
        else
            response = jsonString;
            content_type 'text/json', :charset => 'utf-8'
        end
        return response
    end

    def format_new_node(org_node, id_column, rank_resolution, formatted_nodes, species_id_to_node_id)
        sp_id = org_node.id
        if id_column
            sp_id = org_node.send(id_column)
        end

        unless sp_id
            # has no rank information
            return nil
        end

        if species_id_to_node_id.has_key?(sp_id)
            node_id = species_id_to_node_id[sp_id]
            if rank_resolution
                if org_node.rank.downcase == rank_resolution.downcase
                    # most specific fit
                    # maybe update node info in the future
                end
            end
            return node_id
        else
            new_node = {}
            if id_column
                new_node["nodeName"] = sp_id
                new_node["rankName"] = rank_resolution
                new_node["sci_name"] = sp_id
                new_node["com_name"] = sp_id
                new_node["group"] = org_node.group
            else
                new_node["nodeName"] = org_node.sci_name
                new_node["rankName"] = org_node.rank
                new_node["sci_name"] = org_node.sci_name
                new_node["com_name"] = org_node.com_name
                new_node["group"] = org_node.group
            end
            new_node_id =  formatted_nodes.length
            species_id_to_node_id[sp_id] = new_node_id
            formatted_nodes << new_node
            return new_node_id
        end
    end

    def format_observations(obss, id_column, rank_resolution)
        result = {}

        links = []
        nodes = []
        species_id_to_node_id = {}
        formatted_nodes = []

        obss.each do |obs|
            sp1_id = obs.sp1.id
            sp1_id = obs.sp1.send(id_column) if id_column
            sp2_id = obs.sp2.id
            sp2_id = obs.sp2.send(id_column) if id_column

            # skip if any of the organism is missing
            next unless sp1_id
            next unless sp2_id

            node_id1 = format_new_node(obs.sp1, id_column, rank_resolution, formatted_nodes, species_id_to_node_id)
            node_id2 = format_new_node(obs.sp2, id_column, rank_resolution, formatted_nodes, species_id_to_node_id)

            new_link = {}
            new_link["source"] = node_id1
            new_link["target"] = node_id2
            new_link["value"] = 1
            links << new_link
        end

        result["nodes"] = formatted_nodes
        result["links"] = links
        return result
    end

    def strip_params(input)
        result = input
        if input.include?("?")
            index = input.index("?")
            result = input[0, index]
        end
        return result
    end

    get '/search_by_interaction_ecosystem_species/:interaction/:ecosystem/:species' do | interaction, ecosystem, species |
        return search_func(interaction, ecosystem, species)
    end
    get '/search_by_interaction_ecosystem/:interaction/:ecosystem' do | interaction, ecosystem |
        return search_func(interaction, ecosystem, "no such species")
    end

    def search_func(interaction, ecosystem, species_name)
        interaction = strip_params(interaction)
        ecosystem = strip_params(ecosystem)
        puts "interaction: #{interaction}"
        puts "ecosystem  : #{ecosystem}"
        puts "species_name: #{species_name}"

        title = ""
        search_condition = {}
        inter = Interaction.first(:title => "#{interaction}")
        if inter
            puts "limit to interaction  : #{interaction}"
            search_condition[:inter_id] = inter.id
            title = title + "Interaction \""  + inter.title + "\""
        end
        eco = Ecosystem.first(:name=> "#{ecosystem}")
        if eco
            puts "limit to ecosystem  : #{ecosystem}"
            species = EcoToTax.all(:id_eco => eco.id)
            species_id = []
            species.each do |s|
                species_id << s.id
            end

            search_condition[:sp1_id] = species_id
            search_condition[:sp2_id] = species_id

            title = title + " in " + eco.name
        end


        sp = find_organism_exact(species_name)

        viz_resolution = request["vizResolution"]
        if viz_resolution == "everything"
            viz_resolution = nil
        end

        id_column = nil
        if viz_resolution && @rank_to_colname[viz_resolution]
            id_column = @rank_to_colname[viz_resolution]
        end

        numDegreeToShow = request["numDegreeToShow"]
        numDegreeToShow ||= 1
        if numDegreeToShow == "inf"
            numDegreeToShow = 100
        else
            numDegreeToShow = numDegreeToShow.to_i
        end

        obss = nil
        if sp
            obss_id_set = Set.new
            seed_set = Set.new
            known_set = Set.new
            seed_set << sp.id
            known_set << sp.id
            obss = []

            numDegreeToShow.times do
                break if seed_set.length == 0
                search_condition1 = search_condition.dup
                search_condition1[:sp1_id] = seed_set.to_a
                obss1 = Observation.all(search_condition1)

                search_condition2 = search_condition.dup
                search_condition2[:sp2_id] = seed_set.to_a
                obss2 = Observation.all(search_condition2)

                puts "obss1: size #{obss1.length}"
                puts "obss2: size #{obss2.length}"

                new_sp_set = Set.new
                obss1.each do | entry |
                    obss_id_set << entry.id
                    new_sp_set << entry.sp1_id
                    new_sp_set << entry.sp2_id
                end
                obss2.each do | entry |
                    obss_id_set << entry.id
                    new_sp_set << entry.sp1_id
                    new_sp_set << entry.sp2_id
                end
                seed_set = new_sp_set - known_set
                known_set = new_sp_set
            end
            search_condition[:id] = obss_id_set.to_a
            obss = Observation.all(search_condition)
        else
            obss = Observation.all(search_condition)
        end

        result = format_observations(obss, id_column, viz_resolution)
        result["title"] = title
        #jsonString = result.to_json.to_s
        response = handle_xd(result)
        return response
    end

    get '/node_link/:interaction' do |interaction|
        interaction = strip_params(interaction)
        puts "#{interaction}"
        inter = Interaction.first(:title => "#{interaction}")
        unless inter
            return "error, no such interaction: #{interaction}"
        end

        obss = Observation.all(:inter_id => inter.id)
        result = format_observations(obss)
        #jsonString = result.to_json.to_s
        response = handle_xd(result)
        return response
    end
end



