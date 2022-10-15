module starburst.subsystem.obs.client;

import std.exception : enforce;
import std.string : format;
import std.traits : getUDAs;

import starburst.subsystem.obs;
import vibe.vibe;

@safe:

final class OBSWebSocketClient
{
protected:
    WebSocket mSocket;

    /// Generates an authentication token, based on the description of the OBS Web Socket protocol
    string generateAuthentication(const ref string password, const ref SerializedHelloData.Authentication authentication)
    {
        import std.digest.sha : sha256Of;
        import std.base64 : Base64;

        immutable string secret = Base64.encode(sha256Of(password ~ authentication.salt));
        return Base64.encode(sha256Of(secret ~ authentication.challenge));
    }

public:
    struct ConnectArgs
    {
        string host = "localhost";
        ushort port = 4455;
        string password = "";
        EventSubscription eventSubscription = EventSubscription.all;
    }

    ~this()
    {
        if (mSocket)
            mSocket.close();
    }

    void connect(ConnectArgs args = ConnectArgs.init)
    {
        if (mSocket)
            return;

        mSocket = connectWebSocket(URL("ws", args.host, args.port, InetPath("/")));

        SerializedHelloData hello = receiveMessageData!SerializedHelloData();
        string authentication;

        // Server expects a password
        if (hello.authentication.challenge != "")
            authentication = generateAuthentication(args.password, hello.authentication);

        sendMessageData(SerializedIdentifyData(hello.rpcVersion, args.eventSubscription, authentication));

        SerializedIdentifiedData identified = receiveMessageData!SerializedIdentifiedData();
        if (identified.negotiatedRpcVersion != 1)
            logWarn("Negotiated RPC version other than 1.");
    }

    void disconnect()
    {
        if (mSocket)
        {
            mSocket.close();
            mSocket = null;
        }
    }

    WebSocketMessage receiveMessage()
    {
        // TODO: For some reason this doesn't work
        //enforce(mSocket.connected, new OBSSubSystemException(cast(WebSocketCloseCode) mSocket.closeCode));

        return deserializeJson!WebSocketMessage(parseJsonString(mSocket.receiveText()));
    }

    void sendMessage(WebSocketMessage frame)
    {
        mSocket.send(serializeToJson!WebSocketMessage(frame).toString());
    }

    T receiveMessageData(T)() @trusted
    {
        WebSocketOpCode op = getUDAs!(T, boundOpCode)[0].opCode;
        WebSocketMessage cmd = receiveMessage();
        enforce!OBSSubSystemException(cmd.op == op, format!"Expected '%s' command, got '%s' instead."(op, cmd.op));
        return deserializeJson!T(cmd.d);
    }

    void sendMessageData(T)(T data)
    {
        sendMessage(WebSocketMessage(getUDAs!(T, boundOpCode)[0].opCode, serializeToJson!T(data)));
    }
}