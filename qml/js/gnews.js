.pragma library

// Copyright 2011 Martin Borho <martin@borho.net>
// GPL2 - see license.txt for details

var Gnews = function() {
    this.api_base = 'http://ajax.googleapis.com/ajax/services/search/news?v=1.0&rsz=large',
    this.ned = 'de',
    this.page = 1,
    this.offset = 8,
    this.topic = '',
    this.query = '',

    this.test = function() {
        return this.name;
    }
}

Gnews.prototype.buildUrl = function() {
    var start = (this.page-1) * this.offset
    var url = this.api_base+'&ned='+this.ned+'&start='+start;
    if(this.query != '') {
        url += '&q='+encodeURIComponent(this.query);
    } else {
        url += '&topic='+encodeURIComponent(this.topic);
    }
    return url;
}

Gnews.prototype.doRequest = function(callbackFunc, page) {
    var url = this.buildUrl();
    console.log(url)
    var xmlHttp = new XMLHttpRequest();
    if (xmlHttp) {
        xmlHttp.open('GET', url, true);
        xmlHttp.onreadystatechange = function () {
            if (xmlHttp.readyState == 4) {
                var responseText = xmlHttp.responseText.replace(/^\ ?\(/, '').replace(/\)$/, '');
                var myJSON = JSON.parse(responseText);
                callbackFunc(myJSON);
            }
        };
        xmlHttp.send(null);
    }
}

var gnewsColors = {
  "h":"#6B90DA",
  "w":"#FFC300",
  "n":"#3C3CA4",
  "b":"#007300",
  "t":"#CC0000",
  "p":"#27559B",
  "e":"#8A60B3",
  "s":"#FF6600",
  "m":"#438988",
  "ir":"#00A65E",
  "po":"#BC1748",
}

