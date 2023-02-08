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
        local cmd = string.format("git -C %q show %s:%q >%q", repo, rev, file, out_filepath)
        os.execute(cmd)
    end
    return out_filename, out_dir
end


local function git_include(args, kwargs, meta)
    local repo_name = "."
    local repo = get_repo(meta, repo_name)

    local rev = pandoc.utils.stringify(kwargs["rev"])
    rev = (rev ~= "") and rev or "HEAD"
    local file = pandoc.utils.stringify(args[1])

    local out_filename, out_dir = retrive_file(repo, rev, file)
    return pandoc.path.join({ quarto.project.offset, "vcs", out_filename })
end

return {
    ['git'] = git_include
}
