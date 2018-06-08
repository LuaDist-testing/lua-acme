local pkey = require "openssl.pkey";
local json = require "cjson.safe";
local jws = require "jws";
local jwk = require "jwk";
local parse_error = require "acme.error".parse;

local function new(account_key, directory_url, https_request)
	if account_key == nil then
		account_key = pkey.new();
	elseif type(account_key) == "string" then
		local ok, key = pcall(pkey.new, account_key);
		if not ok then return ok, key; end
		account_key = key;
	end
	if not directory_url then
		directory_url = "https://acme-staging.api.letsencrypt.org/directory";
	end
	if not https_request then
		https_request = require "ssl.https".request;
	end

	local nonces = {
		pop = table.remove;
		push = table.insert;
	};

	local function decode(type, data)
		if type == "application/json" or (type and type:find"%+json") then
			return json.decode(data);
		end
		return data;
	end

	local function request(url, post_body)
		-- print("request", url, post_body)
		local response_body, code, headers, status = https_request(url, post_body);
		if code - (code % 100) ~= 200 then
			-- print(response_body);
			return nil, parse_error(response_body);
		end
		if headers["replay-nonce"] then
			nonces:push(1, headers["replay-nonce"]);
		end
		return {
			url = url;
			code = code;
			status = status;
			head = headers;
			body = decode(headers["content-type"], response_body);
		};
	end

	local directory;

	local function fetch_directory()
		directory = assert(request(directory_url).body);
		return directory;
	end

	local function get_directory()
		return directory or fetch_directory();
	end

	local function signed_request(url, obj)
		while not nonces[1] do
			fetch_directory(); -- need more nonces
		end
		return request(url, jws.sign(account_key, { nonce = nonces:pop() }, obj));
	end

	local function step(obj, url)
		if not url then
			if not directory then
				fetch_directory();
			end
			url = url or directory[obj.resource];
		end
		return signed_request(url, obj);
	end

	local function register(...)
		return step({ resource = "new-reg", contact = { ... }});
	end

	local function get_key_authz(token)
		return token .. "." .. jwk.thumbprint(account_key);
	end

	local function new_authz(identifier)
		return step({ resource = "new-authz", identifier = identifier });
	end

	local function new_dns_authz(name)
		return new_authz({ type = "dns", value = name });
	end

	local function poll_challenge(challenge)
		return step({
			resource = "challenge",
			type = challenge.type,
			keyAuthorization = get_key_authz(challenge.token);
		}, challenge.uri);
	end

	return {
		account_key = account_key;
		directory_url = directory_url;

		nonces = nonces;

		signed_request = signed_request;
		unsigned_request = request;
		get_key_authz = get_key_authz;
		get_directory = get_directory;
		step = step;

		register = register;
		new_authz = new_authz;

		new_dns_authz = new_dns_authz;
		poll_challenge = poll_challenge;
	};
end

return {
	new = new;
};
