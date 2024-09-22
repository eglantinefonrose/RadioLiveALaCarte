export class RadioStation {
    changeuuid: string;
    stationuuid: string;
    serveruuid: string;
    name: string;
    url: string;
    url_resolved: string;
    homepage: string;
    favicon: string;
    tags: string;
    country: string;
    countrycode: string;
    iso_3166_2: string | undefined;
    state: string;
    language: string;
    languagecodes: string;
    votes: number;
    lastchangetime: string;
    lastchangetime_iso8601: string;
    codec: string;
    bitrate: number;
    hls: number;
    lastcheckok: number;
    lastchecktime: string;
    lastchecktime_iso8601: string;
    lastcheckoktime: string;
    lastcheckoktime_iso8601: string;
    lastlocalchecktime: string;
    lastlocalchecktime_iso8601: string;
    clicktimestamp: string;
    clicktimestamp_iso8601: string;
    clickcount: number;
    clicktrend: number;
    ssl_error: number;
    geo_lat: number;
    geo_long: number;
    has_extended_info: boolean;

    constructor(changeuuid: string, stationuuid: string, serveruuid: string,
        name: string,
        url: string,
        url_resolved: string,
        homepage: string,
        favicon: string,
        tags: string,
        country: string,
        countrycode: string,
        iso_3166_2: string,
        state: string,
        language: string,
        languagecodes: string,
        votes: number,
        lastchangetime: string,
        lastchangetime_iso8601: string,
        codec: string,
        bitrate: number,
        hls: number,
        lastcheckok: number,
        lastchecktime: string,
        lastchecktime_iso8601: string,
        lastcheckoktime: string,
        lastcheckoktime_iso8601: string,
        lastlocalchecktime: string,
        lastlocalchecktime_iso8601: string,
        clicktimestamp: string,
        clicktimestamp_iso8601: string,
        clickcount: number,
        clicktrend: number,
        ssl_error: number,
        geo_lat: number,
        geo_long: number,
        has_extended_info: boolean) {

            this.changeuuid = changeuuid;
            this.stationuuid = stationuuid;
            this.serveruuid = serveruuid;
            this.name = name;
            this.url = url;
            this.url_resolved = url_resolved;
            this.homepage = homepage;
            this.favicon = favicon;
            this.tags = tags;
            this.country = country;
            this.countrycode = countrycode;
            this.iso_3166_2 = iso_3166_2;
            this.state = state;
            this.language = language;
            this.languagecodes = languagecodes;
            this.votes = votes;
            this.lastchangetime = lastchangetime;
            this.lastchangetime_iso8601 = lastchangetime_iso8601;
            this.codec = codec;
            this.bitrate = bitrate;
            this.hls = hls;
            this.lastcheckok = lastcheckok;
            this.lastchecktime = lastchecktime;
            this.lastchecktime_iso8601 = lastchecktime_iso8601;
            this.lastcheckoktime = lastcheckoktime;
            this.lastcheckoktime_iso8601 = lastcheckoktime_iso8601;
            this.lastlocalchecktime = lastlocalchecktime;
            this.lastlocalchecktime_iso8601 = lastlocalchecktime_iso8601;
            this.clicktimestamp = clicktimestamp;
            this.clicktimestamp_iso8601 = clicktimestamp_iso8601;
            this.clickcount = clickcount;
            this.clicktrend = clicktrend;
            this.ssl_error = ssl_error;
            this.geo_lat = geo_lat;
            this.geo_long = geo_long;
            this.has_extended_info = has_extended_info;

        }

    }