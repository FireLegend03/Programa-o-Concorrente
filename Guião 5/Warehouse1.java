import java.util.*;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

class Warehouse1 {
    private Map<String, Product> map =  new HashMap<String, Product>();
    private Lock l = new ReentrantLock();

    private class Product { 
        int quantity = 0; 
        Condition cond = l.newCondition();
    }

    private Product get(String item) {
        Product p = map.get(item);
        if (p != null) return p;
        p = new Product();
        map.put(item, p);
        return p;
    }

    public void supply(String item, int quantity) {
        l.lock();
        try{
            Product p = get(item);
            p.quantity += quantity;
            p.cond.signalAll();
        } finally {
            l.unlock();
        }
    }

    // Errado se faltar algum produto...
    public void consume(Set<String> items) throws InterruptedException {
        l.lock();
        try{
            for (String s : items){
                Product p = get(s);
                while(p.quantity == 0){
                        p.cond.await(); 
                }
                p.quantity--;
            }

        } finally{
            l.unlock();
        }
    }

}
