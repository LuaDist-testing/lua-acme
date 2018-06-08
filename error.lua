
local json = require "cjson.safe";

local err_mt = {}
function err_mt:__tostring()
	return ("%d{%s}%s"):format(self.status or -1, self.type, self.detail or "");
end

local function parse_error(err)
	local jerr = json.decode(err);
	if jerr then
		return setmetatable(jerr, err_mt);
	end
	return err;
end

return {
	parse = parse_error;
}
