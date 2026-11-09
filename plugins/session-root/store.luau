--!strict
-- Session roots, kept in `tern.kv` under "sessions" so every window and every
-- run of Tern shares them, plus the path handling around them.
--
-- Entries are nested by scope, then session name:
--   { ["local"] = { [name] = Entry }, ["remote:<host>"] = { [name] = Entry } }
-- Names never share a string with their scope, so a local session can't take
-- a remote one's key whatever either is called. Session ids are only trusted
-- within one window run: `sync` refreshes them when the window starts, and
-- `get` uses them to notice a rename.

local store = {}

export type Session = {
	id: number,
	name: string,
	--- Remote host address; nil on the local machine.
	host: string?,
}

export type Entry = {
	root: string,
	id: number?,
}

type Scope = { [string]: Entry }
type Scopes = { [string]: Scope }

local KEY = "sessions"
local LOCAL = "local"
local HOME = tern.getenv("HOME")
local MACOS = tern.runtime.os == "macos"
-- macOS shells report these through their /private targets.
local PRIVATE = { "/tmp", "/var", "/etc" }

local function load(): Scopes
	local value = tern.kv.get(KEY)
	if type(value) ~= "table" then
		return {}
	end
	return value :: Scopes
end

local function scope_of(s: Session): string
	return if s.host then "remote:" .. s.host else LOCAL
end

-- Drops empty scopes, then writes.
local function save(scopes: Scopes)
	for name, scope in scopes do
		if next(scope) == nil then
			scopes[name] = nil
		end
	end
	tern.kv.set(KEY, scopes)
end

--- `path` with `~` expanded and trailing slashes dropped; on this machine on
--- macOS, also without the `/private` shells report for /tmp, /var and /etc,
--- so a root and a pane's reported directory compare equal.
function store.normalize(path: string, is_local: boolean): string
	if is_local and HOME ~= nil and (path == "~" or string.sub(path, 1, 2) == "~/") then
		path = HOME .. string.sub(path, 2)
	end
	local trimmed = string.gsub(path, "(.)/+$", "%1")
	path = trimmed
	if is_local and MACOS then
		for _, dir in PRIVATE do
			local private = "/private" .. dir
			if path == private or string.sub(path, 1, #private + 1) == private .. "/" then
				return string.sub(path, #"/private" + 1)
			end
		end
	end
	return path
end

--- The root of session `s`, or nil. An entry under another name in the same
--- scope that carries this session's id means the session was renamed: the
--- entry moves to the new name. An entry found by name records the id, in
--- case `sync` couldn't (the session wasn't listed yet).
function store.get(s: Session): string?
	local scopes = load()
	local scope = scopes[scope_of(s)]
	if scope == nil then
		return nil
	end
	local entry = scope[s.name]
	if entry ~= nil then
		if entry.id ~= s.id then
			entry.id = s.id
			save(scopes)
		end
		return entry.root
	end
	for old, e in scope do
		if e.id == s.id then
			scope[old] = nil
			scope[s.name] = e
			save(scopes)
			return e.root
		end
	end
	return nil
end

function store.set(s: Session, root: string)
	local scopes = load()
	local key = scope_of(s)
	local scope = scopes[key] or {}
	scope[s.name] = { root = root, id = s.id }
	scopes[key] = scope
	save(scopes)
end

function store.clear(s: Session)
	local scopes = load()
	local scope = scopes[scope_of(s)]
	if scope ~= nil and scope[s.name] ~= nil then
		scope[s.name] = nil
		save(scopes)
	end
end

--- Forgets the entry of a session that ended. `session_ended` carries no host,
--- so every scope is searched, and both id and name must match.
function store.forget(id: number, name: string)
	local scopes = load()
	local changed = false
	for _, scope in scopes do
		local entry = scope[name]
		if entry ~= nil and entry.id == id then
			scope[name] = nil
			changed = true
		end
	end
	if changed then
		save(scopes)
	end
end

--- Records the ids of the sessions this window sees and drops ids recorded by
--- an earlier run, which may now name another session. Entries of sessions it
--- doesn't see are kept: at `window_start` after a restart the list may not
--- hold every restored session yet, so absence proves nothing.
function store.sync(sessions: { Session })
	local scopes = load()
	local seen: { [string]: { [string]: Session } } = {}
	for _, s in sessions do
		local key = scope_of(s)
		local names = seen[key] or {}
		names[s.name] = s
		seen[key] = names
	end
	local changed = false
	for key, scope in scopes do
		local names = seen[key] or {}
		for name, e in scope do
			local s = names[name]
			local id = if s then s.id else nil
			if e.id ~= id then
				e.id = id
				changed = true
			end
		end
	end
	if changed then
		save(scopes)
	end
end

return store
