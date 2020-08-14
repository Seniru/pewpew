const fs = require("fs")

const OUTPUT_FILE_LOC = "./index.lua"

module.exports = (segments) => {
    return new Promise((resolve, reject) => {
        let writer = fs.createWriteStream(OUTPUT_FILE_LOC)
        
        console.log("\x1b[1m\x1b[32m%s\x1b[0m", "Combining and Writing files...");
        
        writer.once("open", (fd) => {
            
            for (let type of Object.keys(segments)) {
                writer.write(`--==[[ ${type} ]]==--\n\n`)
                for (let filePath of segments[type].files) {
                    console.log(`\x1b[93mWriting ${filePath}`)
                    let chunk = fs.readFileSync(`./${filePath}`).toString()
                    writer.write((segments[type].prefix || "") + (segments[type].compressFunction ? segments[type].compressFunction(chunk) : chunk) + (segments[type].suffix || "\n"))
                }
                writer.write("\n")
            }
            writer.end()
            console.log("\x1b[1m\x1b[32m%s\x1b[0m", "Succesfully wrote the file!")
            resolve(true)
        })
    })
}
