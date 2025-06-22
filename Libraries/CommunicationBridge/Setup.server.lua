local Tool = script:FindFirstAncestorWhichIsA("Tool")
local Module = require(script.Parent)

local Webhook = nil		-- You imperatively mustn't leak this to anybody you don't trust.

Module.SetWebhook(Webhook)