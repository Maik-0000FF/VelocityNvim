-- ~/.config/VelocityNvim/lua/utils/git.lua
-- Git utilities and helpers

local M = {}

--- Check if git is available
---@return boolean
function M.is_available()
  return vim.fn.executable("git") == 1
end

--- Check if current directory is a git repository
---@param path string|nil Path to check (default: current directory)
---@return boolean
function M.is_repo(path)
  if not M.is_available() then return false end

  path = path or vim.fn.getcwd()
  local git_dir = path .. "/.git"

  return vim.fn.isdirectory(git_dir) == 1 or vim.fn.filereadable(git_dir) == 1
end

--- Get git root directory
---@param path string|nil Starting path (default: current directory)
---@return string|nil Git root path
function M.get_root(path)
  if not M.is_available() then return nil end

  -- PERFORMANCE: Native git command ist schneller als custom path walking
  local output, exit_code = M.exec({ "rev-parse", "--show-toplevel" }, { cwd = path })
  return exit_code == 0 and output or nil
end

--- Execute git command
---@param cmd table Git command arguments
---@param opts table|nil Options (cwd, timeout, etc.)
---@return string|nil output, integer exit_code
function M.exec(cmd, opts)
  if not M.is_available() then
    return nil, 1
  end

  opts = opts or {}
  local full_cmd = { "git" }
  vim.list_extend(full_cmd, cmd)

  -- PERFORMANCE: Native vim.system() ist 30-50% schneller als vim.fn.system()
  -- Neovim 0.10+ API mit besserer Fehlerbehandlung und async-Fähigkeit
  local result = vim.system(full_cmd, {
    cwd = opts.cwd,
    timeout = opts.timeout or 10000, -- 10s timeout
    text = true,
  }):wait()

  if result.code == 0 then
    return vim.trim(result.stdout or ""), result.code
  else
    return nil, result.code
  end
end

--- Get current branch name
---@param path string|nil Repository path
---@return string|nil Branch name
function M.get_branch(path)
  -- PERFORMANCE: Eliminiere directory changes - nutze cwd parameter direkt
  local branch, exit_code = M.exec({ "branch", "--show-current" }, { cwd = path })
  return exit_code == 0 and branch or nil
end

--- Get git status (short format)
---@param path string|nil Repository path
---@return table|nil Status information
function M.get_status(path)
  -- PERFORMANCE: Eliminiere directory changes - nutze cwd parameter
  local output, exit_code = M.exec({ "status", "--porcelain" }, { cwd = path })

  if exit_code ~= 0 then
    return nil
  end

  local status = {
    added = 0,
    modified = 0,
    deleted = 0,
    renamed = 0,
    untracked = 0,
    total = 0,
    files = {}
  }

  if output and output ~= "" then
    for line in output:gmatch("[^\r\n]+") do
      local index_status = line:sub(1, 1)
      local worktree_status = line:sub(2, 2)
      local filename = line:sub(4)

      local file_status = {
        filename = filename,
        index = index_status,
        worktree = worktree_status
      }

      table.insert(status.files, file_status)
      status.total = status.total + 1

      -- Count by type
      if index_status == "A" or worktree_status == "A" then
        status.added = status.added + 1
      elseif index_status == "M" or worktree_status == "M" then
        status.modified = status.modified + 1
      elseif index_status == "D" or worktree_status == "D" then
        status.deleted = status.deleted + 1
      elseif index_status == "R" or worktree_status == "R" then
        status.renamed = status.renamed + 1
      elseif index_status == "?" then
        status.untracked = status.untracked + 1
      end
    end
  end

  return status
end

--- Get recent commits
---@param count integer|nil Number of commits (default: 10)
---@param path string|nil Repository path
---@return table|nil List of commits
function M.get_commits(count, path)
  count = count or 10

  -- PERFORMANCE: Eliminiere directory changes - nutze cwd parameter
  local output, exit_code = M.exec({
    "log",
    "--oneline",
    "--max-count=" .. count,
    "--pretty=format:%h|%an|%ar|%s"
  }, { cwd = path })

  if exit_code ~= 0 or not output then
    return nil
  end

  local commits = {}
  for line in output:gmatch("[^\r\n]+") do
    local hash, author, date, message = line:match("([^|]+)|([^|]+)|([^|]+)|(.+)")
    if hash then
      table.insert(commits, {
        hash = hash,
        author = author,
        date = date,
        message = message
      })
    end
  end

  return commits
end

--- Check if file is tracked by git
---@param file string File path
---@param path string|nil Repository path
---@return boolean
function M.is_tracked(file, path)
  -- PERFORMANCE: Eliminiere directory changes - nutze cwd parameter
  local _, exit_code = M.exec({ "ls-files", "--error-unmatch", file }, { cwd = path })
  return exit_code == 0
end

