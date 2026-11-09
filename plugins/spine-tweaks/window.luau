--!strict
-- Spine Tweaks: your own picture as your avatar in Spine chats.
--
-- The picture lives in the plugin's data folder as `avatar`, so reinstalling
-- the plugin keeps it. CSS `url()` can only name files inside the plugin, so
-- the picture goes into a `tern.css` sheet as a `data:` URL. Without one the
-- avatar stays Tern's own.

local AVATAR = tern.plugin.data .. "/avatar"
local MAX_BYTES = 512 * 1024
local SHEET = "avatar"
local RULE = [[
.sf-chat-spine [data-role="omp.user"]::before {
  content: "";
  background-color: transparent !important;
  background-image: url("data:%s;base64,%s") !important;
  background-size: cover !important;
  background-position: center;
  background-repeat: no-repeat;
}
]]

-- The picture's MIME type from its first bytes, or nil for anything else.
local function sniff(bytes: string): string?
	if string.sub(bytes, 1, 8) == "\137PNG\r\n\26\n" then
		return "image/png"
	elseif string.sub(bytes, 1, 3) == "\255\216\255" then
		return "image/jpeg"
	elseif string.sub(bytes, 1, 4) == "GIF8" then
		return "image/gif"
	elseif string.sub(bytes, 1, 4) == "RIFF" and string.sub(bytes, 9, 12) == "WEBP" then
		return "image/webp"
	end
	return nil
end

-- Reads a picture, or returns nil and why not.
local function load(path: string): (string?, string?, string?)
	local ok, bytes = pcall(tern.fs.read, path, MAX_BYTES + 1)
	if not ok then
		return nil, nil, tostring(bytes)
	end
	if #bytes > MAX_BYTES then
		return nil, nil, "larger than " .. MAX_BYTES // 1024 .. " KiB"
	end
	local mime = sniff(bytes)
	if mime == nil then
		return nil, nil, "not a PNG, JPEG, GIF or WebP picture"
	end
	return bytes, mime, nil
end

-- Installs the avatar sheet from the data folder, or empties it.
local function apply(): string?
	if not tern.fs.exists(AVATAR) then
		tern.css(SHEET, "")
		return nil
	end
	local bytes, mime, err = load(AVATAR)
	if bytes == nil or mime == nil then
		tern.css(SHEET, "")
		return err
	end
	tern.css(SHEET, string.format(RULE, mime, tern.base64.encode(bytes)))
	return nil
end

local function expand(path: string): string
	local home = tern.getenv("HOME")
	if home ~= nil and (path == "~" or string.sub(path, 1, 2) == "~/") then
		return home .. string.sub(path, 2)
	end
	return path
end

tern.command({
	id = "choose_avatar",
	title = "Spine Tweaks: choose avatar…",
	icon = "image",
	run = function(cx)
		cx:prompt({
			placeholder = "Path of a PNG, JPEG, GIF or WebP picture",
			icon = "image",
			action = "use as avatar",
		}):next(function(text, _err, cx2)
			if cx2 == nil or text == nil then
				return
			end
			local path = expand((string.gsub(text, "^%s*(.-)%s*$", "%1")))
			if path == "" then
				return
			end
			local bytes, _mime, err = load(path)
			if bytes == nil then
				cx2:toast("error", "Can't use that picture", err)
				return
			end
			tern.fs.write(AVATAR, bytes)
			local failed = apply()
			if failed then
				cx2:toast("error", "Avatar not applied", failed)
			else
				cx2:toast("success", "Avatar set", path)
			end
		end)
	end,
})

tern.command({
	id = "clear_avatar",
	title = "Spine Tweaks: clear avatar",
	icon = "image",
	available = function(_cx)
		return tern.fs.exists(AVATAR)
	end,
	run = function(cx)
		tern.fs.remove(AVATAR)
		apply()
		cx:toast("info", "Avatar cleared")
	end,
})

local failed = apply()
if failed then
	tern.log.warn("spine-tweaks: avatar not applied:", failed)
end
