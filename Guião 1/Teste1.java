class Inc extends Thread{
    private int I;
    private Counte c;

    public Inc(int i, Counte c){
        this.I = i;
        this.c = c;
    }

    public void run(){
        for(int i = 1; i <= this.I; i++){
            this.c.increment();
        }
    }

}

class Counte{
    public int i = 0;

    public void increment(){
        this.i += 1;
    }
}

class Teste1 {
    public static void main(String[] args) throws InterruptedException {
        int N = 50;
        int I = 100;
        Thread[] threads = new Thread[N];
        Counte c = new Counte();
        for(int i = 0; i < N; i++){
            threads[i] = new Inc(I, c);
            threads[i].start();
        }

        for(int i = 0; i < N; i++){
            threads[i].join();
        }

        System.out.println(c.i);

    }
}
