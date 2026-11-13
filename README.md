Warning: truncated output (original token count: 7087)
Total output lines: 543

# PowerMoves RP — PM Emotes development note

PM Emotes is PowerMoves RP's QBCore/FiveM RPEmotes resource with a customized dark-and-blue NUI. It retains RPEmotes playback, search, categories, favorites, keybinds, shared/group emotes, placement, the in-game preview ped, and cancellation. The menu adds direct card actions, compact and draggable layout, per-category scroll restoration, and adjustment controls for supported active emotes. Its optional selected-emote preview panel consumes exports from [PowerMoves Development — EmotePreviewer](https://github.com/rpRIGGS/EmotePreviewer), a separate Windows desktop application; PM Emotes does not capture, render, or encode previews. Preview media is optional: without an export, the panel shows its placeholder and the RPEmotes menu remains usable. The interface is branded POWERMOVES in white and RP in #0438ff. Source regression tests pass; FiveM NUI/CEF behavior, APNG playback, multiplayer adjustment, and seating alignment still require live server acceptance. The former PM AutoShot integration has been retired.

Development decisions and live-test handoff: [NUI feature parity](development-reference/NUI-FEATURE-PARITY.md), [preview integration](development-reference/EMOTE-PREVIEWER-INTEGRATION.md), and [server acceptance checklist](development-reference/SERVER-TEST-ACCEPTANCE.md).

---

<img width="1920" height="1080" alt="rpemotesrebornbanner" src="https://github.com/user-attachments/assets/a515b5ed-da1b-45d4-9a1d-b83399ba9d17" />

Rpemotes-reborn is a community-driven FiveM emote menu allowing players to express themselves in roleplay with custom animations, countless facial expressions, walk styles, and props.

Rpemotes-reborn is free, **and will always be free**: accept no substitutes or reproductions from scummy people reselling other's hard work against agreements made with creators. We're committed to the open-source community and the dozens of contributors who put hard work into rpemotes to provide the community with free emotes and props.

Want to help support them? Check out our credits section at the bottom of the Readme and support those creators!

