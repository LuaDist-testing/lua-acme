local cjson = require "cjson.safe";

local function loaddata(filename)
	local f, err = io.open(filename);
	if not f then return f, err; end
	local data = f:read("*a");
	f:close();
	return data, err;
end

local function savedata(filename, data)
	local scratch, ok = filename.."~";
	local f, err = io.open(scratch, "w");
	if not f then return nil, err; end
	ok, err = f:write(data);
	if ok then ok, err = f:flush(); end
	if not ok then
		f:close();
		os.remove(scratch);
		return ok, err;
	end
	ok, err = f:close();
	if not ok then
		os.remove(scratch);
		return ok, err;
	end
	return os.rename(scratch, filename);
end

local function loadjson(filename)
	local data, err = loaddata(filename);
	if data then
		data, err = cjson.decode(data);
	end
	return data, err;
end

local function savejson(filename, data)
	local bytes, err = cjson.encode(data);
	if not bytes then return bytes, err; end
	return savedata(filename, bytes);
end

return {
	load = loaddata;
	save = savedata;

	loadjson = loadjson;
	savejson = savejson;
}
