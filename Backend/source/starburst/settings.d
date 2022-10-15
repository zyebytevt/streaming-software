module starburst.settings;

import std.file;

import vibe.vibe;

struct Settings
{
public:
    struct OBSWebSocket
    {
        string host;
        ushort port;
        @optional string password;
    }

    struct Twitch
    {
        string clientID;
        string clientSecret;
    }

    OBSWebSocket obsWebSocket;
    Twitch twitch;

    static Settings loadFromFile(string fileName)
    {
        return deserializeJson!Settings(readText(fileName));
    }
}