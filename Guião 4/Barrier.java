class Barrier {

    private final int N;
    private int c = 0;
    private int etapa = 0;

    Barrier (int N) {
        this.N = N;
    }
    public synchronized void await() throws InterruptedException {
        final int etapa = this.etapa;
        c++;
        if (c == N){
            c = 0;
            this.etapa += 1;
            notifyAll();
        }else{
            while(etapa == this.etapa){
                wait();
            }
        }
    }
}
    