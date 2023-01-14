// Source : https://github.com/GreepTheSheep/openplanet-maniaexchange-menu/blob/main/src/Utils/API.as
namespace API
{
    Net::HttpRequest@ DeclareHttpRequest(const string &in url, Net::HttpMethod method, const bool isApi, const string &in body = "")
    {
        auto ret = Net::HttpRequest();
        ret.Method = method;
        ret.Url = url;
        ret.Headers.Set("Content-Type", "application/json");
        Log::Trace(tostring(method) + ": " + url);
        if(body != "") {
            ret.Body = body;
            Log::Trace("Body: " + body);
        }
        if(isApi) {
            ret.Headers.Set("X-AuthKey", accessToken);
            ret.Headers.Set("X-GameId", tostring(GAME_ID));
        }
        ret.Start();
        return ret;
    }
    Net::HttpRequest@ Get(const string &in url)
    {
        return DeclareHttpRequest(url, Net::HttpMethod::Get, false);
    }

    Net::HttpRequest@ GetFromApi(const string &in url)
    {
        return DeclareHttpRequest(url, Net::HttpMethod::Get, true);
    }

    Json::Value GetAsync(const string &in url)
    {
        auto req = Get(url);
        while (!req.Finished()) {
            yield();
        }
        return Json::Parse(req.String());
    }

    Json::Value GetFromApiAsync(const string &in url)
    {
        auto req = GetFromApi(url);
        while (!req.Finished()) {
            yield();
        }
        Log::Trace("Result: " + req.String());
        auto json = Json::Parse(req.String());
        catchError(req, json);
        return json;
    }

    Net::HttpRequest@ Post(const string &in url, const string &in body)
    {
        return DeclareHttpRequest(url, Net::HttpMethod::Post, false, body);
    }

    Net::HttpRequest@ PostFromApi(const string &in url, const string &in body)
    {
        return DeclareHttpRequest(url, Net::HttpMethod::Post, true, body);
    }

    Json::Value PostFromApiAsync(const string &in url, const string &in body)
    {
        auto req = PostFromApi(url, body);
        while (!req.Finished()) {
            yield();
        }
        Log::Trace("Result: " + req.String());
        auto json = Json::Parse(req.String());
        catchError(req, json);
        return json;
    }

    Json::Value PostAsync(const string &in url, const string &in body)
    {
        auto req = Post(url, body);
        while (!req.Finished()) {
            yield();
        }
        return Json::Parse(req.String());
    }

    
    Net::HttpRequest@ DeleteFromApi(const string &in url, const string &in body)
    {
        return DeclareHttpRequest(url, Net::HttpMethod::Delete, true, body);
    }

    Json::Value DeleteFromApiAsync(const string &in url, const string &in body)
    {
        auto req = DeleteFromApi(url, body);
        while (!req.Finished()) {
            yield();
        }
        Log::Trace("Result: " + req.String());
        
        auto json = Json::Parse(req.String());
        catchError(req, json);
        return json;
    }

    void catchError(Net::HttpRequest@ req, Json::Value response) {
        if(req.ResponseCode() >= 400) {
            try {
                Log::Error(getError(response["error"]));
            } catch {
                Log::Error("Unexpected server error");
            }
        }
    }
}