import java.io.*;
import java.net.*;
public class Server {
    public static void main(String[] args) {
        try{
            int port = java.lang.Integer.parseInt(args[0]);
            ServerSocket srv = new ServerSocket(port);
        while (true) {
            Socket cli=srv.accept();
            System.out.println(cli.getInetAddress() + " "+ cli.getPort() );

            BufferedReader in = new BufferedReader(new InputStreamReader(cli.getInputStream()));
            PrintWriter out = new PrintWriter(cli.getOutputStream());
            
            String st = in.readLine();
            String res = st.toUpperCase();
            
            out.println(res);
            out.flush();
        }
        }catch(Exception e){
            e.printStackTrace();
        }
    }
}