module obs.client;

import std.exception : enforce;
import std.string : format;
import std.traits : getUDAs;

import obs;
import vibe.vibe;

@trusted:

final class OBSWebSocketClient
{
private:
    WebSocket mSocket;

    string generateAuthentication(const ref OBSMessageDataHello.Authentication authentication)
    {
        import std.digest.sha;
        import std.base64;

        immutable string secret = Base64.encode(sha256Of(password ~ authentication.salt));
        return Base64.encode(sha256Of(secret ~ authentication.challenge));
    }

    void processHelloAndIdentify()
    {
        import std.stdio;

        OBSMessageDataHello hello = receiveData!OBSMessageDataHello();
        string authentication;

        // Server expects a password
        if (hello.authentication.challenge != "")
            authentication = generateAuthentication(hello.authentication);

        sendData(OBSMessageDataIdentify(hello.rpcVersion, eventSubscription, authentication));

        OBSMessageDataIdentified identified = receiveData!OBSMessageDataIdentified();
        if (identified.negotiatedRpcVersion != 1)
            logWarn("Negotiated RPC version other than 1.");
    }

public:
    string host = "localhost";
    ushort port = 4455;
    string password = "";
    OBSEventSubscription eventSubscription = OBSEventSubscription.all;

    ~this()
    {
        if (mSocket)
            mSocket.close();
    }

    void connect()
    {
        if (mSocket)
            return;

        mSocket = connectWebSocket(URL("ws", host, port, InetPath("/")));

        processHelloAndIdentify();
    }

    void disconnect()
    {
        if (mSocket)
        {
            mSocket.close();
            mSocket.destroy();
            mSocket = null;
        }
    }

    OBSMessage receiveMessage()
    {
        return deserializeJson!OBSMessage(parseJsonString(mSocket.receiveText()));
    }

    void sendMessage(OBSMessage frame)
    {
        mSocket.send(serializeToJson!OBSMessage(frame).toString());
    }

    T receiveData(T)()
    {
        OBSWebSocketOpCode op = getUDAs!(T, obsDataOpCode)[0].opCode;
        OBSMessage cmd = receiveMessage();
        enforce!OBSSubSystemException(cmd.op == op, format!"Expected '%s' command, got '%s' instead."(op, cmd.op));
        return deserializeJson!T(cmd.d);
    }

    void sendData(T)(T data)
    {
        sendMessage(OBSMessage(getUDAs!(T, obsDataOpCode)[0].opCode, serializeToJson!T(data)));
    }
}