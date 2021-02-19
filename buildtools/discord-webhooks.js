const fetch = require("node-fetch")
const { Webhook, MessageBuilder } = require('discord-webhook-node');

const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET || process.argv[0]

console.log(WEBHOOK_SECRET)

const hook = new Webhook(`https://discord.com/api/webhooks/${WEBHOOK_SECRET}`);

let main = async () => {
    let res = await fetch("https://api.github.com/repos/Seniru/pewpew/releases/latest")
    let releaseInfo = await res.json()

    const embed = new MessageBuilder()
        .setTitle(`New release ${releaseInfo.tag_name}`)
        .setAuthor(releaseInfo.author.login, releaseInfo.author.avatar_url, releaseInfo.author.html_url)
        .setURL(releaseInfo.url)
        .setColor("#00b0f4")
        .setDescription(`**${releaseInfo.name}**\n\n${releaseInfo.body}`)
        .addField("Pre-release", releaseInfo.prerelease ? ":white_check_mark:" : ":x:", true)
        .addField("Assets", releaseInfo.assets_url, true)
        .setFooter("Published at")
        .setTimestamp(releaseInfo.published_at);
 
hook.send(embed);
}

main()
 
 
