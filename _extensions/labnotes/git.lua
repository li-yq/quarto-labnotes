local out_dir = pandoc.path.join({ quarto.project.output_directory, "vcs" })

local function get_repo(meta, name)
    local path = ( meta.repos or {} )[name] or "."
    return pandoc.path.join({quarto.project.directory, path})
end

local function normailize_rev(repo, rev)
    return pandoc.pipe("git", { "-C", repo, "rev-parse", "--verify", rev }, ""):sub(1, 40)
end

local function file_exists(name)
    local f = io.open(name, 'r')
    if f ~= nil then
        io.close(f)
        return true
    end
    return false
end

function retrive_file(repo, rev, file)
    rev = normailize_rev(repo, rev)
    file = pandoc.path.normalize(file)
    local hash = pandoc.utils.sha1(rev .. file):sub(1, 20)
    local out_filename = hash .. "-" .. pandoc.path.filename(file)
    pandoc.path.filename(file)
    local out_filepath = pandoc.path.join({ out_dir, out_filename })

    pandoc.system.make_directory(out_dir, true)
    if not file_exists(out_filepath) then
        local cmd = string.format("dvc get %q --rev %q %q -o %q", repo, rev, file, out_filepath)
        os.execute(cmd)
    end
    return out_filename, out_dir
end


local function git_include(args, kwargs, meta)
    if #args == 2 then
        repo_name, path = pandoc.utils.stringify(args[1]), pandoc.utils.stringify(args[2])
    elseif #args == 1 then
        repo_name, path = ".", pandoc.utils.stringify(args[1])
    else
        error("invalid args")
    end
    local repo = get_repo(meta, repo_name)
    
    local rev = pandoc.utils.stringify(kwargs["rev"])
    rev = (rev ~= "") and rev or "HEAD"

    local out_filename, out_dir = retrive_file(repo, rev, path)
    return pandoc.path.join({ quarto.project.offset, "vcs", out_filename })
end

local function git_log(args, kwargs, meta)
    local repo_name = pandoc.utils.stringify(kwargs["repo"])
    repo_name = (repo_name ~= "") and repo_name or "."
    local repo = get_repo(meta, repo_name)

    parsed_args = {}
    for k,v in pairs(args) do
        parsed_args[k] = pandoc.utils.stringify(v)
    end
    local logs = pandoc.pipe("git", { "-C", repo, "log", "--oneline", table.unpack(parsed_args)}, "")

    local result = {}
    for commit, message in string.gmatch(logs, "([0-9a-f]+) ([^\n]*)") do
        table.insert(result, pandoc.Plain( { pandoc.Code(commit), " ", message } ))
    end
    return pandoc.BulletList(result)
end


return {
    ['git-include'] = git_include;
    ['git-log'] = git_log;
}
