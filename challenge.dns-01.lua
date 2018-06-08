-- Copyright (c) 2016 Kim Alvefur
-- 
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--

local digest = require "openssl.digest";
local b64url = require "b64url".encode;

local function preptoken(account, token)
	local key_authz = account.get_key_authz(token);
	local hash = digest.new("sha256");
	hash:update(key_authz);
	local txtcontent = b64url(hash:final());
	return txtcontent;
end

local function verify(account, name, token)
	local txtcontent = preptoken(account, token);
	local dig = assert(io.popen("/usr/bin/dig +short txt _acme-challenge." .. name));
	for line in dig:lines() do
		if line:gsub("[^-_a-zA-Z0-9]", "") == txtcontent then
			return true;
		end
	end
	return false;
end

local function describe(account, name, token)
	local txtcontent = preptoken(account, token);
	print("$ORIGIN "..name);
	print(("_acme-challenge IN TXT %q"):format(txtcontent));
end

return {
	verify = verify;
	describe = describe;
	getcontent = preptoken;
}