var gnewsEditions = {
    "us" : {
        ned : "us",
        name : "United States",
        more : "More sources",
        topics : [
            {label: "Top Stories", value: "h"},
            {label: "World", value: "w"},
            {label: "U.S.", value: "n"},
            {label: "Business", value: "b"},
            {label: "Science/Technology", value: "t"},
            {label: "Politics", value: "p"},
            {label: "Entertainment", value: "e"},
            {label: "Sports", value: "s"},
            {label: "Health", value: "m"},
            {label: "Spotlight", value: "ir"},
            {label: "Most Popular", value: "po"}
        ]
    },
    "uk" : {
        ned : "uk",
        name : "United Kingdom",
        more : "More sources",
        topics : [
            {label: "Top Stories", value: "h"},
            {label: "World", value: "w"},
            {label: "U.K.", value: "n"},
            {label: "Business", value: "b"},
            {label: "Science/Technology", value: "t"},
            {label: "Politics", value: "p"},
            {label: "Entertainment", value: "e"},
            {label: "Sports", value: "s"},
            {label: "Health", value: "m"},
            {label: "Spotlight", value: "ir"},
            {label: "Most Popular", value: "po"}
        ]
    },
    "ca" : {
        ned : "ca",
        name : "Canada English",
        more : "More sources",
        topics : [
            {label: "Top Stories", value: "h"},
            {label: "World", value: "w"},
            {label: "Canada", value: "n"},
            {label: "Business", value: "b"},
            {label: "Science/Technology", value: "t"},
            {label: "Politics", value: "p"},
            {label: "Entertainment", value: "e"},
            {label: "Sports", value: "s"},
            {label: "Health", value: "m"},
            {label: "Spotlight", value: "ir"},
            {label: "Most Popular", value: "po"}
        ]
    },
    "fr_ca" : {
        ned : "fr_ca",
        name : "Canada Français",
        more : "Plus de sources",
        topics : [
            {label: "À la une", value: "h"},
            {label: "International", value: "w"},
            {label: "Canada", value: "n"},
            {label: "Économie", value: "b"},
            {label: "Science/Tech  ", value: "t"},
            {label: "Politique", value: "p"},
            {label: "Divertissements", value: "e"},
            {label: "Sports", value: "s"},
            {label: "Santé", value: "m"},
            {label: "À lire", value: "ir"},
            {label: "Articles les plus lus", value: "po"},
        ]
    },
    "de" : {
        ned : "de",
        name : "Deutschland",
        more : "Mehr Quellen",
        topics : [
            {label: "Schlagzeilen", value: "h"},
            {label: "International", value: "w"},
            {label: "Deutschland", value: "n"},
            {label: "Wirtschaft", value: "b"},
            {label: "Wissen/Technik", value: "t"},
            {label: "Politik", value: "p"},
            {label: "Unterhaltung", value: "e"},
            {label: "Sport", value: "s"},
            {label: "Gesundheit", value: "m"},
            {label: "Panorama", value: "ir"},
            {label: "Meistgeklickt", value: "po"},
        ]
    },
    "de_at" : {
        ned : "de_at",
        name : "Österreich",
        more : "Mehr Quellen",
        topics : [
            {label: "Schlagzeilen", value: "h"},
            {label: "International", value: "w"},
            {label: "Österreich", value: "n"},
            {label: "Wirtschaft", value: "b"},
            {label: "Wissen/Technik", value: "t"},
            {label: "Politik", value: "p"},
            {label: "Unterhaltung", value: "e"},
            {label: "Sport", value: "s"},
            {label: "Gesundheit", value: "m"},
            {label: "Panorama", value: "ir"},
            {label: "Meistgeklickt", value: "po"},
        ]
    },
    "de_ch" : {
        ned : "de_ch",
        name : "Schweiz",
        more : "Mehr Quellen",
        topics : [
            {label: "Schlagzeilen", value: "h"},
            {label: "International", value: "w"},
            {label: "Schweiz", value: "n"},
            {label: "Wirtschaft", value: "b"},
            {label: "Wissen/Technik", value: "t"},
            {label: "Politik", value: "p"},
            {label: "Unterhaltung", value: "e"},
            {label: "Sport", value: "s"},
            {label: "Gesundheit", value: "m"},
            {label: "Panorama", value: "ir"},
            {label: "Meistgeklickt", value: "po"},
        ]
    },
    "fr_ch" : {
        ned : "fr_ch",
        name : "Suisse",
        more : "Plus de sources",
        topics : [
            {label: "À la une", value: "h"},
            {label: "International", value: "w"},
            {label: "Suisse", value: "n"},
            {label: "Économie", value: "b"},
            {label: "Science/Tech  ", value: "t"},
            {label: "Politique", value: "p"},
            {label: "Divertissements", value: "e"},
            {label: "Sports", value: "s"},
            {label: "Santé", value: "m"},
            {label: "À lire", value: "ir"},
            {label: "Articles les plus lus", value: "po"},
        ]
    },
    "fr" : {
        ned : "fr",
        name : "France",
        more : "Plus de sources",
        topics : [
            {label: "À la une", value: "h"},
            {label: "International", value: "w"},
            {label: "France", value: "n"},
            {label: "Économie", value: "b"},
            {label: "Science/Tech  ", value: "t"},
            {label: "Politique", value: "p"},
            {label: "Divertissements", value: "e"},
            {label: "Sports", value: "s"},
            {label: "Santé", value: "m"},
            {label: "À lire", value: "ir"},
            {label: "Articles les plus lus", value: "po"},
        ]
    },
    "nl_nl" : {
        ned : "nl_nl",
        name : "Nederland",
        more : "Meer bronnen",
        topics : [
            {label: "Voorpaginanieuws", value: "h"},
            {label: "Buitenland", value: "w"},
            {label: "Nederland", value: "n"},
            {label: "Zakelijk", value: "b"},
            {label: "Wetenschap/techniek", value: "t"},
            {label: "Politiek", value: "p"},
            {label: "Entertainment", value: "e"},
            {label: "Sport", value: "s"},
            {label: "Gezondheid", value: "m"},
            {label: "Spotlight", value: "ir"},// None
            {label: "Meest gelezen", value: "po"}
        ]
    },
    "nl_be" : {
        ned : "nl_be",
        name : "België",
        more : "Meer bronnen",
        topics : [
            {label: "Voorpaginanieuws", value: "h"},
            {label: "Buitenland", value: "w"},
            {label: "België", value: "n"},
            {label: "Zakelijk", value: "b"},
            {label: "Wetenschap/techniek", value: "t"},
            {label: "Politiek", value: "p"},
            {label: "Entertainment", value: "e"},
            {label: "Sport", value: "s"},
            {label: "Gezondheid", value: "m"},
            {label: "Spotlight", value: "ir"},//None
            {label: "Meest gelezen", value: "po"}
        ]
    },
    "fr_be" : {
        ned : "fr_be",
        name : "Belgique",
        more : "Plus de sources",
        topics : [
            {label: "À la une", value: "h"},
            {label: "International", value: "w"},
            {label: "Belgique", value: "n"},
            {label: "Économie", value: "b"},
            {label: "Science/Tech  ", value: "t"},
            {label: "Politique", value: "p"},
            {label: "Divertissements", value: "e"},
            {label: "Sports", value: "s"},
            {label: "Santé", value: "m"},
            {label: "À lire", value: "ir"}, // None
            {label: "Articles les plus lus", value: "po"},
        ]
    },
    "es" : {
        ned : "es",
        name : "España",
        more : "Más fuentes",
        topics : [
            {label: "Noticias destacadas", value: "h"},
            {label: "Internacional", value: "w"},
            {label: "España", value: "n"},
            {label: "Economía", value: "b"},
            {label: "Ciencia y Tecnología", value: "t"},
            {label: "Política", value: "p"},
            {label: "Espectáculos", value: "e"},
            {label: "Deportes", value: "s"},
            {label: "Salud", value: "m"},
            {label: "Destacados", value: "ir"},
            {label: "Más popular", value: "po"},
        ]
    },
    "pt-PT_pt" : {
        ned : "pt-PT_pt",
        name : "Portugal",
        more : "Mais fontes",
        topics : [
            {label: "Notícias principais", value: "h"},
            {label: "Mundo", value: "w"},
            {label: "Portugal", value: "n"},
            {label: "Negócios", value: "b"},
            {label: "Ciência", value: "t"},
            {label: "Política", value: "p"},
            {label: "Entretenimento", value: "e"},
            {label: "Desporto", value: "s"},
            {label: "Saúde", value: "m"},
            {label: "Em foco", value: "ir"},//None
            {label: "Mais populares", value: "po"}
        ]
    },
    "it" : {
        ned : "it",
        name : "Italia",
        more : "Altre fonti",
        topics : [
            {label: "Prima pagina", value: "h"},
            {label: "Esteri", value: "w"},
            {label: "Italia", value: "n"},
            {label: "Economia", value: "b"},
            {label: "Scienza e tecnologia", value: "t"},
            {label: "Politica", value: "p"},
            {label: "Spettacoli", value: "e"},
            {label: "Sport", value: "s"},
            {label: "Salute", value: "m"},
            {label: "In evidenza", value: "ir"},
            {label: "Più letti", value: "po"},
        ]
    },
    "en_ie" : {
        ned : "en_ie",
        name : "Ireland",
        more : "More sources",
        topics : [
            {label: "Top Stories", value: "h"},
            {label: "World", value: "w"},
            {label: "Ireland", value: "n"},
            {label: "Business", value: "b"},
            {label: "Science/Technology", value: "t"},
            {label: "Politics", value: "p"},
            {label: "Entertainment", value: "e"},
            {label: "Sports", value: "s"},
            {label: "Health", value: "m"},
            {label: "Spotlight", value: "ir"},
            {label: "Most Popular", value: "po"}
        ]
    },
    "sv_se" : {
        ned : "sv_se",
        name : "Sverige",
        more : "Flera källor",
        topics : [
            {label: "Huvudnyheter", value: "h"},
            {label: "Världen", value: "w"},
            {label: "Sverige", value: "n"},
            {label: "Ekonomi", value: "b"},
            {label: "Vetenskap & teknik", value: "t"},
            {label: "Politik", value: "p"},
            {label: "Nöje", value: "e"},
            {label: "Sport", value: "s"},
            {label: "Hälsa", value: "m"},
            {label: "I rampljuset", value: "ir"},
            {label: "Populärast", value: "po"}
        ]
    },
    "no_no" : {
        ned : "no_no",
        name : "Norge",
        more : "Flere kilder",
        topics : [
            {label: "Hovedoppslag", value: "h"},
            {label: "Utenriks", value: "w"},
            {label: "Innenriks", value: "n"},
            {label: "Næringsliv", value: "b"},
            {label: "Vitenskap/teknologi", value: "t"},
            {label: "Politikk", value: "p"},
            {label: "Underholdning", value: "e"},
            {label: "Sport", value: "s"},
            {label: "Helse", value: "m"},
            {label: "I søkelyset", value: "ir"},
            {label: "Mest populære", value: "po"}
        ]
    },
    "pl_pl" : {
        ned : "pl_pl",
        name : "Polska",
        more : "Więcej źródeł",
        topics : [
            {label: "Najważniejsze artykuły", value: "h"},
            {label: "Ze świata", value: "w"},
            {label: "Polska", value: "n"},
            {label: "Gospodarka", value: "b"},
            {label: "Nauka/technika", value: "t"},
            {label: "Polityka", value: "p"},
            {label: "Rozrywka", value: "e"},
            {label: "Sport", value: "s"},
            {label: "Zdrowie", value: "m"},
            {label: "I rampljuset", value: "ir"},
            {label: "Najpopularniejsze", value: "po"}
        ]
    },
    "cs_cz" : {
        ned : "cs_cz",
        name : "Česká republika",
        more : "Další zdroje",
        topics : [
            {label: "Hlavní události", value: "h"},
            {label: "Svět", value: "w"},
            {label: "Domov", value: "n"},
            {label: "Podnikání", value: "b"},
            {label: "Věda/technika", value: "t"},
            {label: "Politika", value: "p"},
            {label: "Kultura", value: "e"},
            {label: "Sport", value: "s"},
            {label: "Zdraví", value: "m"},
            {label: "Stále aktuální", value: "ir"},
            {label: "Nejoblíbenější", value: "po"}
        ]
    },
    "hu_hu" : {
        ned : "hu_hu",
        name : "Magyarország",
        more : "További források",
        topics : [
            {label: "Vezető hírek", value: "h"},
            {label: "Nemzetközi", value: "w"},
            {label: "Magyarország", value: "n"},
            {label: "Üzleti élet", value: "b"},
            {label: "Tudomány/technológia", value: "t"},
            {label: "Politika", value: "p"},
            {label: "Szórakozás", value: "e"},
            {label: "Sport", value: "s"},
            {label: "Egészség", value: "m"},//None
            {label: "Reflektorfényben", value: "ir"},//None
            {label: "Legnépszerűbb témakörök", value: "po"}
        ]
    },
    "el_gr" : {
        ned : "el_gr",
        name : "Ελλάδα",
        more : "Περισσότερες πηγές",
        topics : [
            {label: "Κυριότερες ειδήσειςΚυριότερες ειδήσεις", value: "h"},
            {label: "Κόσμος", value: "w"},
            {label: "Ελλάδα", value: "n"},
            {label: "Εργασία", value: "b"},
            {label: "Επιστήμη και τεχνολογία", value: "t"},
            {label: "Πολιτική", value: "p"},
            {label: "Ψυχαγωγία", value: "e"},
            {label: "Αθλητικά", value: "s"},
            {label: "Υγεία", value: "m"},//None
            {label: "Αφιέρωμα", value: "ir"},//None
            {label: "Πιο Δημοφιλή", value: "po"}
        ]
    },
    "tr_tr" : {
        ned : "tr_tr",
        name : "Türkiye",
        more : "Daha fazla kaynak",
        topics : [
            {label: "En Çok Okunan Diğer Haberler", value: "h"},
            {label: "Dünya", value: "w"},
            {label: "Türkiye", value: "n"},
            {label: "İş", value: "b"},
            {label: "Bilim/Teknoloji", value: "t"},
            {label: "Politika", value: "p"},
            {label: "Eğlence", value: "e"},
            {label: "Spor", value: "s"},
            {label: "Sağlık", value: "m"},
            {label: "Dikkat Çekenler", value: "ir"},
            {label: "En Popüler", value: "po"}
        ]
    },
    "ru_ru" : {
        ned : "ru_ru",
        name : "Россия (Russia)",
        more : "Дополнительные ресурсы ",
        topics : [
            {label: "Главные новости", value: "h"},
            {label: "В мире", value: "w"},
            {label: "Россия", value: "n"},
            {label: "Бизнес", value: "b"},
            {label: "Наука и техника", value: "t"},
            {label: "Политика", value: "p"},
            {label: "Культура", value: "e"},
            {label: "Спорт", value: "s"},
            {label: "Здоровье", value: "m"},
            {label: "Обзор", value: "ir"},
            {label: "Самые популярные", value: "po"}
        ]
    },
     "es_us" : {
        ned : "es_us",
        name : "Estados Unidos",
        more : "Más fuentes",
        topics : [
            {label: "Noticias destacadas", value: "h"},
            {label: "Internacional", value: "w"},
            {label: "Estados Unidos", value: "n"},
            {label: "Economía", value: "b"},
            {label: "Ciencia y Tecnología", value: "t"},
            {label: "Política", value: "p"},
            {label: "Espectáculos", value: "e"},
            {label: "Deportes", value: "s"},
            {label: "Salud", value: "m"},
            {label: "Destacados", value: "ir"},
            {label: "Más popular", value: "po"},
        ]
    },
    "es_mx" : {
        ned : "es_mx",
        name : "México",
        more : "Más fuentes",
        topics : [
            {label: "Noticias destacadas", value: "h"},
            {label: "Internacional", value: "w"},
            {label: "España", value: "n"},
            {label: "Economía", value: "b"},
            {label: "Ciencia y Tecnología", value: "t"},
            {label: "Política", value: "p"},
            {label: "Espectáculos", value: "e"},
            {label: "Deportes", value: "s"},
            {label: "Salud", value: "m"},
            {label: "Destacados", value: "ir"},
            {label: "Más popular", value: "po"},
        ]
    },
    "es_ar" : {
        ned : "es_ar",
        name : "Argentina",
        more : "Más fuentes",
        topics : [
            {label: "Noticias destacadas", value: "h"},
            {label: "Internacional", value: "w"},
            {label: "Argentina", value: "n"},
            {label: "Economía", value: "b"},
            {label: "Ciencia y Tecnología", value: "t"},
            {label: "Política", value: "p"},
            {label: "Espectáculos", value: "e"},
            {label: "Deportes", value: "s"},
            {label: "Salud", value: "m"},
            {label: "Destacados", value: "ir"},
            {label: "Más popular", value: "po"},
        ]
    },
    "pt-BR_br" : {
        ned : "pt-BR_br",
        name : "Brasil",
        more : "Mais fontes",
        topics : [
            {label: "Notícias principais", value: "h"},
            {label: "Mundo", value: "w"},
            {label: "Brasil", value: "n"},
            {label: "Negócios", value: "b"},
            {label: "Ciência/Tecnologia", value: "t"},
            {label: "Política", value: "p"},
            {label: "Entretenimento", value: "e"},
            {label: "Esportes", value: "s"},
            {label: "Saúde", value: "m"},
            {label: "Em destaque", value: "ir"},//None
            {label: "Mais populares", value: "po"}
        ]
    },
    "en_za" : {
        ned : "en_za",
        name : "South Africa",
        more : "More sources",
        topics : [
            {label: "Top Stories", value: "h"},
            {label: "World", value: "w"},
            {label: "South Africa", value: "n"},
            {label: "Business", value: "b"},
            {label: "Sci/Tech", value: "t"},
            {label: "Politics", value: "p"},
            {label: "Entertainment", value: "e"},
            {label: "Sports", value: "s"},
            {label: "Health", value: "m"},
            {label: "Spotlight", value: "ir"},
            {label: "Most Popular", value: "po"}
        ]
    },
    "au" : {
        ned : "au",
        name : "Australia",
        more : "More sources",
        topics : [
            {label: "Top Stories", value: "h"},
            {label: "World", value: "w"},
            {label: "Australia", value: "n"},
            {label: "Business", value: "b"},
            {label: "Science/Technology", value: "t"},
            {label: "Politics", value: "p"},
            {label: "Entertainment", value: "e"},
            {label: "Sports", value: "s"},
            {label: "Health", value: "m"},
            {label: "Spotlight", value: "ir"},
            {label: "Most Popular", value: "po"}
        ]
    },
    "nz" : {
        ned : "nz",
        name : "New Zealand",
        more : "More sources",
        topics : [
            {label: "Top Stories", value: "h"},
            {label: "World", value: "w"},
            {label: "New Zealand", value: "n"},
            {label: "Business", value: "b"},
            {label: "Sci/Tech", value: "t"},
            {label: "Politics", value: "p"},
            {label: "Entertainment", value: "e"},
            {label: "Sports", value: "s"},
            {label: "Health", value: "m"},
            {label: "Spotlight", value: "ir"},
            {label: "Most Popular", value: "po"}
        ]
    },
    "jp" : {
        ned : "jp",
        name : "日本 (Japan)",
        more : "提供元をもっと表示",
        topics : [
            {label: "トップニュース", value: "h"},
            {label: "国際", value: "w"},
            {label: "国内", value: "n"},
            {label: "ビジネス", value: "b"},
            {label: "テクノロジー", value: "t"},
            {label: "政治", value: "p"},
            {label: "エンタメ", value: "e"},
            {label: "スポーツ", value: "s"},
            {label: "健康 ", value: "m"},
            {label: "ピックアップ", value: "ir"},
            {label: "話題のニュース", value: "po"}
        ]
    },
    "cn" : {
        ned : "cn",
        name : "中国版 (China)",
        more : "更多来源",
        topics : [
            {label: "更多焦点新闻", value: "h"},
            {label: "国际/港台", value: "w"},
            {label: "内地", value: "n"},
            {label: "财经", value: "b"},
            {label: "科技", value: "t"},
            {label: "政治", value: "p"},
            {label: "娱乐", value: "e"},
            {label: "体育", value: "s"},
            {label: "健康", value: "m"},
            {label: "特别关注", value: "ir"},
            {label: "热门报道", value: "po"}
        ]
    },
    "hk" : {
        ned : "hk",
        name : "香港版 (Hong Kong)",
        more : "更多新聞來源 ",
        topics : [
            {label: "焦點新聞", value: "h"},
            {label: "國際", value: "w"},
            {label: "香港", value: "n"},
            {label: "財經", value: "b"},
            {label: "科技", value: "t"},
            {label: "政治", value: "p"},
            {label: "娛樂", value: "e"},
            {label: "體育", value: "s"},
            {label: "健康", value: "m"},
            {label: "焦點新聞 ", value: "ir"},
            {label: "熱門", value: "po"}
        ]
    },
    "tw" : {
        ned : "tw",
        name : "台灣版 (Taiwan)",
        more : "更多新聞來源",
        topics : [
            {label: "焦點新聞", value: "h"},
            {label: "國際", value: "w"},
            {label: "台灣", value: "n"},
            {label: "財經", value: "b"},
            {label: "科技", value: "t"},
            {label: "政治", value: "p"},
            {label: "娛樂", value: "e"},
            {label: "體育", value: "s"},
            {label: "健康", value: "m"},
            {label: "焦點新聞", value: "ir"},//none
            {label: "熱門", value: "po"}
        ]
    },
//    "kr" : {
//        ned : "kr",
//        name : "한국 (Korea)",
//        more : "자세히 보기",
//        topics : [
//            {label: "주요 뉴스", value: "h"},
//            {label: "국제", value: "w"},
//            {label: "한국 ", value: "n"},
//            {label: "경제", value: "b"},
//            {label: "정보과학", value: "t"},
//            {label: "정치", value: "p"},
//            {label: "연예", value: "e"},
//            {label: "스포츠", value: "s"},
//            {label: "건강", value: "m"},//None
//            {label: "관심뉴스", value: "ir"},//None
//            {label: "인기뉴스", value: "po"}
//        ]
//    },
}

