import java.util.*;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

class Warehouse2 {
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

    private Product missing(Product[] a){ 
        for(Product p : a){
            if(p.quantity == 0)
                return p;
        }
        return null;
    }

    // Errado se faltar algum produto...
    public void consume(Set<String> items) throws InterruptedException {
        l.lock();
        try{
            Product[] a = new Product[items.size()];
            int i = 0;
            
            for (String s : items){
                Product p = get(s);
                a[i++] = p;
            }
            //Primeira solução
            /*Product r = missing(a);
            while(r != null){
                r.cond.await();
                r = missing(a);
            }*/
            //Segunda solução
            for(;;){
                Product r = missing(a);
                if (r == null) break;
                r.cond.await();
            }

            for (Product p : a){
                p.quantity--;
            }

        } finally{
            l.unlock();
        }
    }

}
