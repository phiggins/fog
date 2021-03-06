module Fog
  module Parsers
    module AWS
      module CloudFormation

        class ValidateTemplate < Fog::Parsers::Base

          def end_element(name)
            case name
            when 'TemplateParameter', 'Description'
              @response[name] = @value
            end
          end

        end
      end
    end
  end
end