var confTopics = [
    {label: "Top Stories", value: "h"},
    {label: "World", value: "w"},
    {label: "National", value: "n"},
    {label: "Business", value: "b"},
    {label: "Science/Technology", value: "t"},
    {label: "Politics", value: "p"},
    {label: "Entertainment", value: "e"},
    {label: "Sports", value: "s"},
    {label: "Health", value: "m"},
    {label: "Spotlight", value: "ir"},
    {label: "Most Popular", value: "po"}
    ]

function getEditionLabel(edition) {
  return gnewsEditions[edition].name;
}

function getEditionList() {
    var result = [];
    for(var e in gnewsEditions) {
       result.push({label: gnewsEditions[e].name, value: gnewsEditions[e].ned});
    }
    return result;
}

function getEditionTopics(edition) {
   return gnewsEditions[edition].topics;
}

function getTopicColor(topic) {
   return gnewsColors[topic];
}

function getTopicLabel(edition, topic) {
  for(var t in gnewsEditions[edition].topics) {
     if(gnewsEditions[edition].topics[t].value == topic) {
         return gnewsEditions[edition].topics[t].label;
     }
  }
  return 'News';
}

function getConfTopicLabel(topic) {
    var max = confTopics.length
    for(var x=0;max > x;x++) {
        if(topic == confTopics[x].value) {
            return confTopics[x].label
        }
    }
    return 'News';
}
