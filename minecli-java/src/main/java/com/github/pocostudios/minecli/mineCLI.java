package com.github.pocostudios.minecli;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Scanner;

//Some code borrowed from t9t's very good minecraftrconclient.

public class mineCLI {
    private static final int SUCCESSCODE = 0;
    private static final int INVALIDARGS = 1;
    private static final int AUTHFAIL = 2;

    private static final int DEFAUULTPORT = 25575;
    private static final String QUITCMD = "\\quit";

    public static void main(String[] args) {
        int exitCode = run(args);
        if (exitCode != 0) System.exit(exitCode);
    }

    private static int run(String[] args) {
        if (args.length < 3) return printUsage(); //Too little args!


        String[] address = args[0].split(":");

        if (address.length > 2) return printUsage();

        String host = address[0];
        int port = (address.length == 2) ? Integer.parseInt(address[1]) : 25575; //return 25575 if blank
        String password = args[1];

        List<String> commands = new ArrayList<>(Arrays.<String>asList(args).subList(2, args.length));

        boolean terminalMode = commands.contains("-t");

        if (terminalMode && commands.size() != 1) return printUsage();

        try (RconClient client = RconClient.open(host, port, password)) {

            Runtime.getRuntime().addShutdownHook(new Thread(client::close));

            if (terminalMode) {
                System.out.println("Authenticated. Type \"\\quit\" to quit.");
                System.out.print("> ");
                Scanner scanner = new Scanner(System.in);
                while (scanner.hasNextLine()) {
                    String line = scanner.nextLine();
                    if (line.trim().equals("\\quit"))
                        break;
                    String response = client.sendCommand(line);
                    System.out.println("< " + (response.isEmpty() ? "(null)" : response));
                    System.out.print("> ");
                }
            } else {
                for (String command : commands) {
                    System.out.println("> " + command);
                    String response = client.sendCommand(command);
                    System.out.println("< " + (response.isEmpty() ? "(null)" : response));
                }
            }
        } catch (AuthFailureException e) {
            System.err.println("Authentication failure (Check RCON password?)");
            return 2;
        }
        return 0;
    }


    private static int printUsage() {
        System.out.println("Usage: java -jar minecli-java.jar <hostname e.g. 127.0.0.1> <port e.g. 25575> <RCON password> <-interactive>");
        System.out.println();
        System.out.println("Example 1: java -jar minecli-java.jar localhost:25575 verysecurepassword 'say Hello!' 'teleport Blender_08 0 0 0'");
        System.out.println("Example 2: java -jar minecli-java.jar localhost:25575 verysecurepassword -t");
        System.out.println();
        System.out.println("The port can be omitted, the default is 25575.");
        System.out.println("\"-t\" enables interactive console mode, to enter commands in an interactive terminal.");
        return 1;
    }

}