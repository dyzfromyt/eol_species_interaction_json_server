namespace :setup do
    task :env do
        require 'boot/init'
    end
end

namespace :setup do
    namespace :db do
        desc "Autoupgrade all models (leaves data in place)."
        task(:models => 'setup:env') do
            next unless defined? ::DataMapper
            ::DataMapper.auto_upgrade!
        end
    end
end
require 'rubygems'
require 'restclient'
def http_get(url, force_refresh = false)
    defeat_cache = ''
    if force_refresh
        if url.include?("?")
            defeat_cache = "&"
        else
            defeat_cache = "?"
        end
        defeat_cache = defeat_cache + "randid="+Time.now.to_i.to_s
    end

    rsp = ''
    begin
#puts url
        rsp=RestClient.get(url + defeat_cache)
#rsp=RestClient.get(url + defeat_cache, {'Content-Type'=>'application/json', 'Accept'=>'application/json'})
        #pp rsp.headers
    rescue Exception => e
        puts "Get Failed: for #{url}"
        puts e.inspect
        puts e.response.to_s
        return nil
    end
    return rsp
end

rank_to_colname = {}
rank_to_colname["class"]="tax_class"
rank_to_colname["order"]="tax_order"
rank_to_colname["superfamily"]="tax_super_family"
rank_to_colname["family"]="tax_family"
rank_to_colname["subfamily"]="tax_sub_family"
rank_to_colname["tribe"]="tax_tribe"
rank_to_colname["genus"]="tax_genus"
rank_to_colname["species"]="tax_species"
rank_to_colname["subspecies"]="tax_sub_species"


rank_to_colname2 = {}
rank_to_colname2["Class"]="tax_class"
rank_to_colname2["Order"]="tax_order"
rank_to_colname2["Super-family"]="tax_super_family"
rank_to_colname2["Family"]="tax_family"
rank_to_colname2["Genus"]="tax_genus"
rank_to_colname2["species"]="tax_species"
rank_to_colname2["sub-species"]="tax_sub_species"


namespace :batch do
    desc "dump eol database"
    task :backup_db do
        cmd = "mysqldump -uroot eol --add-drop-table  > eol.`date +%Y%m%d%H%M`.sql "
        system(cmd)
    end
    desc "fill rank info into hierarchy info"
    task(:fill_rank_hierarchy => 'setup:env') do
        Organism.all().each do | org |
            if rank_to_colname2[org.rank]
                colname = rank_to_colname2[org.rank]
                org.send(colname + '=', org.sci_name)
                org.save
            end
        end

    end

    namespace :organism do
        desc "Populate all organism table with taxonomy hierarchy data."
        task(:get_taxonomy => 'setup:env') do
            require 'uri'
            require 'pp'
            Organism.all().each do | org |
                sci_name = org.sci_name
                sci_name_uri = URI.escape(sci_name)
                species_json = http_get("http://www.eol.org/api/search/1.0/#{sci_name_uri}.json?exact=1");
                next unless species_json
                species_data = JSON.parse(species_json)
                next if species_data["results"].length == 0
                eol_id = species_data["results"][0]["id"]
                details_url="http://www.eol.org/api/pages/1.0/#{eol_id}.json?common_names=1&details=1&vetted=1&subjects=all&text=1"
                details_json = http_get(details_url)
                next unless details_json
                details_data = JSON.parse(details_json)
                next if details_data["taxonConcepts"].length == 0
                taxon_id = details_data["taxonConcepts"][0]["identifier"]
                data_object = details_data["dataObjects"]
                if data_object && data_object[0]
                    org.media_url = data_object[0]["mediaURL"]
                end

                taxon_url = "http://www.eol.org/api/hierarchy_entries/1.0/#{taxon_id}.json"
                taxon_json = http_get(taxon_url)
                next unless taxon_json
                taxon_data = JSON.parse(taxon_json)
                taxon_data["ancestors"].each do |anc|
                    rank = anc["taxonRank"]
                    rank_name = anc["scientificName"]
                    colname = rank_to_colname[rank]
                    next unless colname
                    org.send(colname + '=', rank_name)
                end
                org.eol_id = eol_id
                org.save!

                puts "#{sci_name} #{eol_id}"
            end
        end
    end
end

