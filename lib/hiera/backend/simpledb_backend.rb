# Class Simpledb_backend
# Description: AWS SimpleDB back end to Hiera.
# Author: Nathan Butler <nathan.butler@newsweekdailybeast.com>
# 
class Hiera
  module Backend
    class Simpledb_backend
      def initialize
        begin
          require 'aws-sdk'
        rescue LoadError
          require 'rubygems'
          require 'aws-sdk'
        end

        config = Hash.new
        config['access_key_id'] = Config[:simpledb][:access_key_id]
        config['secret_access_key'] = Config[:simpledb][:secret_access_key]

        AWS.config(config)
        @sdb = AWS::SimpleDB.new
        
        Hiera.debug("SimpleDB_backend initialized")
      end

      def lookup(key, scope, order_override, resolution_type)
        answer = Backend.empty_answer(resolution_type)
        query = Backend.parse_string(Config[:simpledb][:query], scope, { "key" => key })

        Hiera.debug("Looking up \"#{key}\" in SimpleDB Backend")
        Hiera.debug("Resolution_type: #{resolution_type}")

        # Search list of domains specified in the hierarchy section in hiera.yaml
        Backend.datasources(scope, order_override) do |source|
          Hiera.debug("Looking for simpledb domain #{source}")

          begin
            results = @sdb.domains[source].items[key].data.attributes
          rescue AWS::SimpleDB::Errors::NoSuchDomain
            Hiera.debug("Cannot find domain #{source}, skipping")
            next
          end

          Hiera.debug("Results  => #{results.inspect}")

          next if results.empty?

          # for array resolution we just append to the array whatever
          # we find, we then go onto the next file and keep adding to
          # the array
          #
          # for priority searches we break after the first found data item
          case resolution_type
            when :array
              results.each do |ritem|
                answer << Backend.parse_answer(ritem, scope)
              end
            else
              answer = Backend.parse_answer(results, scope)
              break
          end
        end
        Hiera.debug("Answer   => #{answer.inspect}")
        return answer
      end

      def domains(scope, override=nil, domains=nil)
        if domains 
          domains = [domains]
        elsif Config[:simpledb].include?(:domains)
          domains = [Config[:simpledb][:domains]].flatten
        else
          domains = ["hiera"]
        end

        domains.flatten.map do |source|
          source = Backend.parse_string(source, scope)
          yield(source) unless source == ""
        end
      end
    end
  end
end
