-- Copyright (c) 2016 Kim Alvefur
-- 
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--

local http = require "socket.http";

local function verify(account, host, token)
	local url = ("http://%s/.well-known/acme-challenge/%s"):format(host, token);
	local data = http.request(url);
	return data == account.get_key_authz(token);
end

local function describe(account, host, token)
	print(("echo -n %q > /var/www/%s/%s"):format(account.get_key_authz(token), host, token));
end

return {
	verify = verify,
	describe = describe,
}