Interested in joining our community? You can find our Discord [here](https://discord.gg/UJ72w8rgar).

# Features 🛠️

- Emote Preview & Placement - View and place emotes before using them!

- Customizable Banner (Change the image, text, and text color)

- Emote Search Function 🔎

- Community contributed custom animations 🕺

- Group emotes: Dance, salute, and more with 2 or more people

- Exit Emotes: Exit out of emotes with smooth transitions

- Persistent Facial Expressions and Walkstyles via client KVP 

- Easily convert Menyoo to RPEmotes 🔄

- Hide Adult Emotes 🔞

- Hide Animal Emotes ⛔

- Animal Emotes 🐩

- Shared Particle Effects: emotes with smoke effects, fire, and more 💨

- QB-Core + ESX Framework & KVP Keybinding Support ⚙️

- Support for shared and couple poses/animations 👫

- Persistent Disabling Of Idle Camera via KVP 🎥

- Easy To Understand Configuration File ⚙️

- Props Extractor for anti-cheat scripts 💾

- Crouching 🐞

- Crawling 🐛

- Finger Pointing 👆

- Ragdoll 😵

- Hands up 🙌

- Working Binoculars 👀

- News Camera 🎤📹


**Available in the following languages:**

Albanian, Brazilian Portuguese, Chinese (Simplified), Chinese (Traditional), Czech, Danish, Dutch, English, Finnish, French, German, Greek, Hungarian, Indonesian, Italian, Lithuanian, Norwegian, Persian, Polish, Romanian, Russian, Serbian, Sinhala, Slovenian, Spanish, Swedish, Turkish, Vietnamese

Languages can be selected and/or added in the config.lua.

All languages were translated or contributed by the FiveM community, with the odd exception of using Google Translate.

English is the original language and will always be up to date with correct translations. Otherwise, German is currently the only translation which is complete and verified by a native speaker. Other translations might be incomplete or partially lacking in quality. English is used as a fallback for missing translations. Compare your language file to the English one to find and add missing translations.

If you find any incorrect translations or would like to add more languages, please make a pull request with the corrections.


# Exports and Documentation

Find our documentation [here](https://rpemotes-reborn.gitbook.io/guide)

The rpemotes-reborn resource has the following exports:

```lua
exports["rpemotes-reborn"]:EmoteCommandStart(emoteName, textureVariation) -- deprecated, prefer Execute() below
exports["rpemotes-reborn"]:Execute(emoteName, emoteType, textureVariation) -- plays any emote type through its native handler
exports["rpemotes-reborn"]:EmoteCancel(forceCancel) – forceCancel is optional
exports["rpemotes-reborn"]:IsPlayerCrouched()
exports["rpemotes-reborn"]:IsPlayerProne()
exports["rpemotes-reborn"]:StopPlayerProne(force) -- force is optional
exports["rpemotes-reborn"]:GetPlayerProneType() -- returns the type of prone the player is in, either "onfront" or "onback"
exports["rpemotes-reborn"]:IsPlayerCrawling()
exports["rpemotes-reborn"]:IsPlayerPointing()
exports["rpemotes-reborn"]:IsPlayerInAnim() -- returns current animation name or nil
exports["rpemotes-reborn"]:IsPlayerInHandsUp()
exports["rpemotes-reborn"]:toggleBinoculars()
exports["rpemotes-reborn"]:toggleNewscam()
exports["rpemotes-reborn"]:getWalkstyle() -- Gets walk style of player, used to detect certain walk. useful for applying effects while doing certain walks like tripping or other "funny" effects.
exports["rpemotes-reborn"]:setWalkstyle(name, force) -- name = "move_m@alien" or any other, force = optional bool. Lets you set or force a walk style, useful for scripts like retrieving a style before drinking and restoring it after sobering up.
exports["rpemotes-reborn"]:toggleWalkstyle(bool, message) -- bool to allow the user to change their walkstyle in the menu or not / message to show the user (opt…4087 tokens truncated…`. You must also add any custom addon peds to the `animals.lua` file in either category for these animations to be played on those models.

Whenever an update is released, rename `BackUpAnimationListCustom.lua` to `AnimationListCustom.lua`, click yes to overwrite, and you're good to go.

Note that `AnimationListCustom.lua` and `BackUpAnimationListCustom.lua` files from versions prior to version 1.5.0 are not compatible with version 1.5.0, and files from version 1.5.0 are not backwards compatible with versions prior to version 1.5.0. To retain any custom animation code from previous versions, copy over any customizations into the `AnimationListCustom.lua` file that is included in the current version.

It is also a good idea to keep a backup of your config file.
Below is an example:

<img src="screenshots/customanims.png" width="550">

# Credits 🤝

**All** custom animations and props were added with permission from the creators.

All animation creators have **_specifically_** asked that their content remain free and that the RPEmotes team and community do not try to profit from them, claim them as their own, or reupload them anywhere else.

**A huge thank you the following people for their amazing contributions to the menu:**

- the FiveM community for using RP and updating rpemotes-reborn!
### Developers:
- [The Popcorn RP community](https://discord.gg/popcornroleplay) for putting up with all my emote menu testing and troubleshooting issues with me
- [Mathu_lmn](https://github.com/Mathu-lmn) for maintaining the menu and adding features
- [Manason](https://github.com/Manason) for major overhauls, refactors, and improvements of rpemotes-reborn during push to 2.0
- [CritteRo](CritteRo) for work on shared emotes placement and other refactors and fixes of rpemotes-reborn during push to 2.0
- [ChristopherM](https://github.com/cm8263) for creation of the emote placement feature and fixes of rpemotes-reborn during push to 2.0
- [enzo2991](https://github.com/enzo2991) for creating the ped preview functionality, keybind with kvp
- [DerDevHD](https://forum.cfx.re/t/fixed-remove-prop-after-scenario-animation/5002332/8) for the insight on deleting scenario props.
- [iSentrie](https://forum.cfx.re/u/isentrie/) for additional code, support, and joining the RPEmotes project
- [Kibook](https://github.com/kibook) for the addition of the Animal Emotes sub-menu
- [AvaN0x](https://github.com/AvaN0x) for reformatting and assisting with code, additional features, and figuring out shared particle effects
- [Mads](https://github.com/MadsLeander) for joining the team as Co-Developer
- [Tigerle](https://forum.cfx.re/u/tigerle_studios) for providing the additional code required to make Shared Emotes work to its full extent
- [GeekGarage](https://github.com/geekgarage) for their knowledge, time, and dedication, helping to bring new and exciting features to the menu
- [northsqrd](https://github.com/0sqrd) for adding the search function, Animal Emotes config, mobile phone prop texture variants, and general contributions
- [Chico](https://forum.cfx.re/u/chico) for implementing natives to reapply persistent moods and walk styles for ESX and QB-Core frameworks
- [Scully](https://github.com/Scullyy/) for their past work on rpemotes
- Crusopaul and Eki for discussing KVP and initializing it to the menu for persistent walk styles

### Emote & Props Creators:
- [FalseHopeDesigns](https://falsehopedesigns.tebex.io/) for creation of collisionless props
- [SMGMissy](https://jenscreations.tebex.io/) for creating the pride flag props
- [MissSnowie](https://www.gta5-mods.com/users/MissySnowie)
- [Smokey](https://www.gta5-mods.com/users/struggleville)
- [BzZzi](https://forum.cfx.re/u/bzzzi/summary)
- [Natty3d](https://forum.cfx.re/u/natty3d/summary)
- [Amnilka](https://www.gta5-mods.com/users/frabi)
- [LittleSpoon](https://discord.gg/safeword)
- [LadyyShamrockk](https://www.gta5-mods.com/users/LadyyShamrockk)
- [Pupppy](https://discord.gg/rsN35X4s4N)
- [SapphireMods](https://discord.gg/Hf8F4nTyzt)
- [QueenSisters Animations](https://discord.gg/qbPtGwQuep)
- DurtyFree for his work on particle effects and cataloging GTA-related information [DurtyFree GTA V Dump](https://github.com/DurtyFree/gta-v-data-dumps/blob/master/particleEffectsCompact.json)
- [BoringNeptune](https://www.gta5-mods.com/users/BoringNeptune)
- [CMG Mods](https://www.gta5-mods.com/users/-moses-)
- [prue 颜](discord.gg/lunyxmods)
- [PataMods](https://forum.cfx.re/u/Pata_PataMods)
- [Crowded1337](https://www.gta5-mods.com/users/crowded1337)
- [EnchantedBrownie](https://www.gta5-mods.com/users/EnchantedBrownie)
- Chocoholic Animations
- [CrunchyCat](https://www.gta5-mods.com/users/crunchycat)
- [KayKayMods](https://discord.gg/5bYQVWVaxG)
- [MonkeyWhisper](https://github.com/MonkeyWhisper) and [Project Sloth](https://github.com/Project-Sloth)
- [Brummieee](https://forum.cfx.re/u/brummieee_maps/summary)
- [Dark Animations](https://www.gta5-mods.com/users/Darks%20Animations).
- [-EcLiPsE-](https://www.gta5-mods.com/users/-EcLiPsE-) for allowing me to implement [Improved Prop Sets](https://www.gta5-mods.com/misc/improved-propsets-meta) and [GTA Online Biker Idle Anims](https://www.gta5-mods.com/misc/bike-idle-animations)
- [MrWitt](https://www.gta5-mods.com/users/MrWitt)
- [Vedere](https://discord.gg/XMywAMQ8Ef)
- [DRX Animations](https://www.gta5-mods.com/users/DRX%2DAnimations)
- [VNSIanims](https://discord.gg/cTNrjYSXXG)
- [PNWParksFan](https://www.gta5-mods.com/users/PNWParksFan)
- [LSPDFR member Sam](https://www.lcpdfr.com/downloads/gta5mods/misc/23386-lspd-police-badge/)
- [GTA5Mods user Sladus_Slawonkus](https://www.gta5-mods.com/misc/lspd-police-badge-replace-sladus_slawonkus)
- [EP](https://github.com/EpKouhia)
- [TayMcKenzieNZ](https://github.com/TayMcKenzieNZ)
- [41anims](https://www.gta5-mods.com/users/41anims)
- [corbs](https://www.gta5-mods.com/users/corbs)
- [jaysigx](https://www.gta5-mods.com/misc/improved-umbrella)
- [Payzee](https://pazeee.tebex.io/)
