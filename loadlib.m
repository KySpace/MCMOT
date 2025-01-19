fprintf("loading: MCMOT.\n")

if ~contains(path, "UltracoldCommons"); run("[UltracoldCommons]/loadlib"); end
if ~contains(path, "MatlabFunctional"); run("[MatlabFunctional]/loadlib"); end
if ~contains(path, "VisualHelpers"); run("[VisualHelpers]/loadlib"); end
if ~contains(path, "TestRunner"); run("[TestRunner]/loadlib"); end

rootpath = fileparts(mfilename("fullpath"));
srcfolders = ["dynamics", "fields", "init", "main", "visual", "statistics", "vectors", "tests", "flowtests"];
for i = 1 : numel(srcfolders)
    addpath(genpath(rootpath+"\"+srcfolders(i)));
end

phys = PhysicsConstants;
csd2 = Cs133D2Constants;