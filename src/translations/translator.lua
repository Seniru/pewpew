local translate = function(term, language, page, kwargs)
    local translation
    if translations[lang] then 
        translation = translation[lang][term] or translation.en[term] 
    else
        translation = translation.en[term]
    end
    translation = page and translation[page] or translation
    if not translation then return end
    return string.format(translation, kwargs)
end
