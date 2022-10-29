return {
    ['git'] = function(args, kwargs, meta)
        quarto.log.output("git")
        return pandoc.Str("Hello from git!")
    end
}
