function eventNewPlayer(name)
    Timer("banner", function(image)
        print(image)
        --tfm.exec.removeImage(image)
    end, 5000, false, 1)

end
