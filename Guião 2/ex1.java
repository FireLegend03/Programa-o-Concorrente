
class Counter {
    private int c  = 0;
    public synchronized void increment(){
        c++;
    }

    public synchronized int value(){
        return c;
    }
}

class Incrementar extends Thread{
    private int I;
    private Counter c;

    public Incrementar(int I, Counter c){
        this.I = I;
        this.c = c;
    }

    public void run(){
        for(int i = 0; i < I; i++){
            c.increment();
        }
    }
}

class Ex1{
    public static void main(String[] args){
        final int N = Integer.parseInt(args[0]);
        final int I = Integer.parseInt(args[1]);
        Counter c = new Counter();
        
        Thread[] threads = new Thread[N];
        for (int i = 0; i < N; i++){
            threads[i] = new Incrementar(I, c);
            threads[i].start();
        }

        for (int i = 0; i < N; i++){
            try{
                threads[i].join();
            } catch (InterruptedException e){
                e.printStackTrace();
            }
        }
        System.out.println(c.value());
        System.out.println("Fim");

    }
}