--- Get file diff
---@param file string File path
---@param staged boolean|nil Get staged diff
---@param path string|nil Repository path
---@return string|nil Diff output
function M.get_file_diff(file, staged, path)
  local cmd = { "diff" }
  if staged then
    table.insert(cmd, "--staged")
  end
  table.insert(cmd, file)

  -- PERFORMANCE: Eliminiere directory changes - nutze cwd parameter
  local output, exit_code = M.exec(cmd, { cwd = path })
  return exit_code == 0 and output or nil
end

--- Add file to git
---@param file string File path
---@param path string|nil Repository path
---@return boolean success
function M.add_file(file, path)
  -- PERFORMANCE: Eliminiere directory changes - nutze cwd parameter
  local _, exit_code = M.exec({ "add", file }, { cwd = path })
  return exit_code == 0
end

--- Get git blame for file
---@param file string File path
---@param path string|nil Repository path
---@return table|nil Blame information
function M.get_blame(file, path)
  -- PERFORMANCE: Eliminiere directory changes - nutze cwd parameter
  local output, exit_code = M.exec({
    "blame",
    "--line-porcelain",
    file
  }, { cwd = path })

  if exit_code ~= 0 or not output then
    return nil
  end

  local blame_info = {}
  local current_commit = nil

  for line in output:gmatch("[^\r\n]+") do
    if line:match("^%x+") then
      -- New commit hash
      current_commit = {
        hash = line:match("^(%x+)"),
        lines = {}
      }
      table.insert(blame_info, current_commit)
    elseif line:match("^author ") then
      if current_commit then
        current_commit.author = line:match("^author (.+)")
      end
    elseif line:match("^author%-time ") then
      if current_commit then
        current_commit.timestamp = tonumber(line:match("^author%-time (%d+)"))
      end
    elseif line:match("^summary ") then
      if current_commit then
        current_commit.summary = line:match("^summary (.+)")
      end
    end
  end

  return blame_info
end

--- Get git configuration value
---@param key string Configuration key
---@param path string|nil Repository path
---@return string|nil Configuration value
function M.get_config(key, path)
  -- PERFORMANCE: Eliminiere directory changes - nutze cwd parameter
  local output, exit_code = M.exec({ "config", "--get", key }, { cwd = path })
  return exit_code == 0 and output or nil
end

--- Get current user info
---@param path string|nil Repository path
---@return table|nil User information
function M.get_user_info(path)
  local name = M.get_config("user.name", path)
  local email = M.get_config("user.email", path)

  if name or email then
    return {
      name = name,
      email = email
    }
  end

  return nil
end

--- Check if working directory is clean
---@param path string|nil Repository path
---@return boolean
function M.is_clean(path)
  local status = M.get_status(path)
  if not status then
    return false  -- If we can't get status, assume not clean
  end
  return status.total == 0
end

--- Get repository information summary
---@param path string|nil Repository path
---@return table|nil Repository info
function M.get_repo_info(path)
  if not M.is_repo(path) then
    return nil
  end

  local root = M.get_root(path)
  local branch = M.get_branch(path)
  local status = M.get_status(path)
  local user = M.get_user_info(path)
  local commits = M.get_commits(5, path)

  return {
    root = root,
    branch = branch,
    status = status,
    user = user,
    recent_commits = commits,
    is_clean = status and status.total == 0,
  }
end

--- Pretty print git repository information
---@param path string|nil Repository path
function M.print_info(path)
  if not M.is_available() then
    local icons = require("core.icons")
    print(icons.status.error .. " Git is not available")
    return
  end

  if not M.is_repo(path) then
    local icons = require("core.icons")
    print(icons.status.error .. " Not a git repository")
    return
  end

  local info = M.get_repo_info(path)
  if not info then
    local icons = require("core.icons")
    print(icons.status.error .. " Could not get repository information")
    return
  end

  local icons = require("core.icons")
  print(icons.status.sync .. " Git Repository Information:")
  print("  Root: " .. (info.root or "Unknown"))
  print("  Branch: " .. (info.branch or "Unknown"))

  if info.user then
    print("  User: " .. (info.user.name or "Unknown") .. " <" .. (info.user.email or "Unknown") .. ">")
  end

  if info.status then
    print("  Status: " .. (info.is_clean and "Clean" or "Modified"))
    if not info.is_clean then
      print("    Added: " .. info.status.added)
      print("    Modified: " .. info.status.modified)
      print("    Deleted: " .. info.status.deleted)
      print("    Untracked: " .. info.status.untracked)
    end
  end

  if info.recent_commits and #info.recent_commits > 0 then
    print("  Recent Commits:")
    for i, commit in ipairs(info.recent_commits) do
      if i <= 3 then -- Show only first 3
        print(string.format("    %s - %s (%s)", commit.hash, commit.message, commit.author))
      end
    end
  end
end

return M