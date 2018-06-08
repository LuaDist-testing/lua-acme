-- This file was automatically generated for the LuaDist project.

package = "lua-acme"
version = "0.5-1"
-- LuaDist source
source = {
  tag = "0.5-1",
  url = "git://github.com/LuaDist-testing/lua-acme.git"
}
-- Original source
-- source = {
-- 	url = "hg+http://code.zash.se/lua-acme",
-- 	tag = "0.5"
-- }
description = {
	homepage = "http://code.zash.se/lua-acme",
	license = "MIT"
}
dependencies = {
	"lua-jwc",
	"luasocket",
	"luaossl",
	"lua-cjson",
}
build = {
	type = "builtin",
	modules = {
		["acme.account"] = "account.lua",
		["acme.challenge.http-01"] = "challenge.http-01.lua",
		["acme.challenge.dns-01"] = "challenge.dns-01.lua",
		["acme.datautil"] = "datautil.lua",
		["acme.error"] = "error.lua",
	},
	install = {
		bin = {
			"luacme"
		}
	},
}