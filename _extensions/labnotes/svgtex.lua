return {
    {
        Image = function(elem)
            local src = elem["src"]
            if (not src:match(".svg$")) then
                return
            end

            local outdir = pandoc.path.directory(quarto.doc.output_file)
            local filename = pandoc.path.join({ outdir, src })
            local outfile = filename .. ".pdf"
            
            os.execute(string.format("rsvg-convert --keep-aspect-ratio --format pdf %q --output %q", filename, outfile))
            elem["src"] = outfile
            return elem
        end,
    }
}
