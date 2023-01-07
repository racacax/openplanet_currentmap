// Source : https://github.com/GreepTheSheep/openplanet-maniaexchange-menu/blob/main/src/Utils/API.as
namespace API
{
    Net::HttpRequest@ Get(const string &in url)
    {
        auto ret = Net::HttpRequest();
        ret.Method = Net::HttpMethod::Get;
        ret.Url = url;
        Log::Trace("Get: " + url);
        ret.Start();
        return ret;
    }

    Net::HttpRequest@ GetFromApi(const string &in url)
    {
        auto ret = Net::HttpRequest();
        ret.Method = Net::HttpMethod::Get;
        ret.Url = url;
        Log::Trace("Get: " + url);
        ret.Headers.Set("X-AuthKey", accessToken);
        ret.Headers.Set("X-GameId", tostring(GAME_ID));
        ret.Start();
        return ret;
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
        auto ret = Net::HttpRequest();
        ret.Method = Net::HttpMethod::Post;
        ret.Url = url;
        ret.Body = body;
        ret.Headers.Set("Content-Type", "application/json");
        Log::Trace("Post: " + url);
        Log::Trace("Body: " + body);
        ret.Start();
        return ret;
    }

    Net::HttpRequest@ PostFromApi(const string &in url, const string &in body)
    {
        auto ret = Net::HttpRequest();
        ret.Method = Net::HttpMethod::Post;
        ret.Url = url;
        ret.Body = body;
        ret.Headers.Set("Content-Type", "application/json");
        Log::Trace("Post: " + url);
        Log::Trace("Body: " + body);
        ret.Headers.Set("X-AuthKey", accessToken);
        ret.Headers.Set("X-GameId", tostring(GAME_ID));
        ret.Start();
        return ret;
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
        auto ret = Net::HttpRequest();
        ret.Method = Net::HttpMethod::Delete;
        ret.Url = url;
        ret.Body = body;
        ret.Headers.Set("Content-Type", "application/json");
        Log::Trace("Post: " + url);
        Log::Trace("Body: " + body);
        ret.Headers.Set("X-AuthKey", accessToken);
        ret.Headers.Set("X-GameId", tostring(GAME_ID));
        ret.Start();
        return ret;
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