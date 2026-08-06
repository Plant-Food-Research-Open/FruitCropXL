
//   Implements a background command queue processor for
//   running minerva m-store commands in the background
//

import java.io.BufferedReader;
import java.io.InputStreamReader;


public final class BasicMinervaHelper {

    // Todo: make this a singleton?. (per-service?)

    private static String service;

    public  BasicMinervaHelper(String service) {
        BasicMinervaHelper.service = service;
    }


    // minerva m-store helper function
    public void m_store(String filename, String minerva_class, String object_id, String series_id){
        String[] command = new String[] { "m-store",
                                        BasicMinervaHelper.service,
                                        filename,
                                        "--class=" + minerva_class,
                                        "--oid=" + object_id,
                                        "-sid=" + series_id};
        executeSystemCommand(command);
    }


    // Note: using this basic method for groimp compatibility.  Suitable for fast low-latency commands.
    private void executeSystemCommand(String[] command) {
		int exitCode; 
        try {

            boolean synchronous = false;

            System.out.print("\n[System] " + String.join(" ", command));
            
            Process process = new ProcessBuilder(command)
                           // console output is currently disabled as m-store is too verbose and contains debug messages.!
//                        .inheritIO()    // send output to current terminal
                        .start();
                        
            if (synchronous) {
                exitCode = process.waitFor();
                // for debug
                // System.out.println("[FINISHED] Exit Code: " + exitCode);
                }

        } catch (Exception e) {
            System.err.println("[ERROR] Failed to run command: " + e.getMessage());
        }
    }



/**
    // example usage
    public static void main(String[] args) throws InterruptedException {

        BasicMinervaHelper mh = new BasicMinervaHelper("dhs-simulation-artifacts");

        // Target commands based on your OS environment
        boolean isWindows = System.getProperty("os.name").toLowerCase().contains("win");

        if (isWindows) {
            mh.executeSystemCommand(new String[]{"cmd.exe", "/c", "echo Hello World from Minerva helper!"});
            mh.executeSystemCommand(new String[]{"cmd.exe", "/c", "dir"});
            mh.executeSystemCommand(new String[]{"cmd.exe", "/c", "ping 127.0.0.1 -n 3"}); // Simulates a slow task
        } else {
            mh.executeSystemCommand(new String[]{"sh", "-c", "echo Hello World from Minerva helper!"});
            mh.executeSystemCommand(new String[]{"ls", "-la"});
            mh.executeSystemCommand(new String[]{"sleep", "3"}); // Simulates a slow task
        }

        mh.executeSystemCommand(isWindows ? new String[]{"cmd.exe", "/c", "echo Done!"} : new String[]{"echo", "Done!"});


        // example_m_store command:
        //     e.g. m_store("my-xeg-filename", "FruitCropXL-xeg", "1.2.3", "1.2.3.5")
        //
        //         
        // mh.m_store("my-file", "<data-class-name>", "<object_id>", "<series_id>")
    }
**/

}






            
