local out_dir = pandoc.path.join({ quarto.project.output_directory, "vcs" })

local function normailize_rev(rev)
    return pandoc.pipe("git", { "rev-parse", "--verify", rev }, ""):sub(1, 40)
end

local function file_exists(name)
    local f = io.open(name, 'r')
    if f ~= nil then
        io.close(f)
        return true
    end
    return false
end

function retrive_file(rev, file)
    rev = normailize_rev(rev)
    file = pandoc.path.normalize(file)
    local hash = pandoc.utils.sha1(rev .. file):sub(1, 20)
    local out_filename = hash .. "-" .. pandoc.path.filename(file)
    pandoc.path.filename(file)
    local out_filepath = pandoc.path.join({ out_dir, out_filename })

    pandoc.system.make_directory(out_dir, true)
    if not file_exists(out_filepath) then
        local cmd = string.format("git show %s:%s >%s", rev, file, out_filepath)
        os.execute(cmd)
    end
    return out_filename, out_dir
end

return {
    ['git'] = function(args, kwargs, meta)
        local rev = pandoc.utils.stringify(kwargs["rev"])
        rev = (rev ~= "") and rev or "HEAD"
        local file = pandoc.utils.stringify(args[1])

        local out_filename, out_dir = retrive_file(rev, file)
        return pandoc.path.join({ quarto.project.offset, "vcs", out_filename })
    end
}
