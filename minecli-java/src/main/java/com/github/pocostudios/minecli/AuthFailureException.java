package com.github.pocostudios.minecli;

public class AuthFailureException extends RconClientException {
    public AuthFailureException() {
        super("Authentication failure (Check RCON password?)");
    }
}
