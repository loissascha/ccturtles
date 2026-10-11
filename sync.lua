-- sync.lua
-- Downloads an entire public GitHub repository

local owner, repo, branch = ...

assert(owner and repo,
	"Usage: sync <username> <repo> [branch]")

branch = branch or "main"

local apiUrl =
	"https://api.github.com/repos/"
	.. owner .. "/" .. repo
	.. "/git/trees/" .. branch
	.. "?recursive=1"

local rawUrl =
	"https://raw.githubusercontent.com/"
	.. owner .. "/" .. repo
	.. "/" .. branch .. "/"

local function fetch(url)
	local response, err = http.get(url)

	if not response then
		error("HTTP request failed: " .. tostring(err))
	end

	local code = response.getResponseCode()
	local data = response.readAll()
	response.close()

	if code ~= 200 then
		error("HTTP " .. code .. ": " .. url)
	end

	return data
end

print("Fetching repository: " .. owner .. "/" .. repo)

local data = textutils.unserializeJSON(fetch(apiUrl))

assert(data and data.tree, "Invalid GitHub response")
assert(not data.truncated, "Repository tree was truncated")

local downloaded = 0

for _, entry in ipairs(data.tree) do
	if entry.type == "blob" then
		local path = entry.path

		-- Skip GitHub configuration and local state
		if not path:match("^%.github/")
			and path ~= "nav_home.json"
			and not path:find("%.%.", 1, true)
			and not path:match("^/") then
			print("Downloading: " .. path)

			local contents = fetch(rawUrl .. path)

			local dir = fs.getDir(path)

			if dir ~= "" and not fs.exists(dir) then
				fs.makeDir(dir)
			end

			local file = assert(fs.open(path, "w"))
			file.write(contents)
			file.close()

			downloaded = downloaded + 1
		end
	end
end

print("Sync complete! Downloaded "
	.. downloaded .. " files.")
