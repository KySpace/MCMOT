classdef FieldSettings
    properties
        type            {mustBeMember(type, ["magnetic" "coolings" "gravity" "none"])} = "none"
        info            struct = struct()
        units           = [] % CurrUnit or BeamUnit
    end
end