--!strict
-- Session Root: each session may have a root directory, and new tabs in that
-- session open there.
--
-- New Tab (⌘T, the toolbar's +, the palette) is overridden. The + on a
-- session's row in the vertical tab list doesn't run New Tab: it opens a tab
-- in the directory of that session's focused pane. Such a tab is noticed in
-- `tab_created` and replaced by one at the root.

local store = require("./store")

-- Panes this plugin opened, until their `tab_created` passes.
local mine: { [number]: boolean } = {}
-- Panes created in the current tick.
local fresh: { [number]: boolean } = {}
-- Per session id: the last focused pane that existed before it was focused,
-- the pane whose directory a session row's + copies.
local last_focus: { [number]: number } = {}

type Host = { kind: string, address: string?, name: string }

local function host_key(host: Host): string?
	if host.kind == "local" then
		return nil
	end
	return host.address or host.name
end

local function session(cx: WindowCx): store.Session
	local cur = cx.sessions:current()
	return { id = cur.id, name = cur.name, host = host_key(cx.hosts:current()) }
end

local function normalize(s: store.Session, path: string): string
	return store.normalize(path, s.host == nil)
end

local function focused_cwd(cx: WindowCx): string?
	local id = cx.session:focused()
	local pane = if id then cx.session:pane(id) else nil
	if pane == nil or pane.cwd == nil or pane.cwd == "" then
		return nil
	end
	return pane.cwd
end

local function open_at_root(cx: WindowCx, root: string): number?
	local pane = cx.layout:new_tab({ cwd = root })
	if pane ~= nil then
		mine[pane] = true
	end
	return pane
end

-- A directory the user typed, checked where it can be: on this machine.
local function accept_dir(cx: WindowCx, s: store.Session, text: string?): string?
	if text == nil then
		return nil
	end
	local trimmed = string.gsub(text, "^%s*(.-)%s*$", "%1")
	if trimmed == "" then
		return nil
	end
	local dir = normalize(s, trimmed)
	if string.sub(dir, 1, 1) ~= "/" and string.sub(dir, 1, 1) ~= "~" then
		cx:toast("error", "Session root must be an absolute path", dir)
		return nil
	end
	if s.host == nil and not tern.fs.exists(dir) then
		cx:toast("error", "No such directory", dir)
		return nil
	end
	return dir
end

local function set_root(cx: WindowCx, s: store.Session, dir: string)
	store.set(s, dir)
	cx:toast("success", "Session root of " .. s.name, dir)
end

-- New Tab, wherever it starts except a session row's +.
tern.override("new_tab", function(cx)
	local root = store.get(session(cx))
	if root == nil then
		return false
	end
	open_at_root(cx, root)
	return true
end)

tern.on("pane_created", function(ev: { pane: number }, _cx)
	local pane = ev.pane
	fresh[pane] = true
	tern.timer(0, function()
		fresh[pane] = nil
	end)
end)

tern.on("pane_closed", function(ev: { pane: number }, _cx)
	mine[ev.pane] = nil
end)

tern.on("focus", function(ev: { pane: number, tab: number }, cx)
	if fresh[ev.pane] then
		return
	end
	last_focus[cx.sessions:current().id] = ev.pane
end)

-- A session row's + opened a shell tab in the directory of the session's
-- focused pane: replace it with one at the root, in the same position.
tern.on("tab_created", function(ev: { tab: number }, cx)
	local layout = cx.session:layout(ev.tab)
	local pane = if layout then layout.root.pane else nil
	if pane == nil then
		return
	end
	if mine[pane] then
		mine[pane] = nil
		return
	end
	if not fresh[pane] then
		return -- a pane moved into a tab of its own
	end
	local info = cx.session:pane(pane)
	if info == nil or info.kind ~= "terminal" or info.cwd == nil then
		return
	end
	local s = session(cx)
	local root = store.get(s)
	if root == nil then
		return
	end
	local here = normalize(s, info.cwd)
	if here == normalize(s, root) then
		return
	end
	-- Only a tab that copied the focused pane's directory, as the + does;
	-- tabs other plugins open in a directory of their choosing stay.
	local before = last_focus[s.id]
	local before_info = if before then cx.session:pane(before) else nil
	if before_info ~= nil and before_info.cwd ~= nil and normalize(s, before_info.cwd) ~= here then
		return
	end

	local position: number? = nil
	for _, tab in cx.session:tabs() do
		if tab.id == ev.tab then
			position = tab.position
		end
	end
	local replacement = open_at_root(cx, root)
	if replacement == nil then
		return
	end
	cx.layout:close(pane)
	local tab = cx.session:tab_of(replacement)
	if tab ~= nil and position ~= nil then
		cx.layout:order_tab(tab, position)
	end
end)

tern.on("session_ended", function(ev: { session: number, name: string, shown: boolean }, _cx)
	store.forget(ev.session, ev.name)
end)

tern.on("window_start", function(cx: WindowCx)
	local hosts: { [number]: string? } = {}
	for _, host in cx.hosts:list() do
		hosts[host.id] = host_key(host)
	end
	local sessions: { store.Session } = {}
	for _, s in cx.sessions:list() do
		table.insert(sessions, { id = s.id, name = s.name, host = hosts[s.host] })
	end
	store.sync(sessions)
end)

tern.command({
	id = "set_here",
	title = "Session root: use this directory",
	icon = "folder",
	group = "Session Root",
	available = function(cx)
		return focused_cwd(cx) ~= nil
	end,
	run = function(cx)
		local cwd = focused_cwd(cx)
		if cwd == nil then
			return
		end
		local s = session(cx)
		set_root(cx, s, normalize(s, cwd))
	end,
})

tern.command({
	id = "set",
	title = "Session root: set…",
	icon = "folder",
	group = "Session Root",
	run = function(cx)
		local s = session(cx)
		cx:prompt({
			value = store.get(s) or focused_cwd(cx),
			placeholder = "Root directory of " .. s.name,
			icon = "folder",
			action = "set root",
		}):next(function(text, _err, cx2)
			if cx2 == nil then
				return
			end
			local dir = accept_dir(cx2, s, text)
			if dir ~= nil then
				set_root(cx2, s, dir)
			end
		end)
	end,
})

tern.command({
	id = "clear",
	title = "Session root: clear",
	icon = "folder",
	group = "Session Root",
	available = function(cx)
		return store.get(session(cx)) ~= nil
	end,
	run = function(cx)
		local s = session(cx)
		store.clear(s)
		cx:toast("info", "Session root of " .. s.name .. " cleared")
	end,
})

tern.command({
	id = "new_session",
	title = "New session at directory…",
	icon = "folder",
	group = "Session Root",
	run = function(cx)
		local here = session(cx)
		cx:prompt({
			value = focused_cwd(cx),
			placeholder = "Root directory of the new session",
			icon = "folder",
			action = "create session",
		}):next(function(text, _err, cx2)
			if cx2 == nil then
				return
			end
			local dir = accept_dir(cx2, here, text)
			if dir == nil then
				return
			end
			local name = string.match(dir, "([^/]+)$") or dir
			local ok, err = pcall(function()
				cx2.sessions:create({ name = name, cwd = dir })
			end)
			if not ok then
				cx2:toast("error", "Couldn't create session " .. name, tostring(err))
				return
			end
			set_root(cx2, session(cx2), dir)
		end)
	end,
})
