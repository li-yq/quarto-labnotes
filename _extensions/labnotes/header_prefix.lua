function Pandoc(doc)
    local header = pandoc.Header(1, "Note: " .. pandoc.utils.stringify(doc.meta["title"]))
    doc.blocks:insert(1, header)
    return doc
end
