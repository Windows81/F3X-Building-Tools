local Tool = script.Parent
local ImportCooldown = 0
local LastCopy = 0

Settings = {
	--------------------------------------
	--	COMMUNICATION
	--------------------------------------

	-- ABOUT WEBHOOKS: Webhooks used to be here, but to prevent hackers to send messages by using require to get your webhook, it can be found in CommunicationBridge.WebhookSetup.

	WebhookModule = require(Tool:WaitForChild("Libraries"):WaitForChild("CommunicationBridge")),

	-- TODO: Add log configuration here.

	--------------------------------------
	--	BAD BEHAVIORS
	--------------------------------------

	-- TIP: if you want to disable those behaviors in private servers, you can use logic gates or check in the function.
	-- How many lag-friendly parts (unanchored, particle emitters, etc...) you can create in a minute without getting kicked.

	LagFriendlyPartLimit = math.huge,

	-- Ungrouping a humanoid can cause killloops. Anybody doing so will get affected by the BadBehaviorSubFunction.
	-- Disabling this is a silly idea, in my opinion.

	DisallowHumanoidUngrouping = false,

	-- Enormous meshes are very annoying to remove, and can cause Z-fighting artifacts that are very disturbing.
	-- You can prevent them so. Note that the size is calculated this way: Mesh.Size.X * Part.Size.X e. g.

	MaxNormalMeshSize = 10240,

	-- If you want to kick the player when they place a big normal mesh.

	TriggerBadBehaviorForNormalMeshes = false,

	-- The biggest FileMesh would be 2048 studs big. This would limit the file mesh's size to 20480 e. g. for the worst.

	MaxFileMeshSize = 20480,

	-- If you want to kick the player when they place a big normal mesh.

	TriggerBadBehaviorForFileMeshes = false,

	-- If you got some c00lkid fans, enabling this will trigger a BadBehaviorSubFunction that will check the image/independent texture.
	-- You can decide there if you want to kick the user or not.

	BlacklistImages = false,

	-- Some hackers might try to select things inside of Terrain or outside of Workspace like Players.
	-- Enabling this option will kick them out of the server.

	OnlySelectInWorkspace = false,

	--------------------------------------
	--	CONSEQUENCES
	--------------------------------------

	-- If a bad behavior is triggered, it returns a BehaviorCode that can be:
	-- - Mass unanchoring - "Anchor"
	-- - Mass particle emitters - "Lag"
	-- - Humanoid Ungrouping - "Ungroup"
	-- - MeshSize - "Mesh"
	-- - ImageBlacklist - "Image"
	-- The table below contains a specific function for each of those. In this case, I used the webhook and kicked the player.

	BadBehaviorFunction = function(Player: Player, Module, BehaviorCode, Values)
		local BadBehaviorSubFunctions = {
			Anchor = function(Player: Player, Module, Values)
	--			Module.Embed("", "INAPPROPRIATE BEHAVIOR WARNING FOR ".. Player.DisplayName .." (@"..Player.Name.."):", "The mentioned player unanchored " .. Values.Parts .. " parts at the minute, which is above the limit.", 0xff0000)
	--			Player:Kick("KICKED: You got kicked for mass unanchoring.")
				return true
			end,
			Lag = function(Player: Player, Module, Values)
				Module.Embed("", "INAPPROPRIATE BEHAVIOR WARNING FOR ".. Player.DisplayName .." (@"..Player.Name.."):", "The mentioned player placed approximatively " .. Values.Rate / 20 .. " particles at the minute, which is above the limit.", 0xff0000)
				Player:Kick("KICKED: You got kicked for placing too many particle emitters.")
				return true
			end,
			Forbidden = function(Player: Player, Module, Values)
				Module.Embed("", "INAPPROPRIATE BEHAVIOR WARNING FOR ".. Player.DisplayName .." (@"..Player.Name.."):", "The mentioned player tried to select instances in forbidden location.", 0xff0000)
				Player:Kick("KICKED: You got kicked for selecting parts that are forbidden.")
				return true
			end,
			Ungroup = function(Player: Player, Module, Values)
				Module.Embed("", "INAPPROPRIATE BEHAVIOR WARNING FOR "..Player.DisplayName.." (@"..Player.Name.."):", "The mentioned player has attempted to ungroup somebody. See by yourself if taking action is necessary.", 0xff0000)
				Player:Kick("KICKED: You got kicked for ungrouping a player/NPC.")
				return true
			end,
			MeshSize = function(Player: Player, Module, Values)
				Module.Embed("", "INAPPROPRIATE BEHAVIOR WARNING FOR "..Player.DisplayName.." (@"..Player.Name.."):", "The mentioned player has attempted to create a part with a mesh of a total size of " .. Values.X .. ", " .. Values.Y .. ", " .. Values.Z .. ". As this can create destructive glitches, the player has been kicked.", 0xff0000)
				Player:Kick("KICKED: You got kicked for potentially creating enormous meshes.")
				return true
			end,
			Image = function(Player: Player, Module, Values)

				local function ParseAssetId(Input)
					-- Returns the intended asset ID for the given input

					-- Get the ID number from the input
					local Id = tonumber(Input)
						or tonumber(Input:lower():match("%d+"))
						or tonumber(Input:lower():match('%?id=([0-9]+)'))
						or tonumber(Input:match('/([0-9]+)/'))
						or tonumber(Input:lower():match('rbxassetid://([0-9]+)'))
						or tonumber(Input:lower():match('https://www.roblox.com/asset-thumbnail/image?assetId=/([0-9]+)/&width=50&height=50&format=png'))
						or tonumber(Input:lower():match('rbxthumb://type=Asset&id=/([0-9]+)/&w=420&h=420'))

					-- Return the ID
					return Id;
				end;

				if not Values.Image or not tonumber(ParseAssetId(Values.Image)) then return end		-- rbxthumbs are also checked too! Only the ID is submitted...

				local ImageId = ParseAssetId(Values.Image)

				local BadNames = {
					"coolkid",
					"c00lkid",
					"coolkidd",
					"c00lkidd",
					"hacker",
					"hack"
				}

				local MarketplaceService = game:GetService("MarketplaceService")
				local ProductName = MarketplaceService:GetProductInfo(ImageId, Enum.InfoType.Asset) and
					string.lower(MarketplaceService:GetProductInfo(ImageId, Enum.InfoType.Asset).Name)

				-- Yes. I use this way so I don't need to update.

				if not ProductName then return end

				local IsBlacklisted = false

				for _, BadName in pairs(BadNames) do
					if string.find(ProductName, BadName) then
						IsBlacklisted = true
					end
				end

				if IsBlacklisted == true then
					Module.Embed("", "INAPPROPRIATE BEHAVIOR WARNING FOR "..Player.DisplayName.." (@"..Player.Name.."):", "The mentioned player placed a blacklisted image named " .. ProductName .. ". They have been kicked.", 0xff0000)
					Player:Kick("KICKED: You got kicked for placing a blacklisted image.")
					return true
				end
			end,
		}

		local Positive

		if BadBehaviorSubFunctions[BehaviorCode] then
			Positive = BadBehaviorSubFunctions[BehaviorCode](Player, Module, Values)
		end

		return Positive or false
	end,

	--------------------------------------
	--	PERMISSIONS
	--------------------------------------

	-- If you want to set this up and use raidRoleplay's tags, you can safely put "return true" in the space between function() and end
	-- If you want to use your own system, you can check the part with CheckPermission and own/unown parts with SetPermission.

	-- The Type argument will be:

	-- "New" when a new part is created.
	-- "Lock" if a part gets locked. You can know if you're locking or unlocking with the Locking argument.

	-- If you use HD admin or Adonis, feel free to check the rank too!

	-- Set PartSelectionLimit or CloningDelay to 0 if you don't want it/them to be applied. Otherwisely, use logic gates or numbers for it.

	-- Every settings after have to be a boolean or a logic gate under specific conditions.

	CheckPermission = function(Item: Instance, Player: Player)
		return true
	end,

	SetPermission = function(Item: Instance, Player: Player, Type: string, Locking: boolean)
		if Type == "Lock" then
			Item.Locked = Locking
		end
	end,

	-- The consider part function determines whether a part will be considered or not.
	-- Compared to CheckPermission, when this function returns false, the part will just be ignored.
	-- Use CheckPermission if you want to make the system to be aware of the part, or this function if you want to ignore it (baseplate i. e.)

	ConsiderPart = function(Item: Instance, Player: Player)
		return not (Item:IsA("BasePart") and Item.Locked or Item:IsA("Terrain")) and true
	end,


	PartSelectionLimit = 0,
	CloningDelay = 0,

	CanUseExplorer = true,
	CanUseSaveLoad = true,

	-- If you are alright to let people clone/delete/move other players, set this setting to 0.
	-- If you don't want people to be able to delete/clone/move other players, set this setting to 1.
	-- If you just want to prohibt any modification at players, set this setting to 2.

	PlayerTolerance = 0,

	-- Does your game have a lobby? You can disable spawns by adding "Spawn" to this table.
	-- This setting is here if you want to blacklist certain parts to be created via the New Part Tool.

	InstanceBlacklist = {},

	--------------------------------------
	--	MISCS
	--------------------------------------

	-- When you point at a part, you can add a hint where you can input the part's name and more things.
	-- Set it to false if you don't want hints to display (mostly if you use raidRoleplay).
	-- You can just display the item's name by putting "return Item.Name".

	PartHintFunction = function(Core, Item, Player)
		return Item.Name
	end,

	-- In the explorer, you can add a custom name (Part [@John Doe] e. g.) with this function.
	-- If this doesn't matter for you, just put "return Item.Name".

	CustomNameFunction = function(Item, Player)
		return Item.Name
	end,

	-- The SelectionBox and the TargetBox are the outlines seen when respectively selecting or targetting.
	-- To prevent lag, those need to be used once and aren't stored in the tool's files.
	-- You can modify how they're created by changing the different properties of those.

	SelectionBoxMake = function(Core)
		print("show em one or two things")

		return {
			Name = 'BTSelectionBox',
			Parent = Core.UI,
			LineThickness = 0.025,
			Transparency = 0.6,
			Color = Core.Selection.Color,
		};
	end;

	TargetBoxMake = function(Core)
		return {
			Name = 'BTTargetBox',
			Parent = Core.UI,
			LineThickness = 0.025,
			Transparency = 0.6,
			Color = BrickColor.new 'Institutional white'
		};
	end;

	-- Adding tools is pretty way to go. However, adding new buttons for the selection pane might be more challenging.
	-- The selection pane isn't too hard to modify. But the core module almost gets modified at each update.
	-- This is why you can add some extra functions here that will be added natively to the Core module.
	-- Your custom function requires the code as a first table element, then the hotkey to which it's assigned as a second element (a string like 'Y' or a table)
	-- Put the hotkey to nil if you don't want it to have a key assigned.
	-- Any function that's called gets the core module as a first argument.
	-- You DON'T need to submit Core as an argument when calling the function.

	CustomCoreFunctions = {};

	-- If you're interested in triggering sounds, notifications, etc... when core-related functions or event are triggered, you can add events here.
	-- This function will be called at the setup with core as an argument, and will set up connections.
	-- You can add a click sound when selecting with an signal like Core.Selection.Changed:Connect() i. e.

	CustomCoreConnections = function(Core)
	end;

	-- If you're interested in adding new functionalities while being able to update Fork3X with ease, you can add the functions here.
	-- They will be natively integrated to the SyncModule. You don't need to do anything more.

	ExtraSyncAPIFunctions = {};

	-- If you're interested in adding custom instances via the New Part tool, you can add them here.
	-- You need to specify the name of the instance and the function to create it.

	CustomPartTypes = {};

	-- You can change the delay between each time you press the Load button with the Save/Load utility.

	LoadDelay = 0;

	--------------------------------------
	--	CLASSIC F3X SETTINGS
	--------------------------------------

	DisallowLocked = false;
	--[[
	When streaming is enabled, and the tool is being used by a player, cloned
	items are tagged with a temporary ID for this long in order for clients to
	be able to identify them as they replicate in.
	]]
	StreamingCloneTagLifetime = 2,
}

return Settings
