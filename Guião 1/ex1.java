// javac ex1.java
// java A 5 3

class Printer extends Thread{
    private int I;

    public Printer(int I){
        this.I = I;
    }

    public void run(){
        for(int i = 0; i < I; i++){
            System.out.println(i);
        }
    }
}


class A{
    public static void main(String[] args){
        final int N = Integer.parseInt(args[0]);
        final int I = Integer.parseInt(args[1]);
        
        Thread[] threads = new Thread[N];
        for (int i = 0; i < N; i++){
            threads[i] = new Printer(I);
            threads[i].start();
        }

        for (int i = 0; i < N; i++){
            try{
                threads[i].join();
            } catch (InterruptedException e){
                e.printStackTrace();
            }
        }
        System.out.println("Fim");

    }
}
