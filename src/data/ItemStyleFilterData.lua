local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext
local logger = AGS.internal.logger

local NEXT_UNASSIGNED_STYLE_ID = 145
local ICON_SIZE = "100%"

local isValidStyleId = {}
for itemStyleIndex = 1, GetNumValidItemStyles() do
    local validItemStyleId = GetValidItemStyleId(itemStyleIndex)
    if(validItemStyleId > 0) then
        isValidStyleId[validItemStyleId] = true
    end
end

local newStyles = {
    135, -- Y'ffre's Will
    138, -- Firesong
    139, -- House Mornard
    140, -- Scribes of Mora
    141, -- Blessed Inheritor
    142, -- Clan Dreamcarver
    143, -- Dead Keeper
    144, -- Kindred's Concord
}
-- automatically fill in new styles if there are any
for styleId = NEXT_UNASSIGNED_STYLE_ID, GetHighestItemStyleId() do
    newStyles[#newStyles + 1] = styleId
end

local function GetFormattedCategoryName(collectibleId)
    return zo_strformat("<<1>>", GetCollectibleName(collectibleId))
end

local styleCategories = {
    {
        label = gettext("Racial"),
        values = {
            1, -- Breton
            2, -- Redguard
            3, -- Orc
            4, -- Dark Elf
            5, -- Nord
            6, -- Argonian
            7, -- High Elf
            8, -- Wood Elf
            9, -- Khajiit
            14, -- Dwemer
            15, -- Ancient Elf
            17, -- Barbaric
            19, -- Primal
            20, -- Daedric
            22, -- Ancient Orc
            29, -- Xivkyn
            30, -- Soul Shriven
            33, -- Akaviri
            34, -- Imperial
        },
    },
    {
        label = gettext("Uncommon"),
        values = {
            13, -- Malacath
            16, -- Order of the Hour
            21, -- Trinimac
            27, -- Celestial
            28, -- Glass
            31, -- Draugr
            35, -- Yokudan
            36, -- Universal
            39, -- Minotaur
            40, -- Ebony
            44, -- Ra Gada
            45, -- Dro-m'Athra
            56, -- Silken Ring
            57, -- Mazzatun
        },
    },
    {
        label = gettext("Organizations"),
        values = {
            11, -- Thieves Guild
            12, -- Dark Brotherhood
            23, -- Daggerfall Covenant
            24, -- Ebonheart Pact
            25, -- Aldmeri Dominion
            26, -- Mercenary
            41, -- Abah's Watch
            46, -- Assassins League
            47, -- Outlaw
        },
    },
    {
        label = gettext("Events"),
        values = {
            38, -- Tsaesci
            42, -- Skinchanger
            53, -- Frostcaster
            58, -- Grim Harlequin
            59, -- Hollowjack
            55, -- Worm Cult
            74, -- Dremora
        },
    },
    {
        label = GetFormattedCategoryName(593), -- "Morrowind"
        values = {
            43, -- Morag Tong
            52, -- Buoyant Armiger
            54, -- Ashlander
            50, -- Militant Ordinator
            51, -- Telvanni
            49, -- Hlaalu
            48, -- Redoran
            60, -- Refabricated
            61, -- Bloodforge
            62, -- Dreadhorn
            65, -- Apostle
            66, -- Ebonshadow
        },
    },
    {
        label = GetFormattedCategoryName(5107), -- "Summerset"
        values = {
            69, -- Fang Lair
            70, -- Scalecaller
            71, -- Psijic Order
            72, -- Sapiarch
            75, -- Pyandonean
            73, -- Welkynar
            77, -- Huntsman
            78, -- Silver Dawn
            80, -- Honor Guard
            79, -- Dead-Water
            81, -- Elder Argonian
        },
    },
    {
        label = GetFormattedCategoryName(5843), -- "Elsweyr"
        values = {
            82, -- Coldsnap
            83, -- Meridian
            84, -- Anequina
            85, -- Pellitine
            86, -- Sunspire
            89, -- Stags of Z'en
            93, -- Moongrave Fane
            92, -- Dragonguard
            95, -- Shield of Senchal
            94, -- New Moon Priest
        },
    },
    {
        label = GetFormattedCategoryName(7466), -- "Greymoor"
        values = {
            97, -- Icereach Coven
            98, -- Pyre Watch
            103, -- Ancestral Nord
            105, -- Ancestral Orc
            104, -- Ancestral High Elf
            100, -- Blackreach Vanguard
            101, -- Greymoor
            102, -- Sea Giant
            106, -- Thorn Legion
            107, -- Hazardous Alchemy
            110, -- Ancestral Reach
            111, -- Nighthollow
            112, -- Arkthzand Armory
            113, -- Wayward Guardian
        },
    },
    {
        label = GetFormattedCategoryName(8659), -- "Blackwood"
        values = {
            108, -- Ancestral Akaviri
            121, -- Ivory Brigade
            122, -- Sul-Xan
            120, -- Black Fin Legion
            117, -- Waking Flame
            116, -- True-Sworn
            114, -- House Hexos
            119, -- Ancient Daedric
            123, -- Crimson Oath
            124, -- Silver Rose
        },
    },
    {
        label = GetFormattedCategoryName(10053), -- "High Isle"
        values = {
            125, -- Annihilarch's Chosen
            126, -- Fargrave Guardian
            129, -- Ascendant Order
            128, -- Dreadsails
            131, -- Steadfast Society
            109, -- Ancestral Breton
            130, -- Syrabanic Marine
            132, -- Systres Guardian
            136, -- Drowned Mariner
        },
    },
    {
        label = gettext("New"),
        values = newStyles,
    },
}

local STYLE_CATEGORIES = {}
for _, category in ipairs(styleCategories) do
    local validStyles = {}
    for _, styleId in ipairs(category.values) do
        if(isValidStyleId[styleId]) then
            local name = zo_strformat("<<1>>", GetItemStyleName(styleId))
            local icon = GetItemLinkIcon(GetItemStyleMaterialLink(styleId))
            local label = zo_iconTextFormat(icon, ICON_SIZE, ICON_SIZE, name)
            validStyles[#validStyles + 1] = {
                parent = category,
                id = styleId,
                label = label,
                fullLabel = label,
                sortIndex = name,
            }
        else
            logger:Debug("Detected use of invalid style id '%d' (%s) in category '%s'", styleId, GetItemStyleName(styleId), category.label)
        end
        isValidStyleId[styleId] = nil
    end
    category.values = validStyles
    if #validStyles > 0 then
        STYLE_CATEGORIES[#STYLE_CATEGORIES + 1] = category
    end
end

for styleId in pairs(isValidStyleId) do
    logger:Debug("Detected unused style id '%d' (%s)", styleId, GetItemStyleName(styleId))
end

AwesomeGuildStore.data.STYLE_CATEGORIES = STYLE_CATEGORIES
